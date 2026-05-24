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

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { action, payload } = await req.json();

    const respond = (data: unknown, status = 200) =>
      new Response(JSON.stringify(data), {
        status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });

    // ── LEVELS ────────────────────────────────────────────────────────────────
    if (action === "insertLevel") {
      const { data, error } = await adminClient.from("levels").insert([payload]).select().single();
      if (error) return respond({ error: error.message }, 400);
      return respond({ data });
    }

    if (action === "deleteLevel") {
      const { error } = await adminClient.from("levels").delete().eq("id", payload.id);
      if (error) return respond({ error: error.message }, 400);
      return respond({ ok: true });
    }

    // ── WORDSETS ──────────────────────────────────────────────────────────────
    if (action === "insertWordset") {
      const { data, error } = await adminClient.from("wordsets").insert([payload]).select().single();
      if (error) return respond({ error: error.message }, 400);
      return respond({ data });
    }

    if (action === "deleteWordset") {
      const { error } = await adminClient.from("wordsets").delete().eq("id", payload.id);
      if (error) return respond({ error: error.message }, 400);
      return respond({ ok: true });
    }

    // ── WORDS ─────────────────────────────────────────────────────────────────
    if (action === "insertWord") {
      const { data, error } = await adminClient.from("words").insert([payload]).select().single();
      if (error) return respond({ error: error.message }, 400);
      return respond({ data });
    }

    if (action === "insertWords") {
      // Bulk import
      const { data, error } = await adminClient.from("words").insert(payload.words);
      if (error) return respond({ error: error.message }, 400);
      return respond({ ok: true, data });
    }

    if (action === "updateWord") {
      const { id, ...fields } = payload;
      const { error } = await adminClient.from("words").update(fields).eq("id", id);
      if (error) return respond({ error: error.message }, 400);
      return respond({ ok: true });
    }

    if (action === "deleteWord") {
      const { error } = await adminClient.from("words").delete().eq("id", payload.id);
      if (error) return respond({ error: error.message }, 400);
      return respond({ ok: true });
    }

    return respond({ error: "Unknown action" }, 400);

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
