import { createClient } from "jsr:@supabase/supabase-js@2";

export async function getUserPlanStatus(
  authorization: string,
  fileSize: number,
) {
  let status = 200;
  let error = "";
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    {
      global: {
        headers: { Authorization: authorization },
      },
    },
  );
  // First get the token from the Authorization header
  const userToken = authorization.replace("Bearer ", "");

  // Now we can get the session or user object
  const {
    data: { user },
  } = await supabaseClient.auth.getUser(userToken);
  const userId = user?.id;

  // Get user plan
  const { data: plan, error: planError } = await supabaseClient
    .from("plans")
    .select("b2_limit,expires_at")
    .eq("id", userId)
    .single();

  if (planError || !plan) {
    status = 400;
    error = "Failed to fetch plan";
    return { status, userId, error };
  }

  if (new Date(plan.expires_at) < new Date()) {
    status = 400;
    error = "Plan expired";
    return { status, userId, error };
  }

  const { data: storage, error: storageError } = await supabaseClient
    .from("storage")
    .select("b2_size")
    .eq("id", userId)
    .single();

  if (storageError || !storage) {
    error = "Failed to fetch storage";
    status = 400;
    return { status, userId, error };
  }

  if (fileSize > (plan.b2_limit - storage.b2_size)) {
    status = 400;
    error = "Storage limit exceeded";
    return { status, userId, error };
  }

  return { status, userId, error };
}
