import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const adminClient = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false, autoRefreshToken: false } }
);

async function hashPassword(plain: string): Promise<string> {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(plain));
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, "0")).join("");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { action, payload } = await req.json();

    // ── Admin şifresini doğrula (login) ──────────────────────────────────────
    if (action === "verify") {
      const { password } = payload;
      const { data } = await adminClient
        .from("settings")
        .select("value")
        .eq("key", "adminPassword")
        .single();

      const correctHash = data?.value ?? await hashPassword("admin");
      const inputHash   = await hashPassword(password);
      const ok = inputHash === correctHash;

      return new Response(JSON.stringify({ ok }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // ── Admin şifresini değiştir ──────────────────────────────────────────────
    if (action === "changePassword") {
      const { oldPassword, newPassword } = payload;

      // Eski şifreyi doğrula
      const { data: settingRow } = await adminClient
        .from("settings")
        .select("value")
        .eq("key", "adminPassword")
        .single();

      const currentHash = settingRow?.value ?? await hashPassword("admin");
      const oldHash     = await hashPassword(oldPassword);

      if (oldHash !== currentHash) {
        return new Response(JSON.stringify({ ok: false, error: "Eski şifre hatalı." }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      if (!newPassword || newPassword.length < 4) {
        return new Response(JSON.stringify({ ok: false, error: "Yeni şifre en az 4 karakter olmalı." }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const newHash = await hashPassword(newPassword);
      const { error } = await adminClient
        .from("settings")
        .upsert([{ key: "adminPassword", value: newHash }], { onConflict: "key" });

      if (error) {
        return new Response(JSON.stringify({ ok: false, error: error.message }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      return new Response(JSON.stringify({ ok: true, newHash }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ error: "Unknown action" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

