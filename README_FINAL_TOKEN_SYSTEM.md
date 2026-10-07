# SPARK Final Token System

## What changed
The old 6-piece Final QR system is replaced with six unique one-time tokens.

Flow:
Track QR → Challenge → unique token → six people collect six different track tokens → `final-unlock.html` → verification → Final QR → `final-reveal.html`.

## Supabase setup
1. Open the Supabase project already used by the site.
2. Open SQL Editor.
3. Paste and run `supabase_final_tokens.sql`.
4. Publish the updated GitHub Pages files.

No secret/service-role key is required in the website. The existing publishable key is used for RPC calls.

## Important security note
The current track answers are still implemented in the public HTML/JavaScript. This token layer prevents reusing a token after it has been consumed and requires one token from each final track, but a technically skilled person can still inspect the public challenge code and call the public token RPC directly. For a high-stakes anti-cheat setup, the next hardening step is to move answer validation into Supabase functions too.
