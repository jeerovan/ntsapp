// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

function extractPlanDetails(productId: string) {
  // Normalize to lowercase and remove the suffix after colon if present
  const normalizedId = productId.split(":")[0].toLowerCase();

  // Extract number of devices (default to 1 if not specified)
  const deviceMatch = normalizedId.match(/(\d+)devices?/);
  const numDevices = deviceMatch ? parseInt(deviceMatch[1], 10) : 1;

  // Extract storage size and convert to bytes
  const storageMatch = normalizedId.match(/(\d+)(gb|tb|mb|kb)/i);
  let storageBytes = 0;

  if (storageMatch) {
    const size = parseInt(storageMatch[1], 10);
    const unit = storageMatch[2].toLowerCase();

    switch (unit) {
      case "tb":
        storageBytes = size * 1024 * 1024 * 1024 * 1024;
        break;
      case "gb":
        storageBytes = size * 1024 * 1024 * 1024;
        break;
      default:
        storageBytes = size; // assume bytes if no unit
    }
  }

  return {
    storageBytes,
    numDevices,
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
    });
  }
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  const { event } = await req.json();
  console.log(event);
  try {
    const { product_id, expiration_at_ms, original_app_user_id } = event;
    if (product_id && expiration_at_ms && original_app_user_id) {
      const { storageBytes, numDevices } = extractPlanDetails(product_id);
      await supabase.from("plans").upsert({
        rc_id: original_app_user_id,
        expires_at: expiration_at_ms,
        b2_limit: storageBytes,
        devices: numDevices,
      }, { onConflict: "rc_id" }).eq("rc_id", original_app_user_id);
    }
  } catch (error) {
    console.log(error);
    return new Response(
      "",
      { status: 200 },
    );
  }
  return new Response(
    "",
    { status: 200 },
  );
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/webhook_rc' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
