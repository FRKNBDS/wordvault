// ── WORDVAULT SERVICE WORKER ─────────────────────────────────────────────────
// Amaç: Uygulama internetsizken de açılabilsin (ilk açılış dahil, bir kez
// internetle ziyaret edildikten sonra). Yeni bir deploy yapıldığında en güncel
// dosyalar otomatik olarak cache'e alınır, eskiler temizlenir.
//
// Strateji:
//  - Navigasyon istekleri (sayfa yüklemeleri): cache'i önce dene, yoksa ağa git,
//    ağ da yoksa cache'teki index.html'i göster (app shell fallback).
//  - Diğer tüm istekler (JS/CSS/font/ikon vb.): "stale-while-revalidate" —
//    cache varsa anında onu döndür + arka planda ağdan tazele; cache yoksa ağa git.
//  - Supabase / harici API istekleri: SW'ye hiç dokunulmaz (ağ olduğu gibi gider).
//    Bu veriler App.jsx içinde IndexedDB'ye yazılıp oradan okunuyor zaten.

const CACHE_VERSION = "wordvault-v1";
const APP_SHELL = ["/", "/index.html", "/manifest.json", "/privacy-policy.html"];

// Sadece kendi origin'imizdeki (Vercel) istekleri cache'leyelim.
// Supabase, GitHub raw gibi harici domain'lere SW karışmasın.
function isSameOrigin(url) {
  try {
    return new URL(url).origin === self.location.origin;
  } catch {
    return false;
  }
}

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then((cache) =>
      Promise.all(
        APP_SHELL.map((url) =>
          cache.add(url).catch(() => {
            // Dosya yoksa veya alınamıyorsa sessizce geç, kurulumu bozmasın
          })
        )
      )
    )
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const { request } = event;

  // Sadece GET isteklerini ele al; POST/PUT vb. (Supabase yazma istekleri gibi)
  // SW'den geçmeden direkt ağa gitsin.
  if (request.method !== "GET") return;

  // Harici (cross-origin) istekler — Supabase, GitHub raw, vb. — SW'ye karışmaz.
  if (!isSameOrigin(request.url)) return;

  // Sayfa navigasyonu (kullanıcı uygulamayı açıyor / yeniliyor)
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((res) => {
          // Ağdan başarıyla geldiyse cache'i güncelle
          const copy = res.clone();
          caches.open(CACHE_VERSION).then((c) => c.put("/index.html", copy)).catch(() => {});
          return res;
        })
        .catch(() =>
          // İnternet yok: cache'teki app shell'i göster
          caches.match("/index.html").then((cached) => cached || caches.match("/"))
        )
    );
    return;
  }

  // Diğer same-origin istekler (JS/CSS/ikonlar/manifest):
  // stale-while-revalidate — cache varsa hemen onu ver, arka planda tazele.
  event.respondWith(
    caches.open(CACHE_VERSION).then(async (cache) => {
      const cached = await cache.match(request);
      const networkFetch = fetch(request)
        .then((res) => {
          if (res && res.status === 200) cache.put(request, res.clone());
          return res;
        })
        .catch(() => null);

      return cached || networkFetch || Response.error();
    })
  );
});
