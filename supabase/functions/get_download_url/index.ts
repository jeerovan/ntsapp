// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { authenticateB2 } from '../_common/backblaze.ts'

const B2_BUCKET_ID = Deno.env.get("B2_BUCKET_ID")!;
const B2_BUCKET_NAME = Deno.env.get("B2_BUCKET_NAME")!;

const B2_API_URL = Deno.env.get("B2_API")!;
const B2_DOWNLOAD_URL = Deno.env.get("B2_STORAGE");
/**
 * Generate a Pre-signed Download URL
 */
async function getDownloadUrl(filePath: string) {
  const { authorizationToken } = await authenticateB2();
  const response = await fetch(`${B2_API_URL}/b2_get_download_authorization`, {
    method: "POST",
    headers: {
      Authorization: authorizationToken,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      bucketId: B2_BUCKET_ID,
      fileNamePrefix: filePath,
      validDurationInSeconds: 3600, // 1 hour
    }),
  });

  if (!response.ok) {
    throw new Error("Failed to generate download authorization");
  }

  const data = await response.json();
  return `${B2_DOWNLOAD_URL}/file/${B2_BUCKET_NAME}/${filePath}?Authorization=${data.authorizationToken}`;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }

  try {
    const { fileName} = await req.json();

    if (!fileName) {
      return new Response(JSON.stringify({ error: "Missing fileName" }), { status: 400 });
    }

    const filePath = `${fileName}`; // ${userId}/${fileName}

    const downloadUrl = await getDownloadUrl(filePath);
      return new Response(JSON.stringify({ downloadUrl }), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: "Internal server error" }), { status: 500 });
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/get_download_url' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
