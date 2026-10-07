/* SPARK FINAL TOKEN SYSTEM */
const SPARK_SUPABASE_URL = "https://kyiyxkprrqdgosmhabjv.supabase.co";
const SPARK_SUPABASE_KEY = "sb_publishable_hMnZrZlncivkcZFgO7nlwA_QOnAwlVJ";

async function issueSparkFinalToken(trackId) {
  const storageKey = `spark_final_token_${trackId}`;
  const existing = localStorage.getItem(storageKey);
  if (existing) return existing;

  const response = await fetch(`${SPARK_SUPABASE_URL}/rest/v1/rpc/issue_final_token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": SPARK_SUPABASE_KEY,
      "Authorization": `Bearer ${SPARK_SUPABASE_KEY}`
    },
    body: JSON.stringify({ p_track: trackId })
  });

  const data = await response.json();
  if (!response.ok) throw new Error(data?.message || data?.error || "Could not generate token.");
  const token = Array.isArray(data) ? data[0]?.token : data?.token;
  if (!token) throw new Error("No token was returned.");
  localStorage.setItem(storageKey, token);
  return token;
}

async function revealSparkFinalToken(trackId, targetId = "finalTokenBox") {
  const box = document.getElementById(targetId);
  if (!box) return;
  box.innerHTML = `<div class="token-loading">GENERATING YOUR FINAL TOKEN…</div>`;
  try {
    const token = await issueSparkFinalToken(trackId);
    box.innerHTML = `
      <div class="token-label">YOUR FINAL TOKEN</div>
      <div class="token-value" id="sparkTokenValue">${token}</div>
      <div class="token-warning">KEEP THIS CODE. YOUR TEAM WILL NEED IT.</div>
    `;
  } catch (error) {
    console.error(error);
    box.innerHTML = `<div class="token-error">TOKEN GENERATION FAILED. PLEASE TRY AGAIN.</div>`;
  }
}
