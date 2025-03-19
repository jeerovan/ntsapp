// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { getUserPlanStatus } from "../_shared/supabase.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface EncryptedData {
  id: string;
  cipher_text: string;
  cipher_nonce: string;
  key_cipher: string;
  key_nonce: string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }
  try {
    const authorization = req.headers.get("Authorization") ?? "";
    const deviceId = req.headers.get("deviceId") ?? "";
    const plan = await getUserPlanStatus(authorization, 0, deviceId);
    if (plan.status > 200) {
      return new Response(JSON.stringify({ error: plan.error }), {
        status: plan.status,
      });
    }
    const { lastAt } = await req.json();
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const tables = ["category", "itemgroup", "item"];
    const changes: Record<string, EncryptedData[]> = {};
    for (const table of tables) {
      const { data } = await supabaseClient
        .from(table)
        .select("id,cipher_text,cipher_nonce,key_cipher,key_nonce")
        .eq("user_id", plan.userId)
        .neq("device_id", deviceId)
        .gt("server_at", lastAt);
      if (data && data.length > 0) changes[table] = data;
    }
    return new Response(JSON.stringify(changes), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error }), { status: 400 });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/fetch_changes' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
