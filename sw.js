// WordVault Service Worker
// Strateji: App Shell + Network First (API), Cache First (statik dosyalar)

const CACHE_NAME = 'wordvault-v1';
const STATIC_CACHE = 'wordvault-static-v1';

// Uygulama açılışında önbelleğe alınacak dosyalar (App Shell)
const APP_SHELL = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
];

// ── Kurulum: App Shell'i önbelleğe al ────────────────────────────────────────
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => {
      return cache.addAll(APP_SHELL);
    })
  );
  // Hemen aktif ol, bekletme
  self.skipWaiting();
});

// ── Aktivasyon: Eski önbellekleri temizle ────────────────────────────────────
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME && name !== STATIC_CACHE)
          .map((name) => caches.delete(name))
      );
    })
  );
  // Tüm sekmeleri hemen ele geç
  self.clients.claim();
});

// ── Fetch: Ağ stratejisi ─────────────────────────────────────────────────────
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Supabase ve GitHub API isteklerini → Network First
  if (
    url.hostname.includes('supabase.co') ||
    url.hostname.includes('githubusercontent.com') ||
    url.hostname.includes('raw.githubusercontent.com')
  ) {
    event.respondWith(networkFirst(request));
    return;
  }

  // Google Fonts → Cache First
  if (url.hostname.includes('fonts.googleapis.com') || url.hostname.includes('fonts.gstatic.com')) {
    event.respondWith(cacheFirst(request));
    return;
  }

  // Statik dosyalar (JS, CSS, resim) → Cache First
  if (
    request.destination === 'script' ||
    request.destination === 'style' ||
    request.destination === 'image' ||
    request.destination === 'font'
  ) {
    event.respondWith(cacheFirst(request));
    return;
  }

  // Sayfa navigasyonları → Network First, hata durumunda index.html dön (SPA)
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request).catch(() => caches.match('/index.html'))
    );
    return;
  }

  // Diğer her şey → Network First
  event.respondWith(networkFirst(request));
});

// ── Yardımcı: Network First ──────────────────────────────────────────────────
async function networkFirst(request) {
  try {
    const networkResponse = await fetch(request);
    // Başarılı yanıtı önbelleğe al
    if (networkResponse.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch {
    // Ağ yoksa önbellekten dön
    const cached = await caches.match(request);
    return cached || new Response('Çevrimdışısınız ve bu içerik önbellekte yok.', {
      status: 503,
      headers: { 'Content-Type': 'text/plain; charset=utf-8' },
    });
  }
}

// ── Yardımcı: Cache First ────────────────────────────────────────────────────
async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(STATIC_CACHE);
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch {
    return new Response('', { status: 503 });
  }
}
