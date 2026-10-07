-- SPARK FINAL TOKEN SYSTEM — 8 TRACKS
-- Run in Supabase SQL Editor. Existing tokens are preserved.
create extension if not exists pgcrypto;
create table if not exists public.spark_final_tokens (id bigint generated always as identity primary key, token text not null unique, track text not null, issued_at timestamptz not null default now(), used_at timestamptz);
alter table public.spark_final_tokens drop constraint if exists spark_final_tokens_track_check;
alter table public.spark_final_tokens add constraint spark_final_tokens_track_check check (track in ('data-analysis','web-development','bioinformatics','cyber-security','logistics','human-resources','marketing','general-skills'));
create index if not exists spark_final_tokens_token_idx on public.spark_final_tokens(token);
create index if not exists spark_final_tokens_track_idx on public.spark_final_tokens(track);
alter table public.spark_final_tokens enable row level security;
revoke all on public.spark_final_tokens from anon, authenticated;
drop function if exists public.issue_final_token(text);
create or replace function public.issue_final_token(p_track text) returns table(token text) language plpgsql security definer set search_path=public as $$ declare v_token text; begin if p_track not in ('data-analysis','web-development','bioinformatics','cyber-security','logistics','human-resources','marketing','general-skills') then raise exception 'Invalid track'; end if; v_token:=upper(substr(encode(gen_random_bytes(9),'hex'),1,6))||'-'||upper(substr(encode(gen_random_bytes(9),'hex'),7,6))||'-'||upper(substr(encode(gen_random_bytes(9),'hex'),13,6)); insert into public.spark_final_tokens(token,track) values(v_token,p_track); return query select v_token; end; $$;
grant execute on function public.issue_final_token(text) to anon, authenticated;
drop function if exists public.verify_final_tokens(text[]);
create or replace function public.verify_final_tokens(p_tokens text[]) returns table(success boolean,message text) language plpgsql security definer set search_path=public as $$ declare v_count integer; v_tracks integer; begin if coalesce(array_length(p_tokens,1),0)<>8 then return query select false,'Exactly 8 tokens are required.'; return; end if; select count(*) into v_count from public.spark_final_tokens where token=any(p_tokens) and used_at is null; if v_count<>8 then return query select false,'One or more tokens are invalid or already used.'; return; end if; select count(distinct track) into v_tracks from public.spark_final_tokens where token=any(p_tokens) and used_at is null; if v_tracks<>8 then return query select false,'You need one valid token from each of the 8 final tracks.'; return; end if; update public.spark_final_tokens set used_at=now() where token=any(p_tokens) and used_at is null; return query select true,'Final unlocked.'; end; $$;
grant execute on function public.verify_final_tokens(text[]) to anon, authenticated;
