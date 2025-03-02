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

export async function setFileEntry(
  userId: string,
  fileId: string,
  cipher: string,
  nonce: string,
  parts: number,
  size: number,
) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const { data: existingFile } = await supabaseClient.from("files").select().eq(
    "id",
    fileId,
  ).single();
  if (existingFile) {
    return existingFile;
  } else {
    const { data: file } = await supabaseClient.from("files").insert({
      id: fileId,
      user_id: userId,
      key_cipher: cipher,
      key_nonce: nonce,
      parts: parts,
      size: size,
    }).select().single();
    return file;
  }
}

export async function setFileUploaded(
  fileId: string,
  parts: number,
) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  const now = new Date().getTime();
  await supabaseClient.from("files").update({
    parts_uploaded: parts,
    uploaded_at: now,
  }).eq(
    "id",
    fileId,
  ).lt("uploaded_at", now);
}

export async function getDownloadToken(userFileId: string) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  let existingToken = null;
  let existingTokenExpires = null;

  // Fetch existing token from Supabase (Only fetching required columns)
  const { data, error } = await supabaseClient
    .from("files")
    .select("token, expires")
    .eq("id", userFileId)
    .single();

  // If no data exists, we must generate a new token
  if (data && !error) {
    existingToken = data.token;
    existingTokenExpires = data.expires;
  }
  return { existingToken, existingTokenExpires };
}

export async function setDownloadToken(
  userFileId: string,
  token: string,
  expires: number,
) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // update token and expiry
  await supabaseClient
    .from("files")
    .update({ token: token, expires: expires })
    .eq("id", userFileId);
}

export async function getFile(fileId: string) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // Fetch
  const { data: file, error } = await supabaseClient
    .from("files")
    .select()
    .eq("id", fileId)
    .single();
  if (!error) {
    return file;
  }
  return null;
}

export async function setB2FileId(userFileId: string, b2FileId: string) {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  // update b2fileid
  await supabaseClient
    .from("files")
    .update({ b2_id: b2FileId })
    .eq("id", userFileId).is("b2_id", null);
}
