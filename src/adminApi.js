// adminApi.js
// supabaseAdmin yerine Edge Function'ları çağırır — service_role key frontend'de olmaz.

const BASE = import.meta.env.VITE_SUPABASE_URL + "/functions/v1";

async function call(fn, action, payload) {
  const res = await fetch(`${BASE}/${fn}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      // Supabase Edge Functions için anon key yeterli (gerçek yetki sunucuda)
      "apikey": import.meta.env.VITE_SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ action, payload }),
  });
  const json = await res.json();
  if (json.error) throw new Error(json.error);
  return json;
}

// ── ADMIN AUTH ────────────────────────────────────────────────────────────────

/** Admin şifresini doğrula. true/false döner. */
export async function adminVerifyPassword(password) {
  const { ok } = await call("admin-auth", "verify", { password });
  return ok;
}

/**
 * Admin şifresini değiştir.
 * Başarılıysa { ok: true, newHash } döner.
 * Hata varsa Error fırlatır.
 */
export async function adminChangePassword(oldPassword, newPassword) {
  return call("admin-auth", "changePassword", { oldPassword, newPassword });
}

// ── LEVELS ───────────────────────────────────────────────────────────────────

export async function adminInsertLevel(levelData) {
  const { data } = await call("admin-content", "insertLevel", levelData);
  return data;
}

export async function adminDeleteLevel(id) {
  return call("admin-content", "deleteLevel", { id });
}

// ── WORDSETS ──────────────────────────────────────────────────────────────────

export async function adminInsertWordset(wordsetData) {
  const { data } = await call("admin-content", "insertWordset", wordsetData);
  return data;
}

export async function adminDeleteWordset(id) {
  return call("admin-content", "deleteWordset", { id });
}

// ── WORDS ─────────────────────────────────────────────────────────────────────

export async function adminInsertWord(wordData) {
  const { data } = await call("admin-content", "insertWord", wordData);
  return data;
}

/** Bulk insert — import için */
export async function adminInsertWords(words) {
  return call("admin-content", "insertWords", { words });
}

export async function adminUpdateWord(id, fields) {
  return call("admin-content", "updateWord", { id, ...fields });
}

export async function adminDeleteWord(id) {
  return call("admin-content", "deleteWord", { id });
}
