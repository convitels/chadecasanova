-- v3: CORRIGE O SITE NÃO MOSTRAR "INDISPONÍVEL" E NÃO CANCELAR.
-- Verificado em 27/10: o banco estava sem as funções novas e sem permissão de leitura da lista de presentes.
-- Execute TODO este arquivo no SQL Editor do Supabase e clique em RUN.

grant usage on schema public to anon, authenticated;
alter table public.gifts enable row level security;
drop policy if exists "public can read gifts" on public.gifts;
create policy "public can read gifts" on public.gifts for select to anon, authenticated using (true);
grant select on public.gifts to anon, authenticated;
grant execute on function public.reserve_gift(uuid,text) to anon, authenticated;

-- CHA DE CASA NOVA — SABRINA & LUCAS
-- Atualização: cancelamento por nome e sobrenome, disponibilidade visível para todos .
-- Execute UMA VEZ no SQL Editor do Supabase (projeto qtxdtjvgnknfzpttrvhl), DEPOIS do supabase_configuracao_completa.sql.
-- Não apaga presentes nem reservas.

-- 2) Normaliza nomes (ignora maiúsculas, acentos e espaços extras)
create or replace function public.normalize_guest_name(p text)
returns text language sql immutable set search_path=public as $$
  select lower(regexp_replace(trim(translate(coalesce(p,''),
    'ÁÀÂÃÄáàâãäÉÈÊËéèêëÍÌÎÏíìîïÓÒÔÕÖóòôõöÚÙÛÜúùûüÇçÑñ',
    'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCcNn')), '\s+', ' ', 'g'));
$$;

-- 3) Lista pública de presentes reservados (sem expor o nome de quem reservou)
create or replace function public.get_reserved_gift_ids()
returns setof uuid language sql stable security definer set search_path=public as $$
  select distinct gift_id from public.gift_reservations where cancelled_at is null;
$$;
revoke all on function public.get_reserved_gift_ids() from public;
grant execute on function public.get_reserved_gift_ids() to anon, authenticated;

-- 4) Reserva exige nome e sobrenome
create or replace function public.reserve_gift(p_gift_id uuid, p_guest_name text)
returns jsonb language plpgsql security definer set search_path=public,extensions as $$
declare v_reservation_id uuid; v_token text; v_name text;
begin
  v_name:=regexp_replace(trim(coalesce(p_guest_name,'')),'\s+',' ','g');
  if char_length(v_name)<3 or char_length(v_name)>100 or position(' ' in v_name)=0 then
    raise exception 'Informe nome e sobrenome.';
  end if;
  if not exists(select 1 from public.gifts where id=p_gift_id) then raise exception 'Presente não encontrado.'; end if;
  perform pg_advisory_xact_lock(hashtext(p_gift_id::text));
  if exists(select 1 from public.gift_reservations where gift_id=p_gift_id and cancelled_at is null) then
    raise exception 'Esse presente já foi reservado.';
  end if;
  v_token:=encode(extensions.gen_random_bytes(32),'hex');
  insert into public.gift_reservations(gift_id,guest_name,cancellation_token_hash)
  values(p_gift_id,v_name,encode(extensions.digest(v_token,'sha256'),'hex')) returning id into v_reservation_id;
  return jsonb_build_object('reservation_id',v_reservation_id,'cancellation_token',v_token);
end; $$;

-- 5) Cancelamento: funciona em qualquer aparelho, desde que o nome e sobrenome confiram com a reserva
create or replace function public.cancel_gift_reservation_by_name(p_gift_id uuid, p_guest_name text)
returns boolean language plpgsql security definer set search_path=public as $$
declare v_count integer;
begin
  if position(' ' in public.normalize_guest_name(p_guest_name))=0 then return false; end if;
  update public.gift_reservations
     set cancelled_at=now(), cancelled_by_name=trim(p_guest_name)
   where gift_id=p_gift_id and cancelled_at is null
     and public.normalize_guest_name(guest_name)=public.normalize_guest_name(p_guest_name);
  get diagnostics v_count=row_count;
  return v_count>0;
end; $$;
revoke all on function public.cancel_gift_reservation_by_name(uuid,text) from public;
grant execute on function public.cancel_gift_reservation_by_name(uuid,text) to anon, authenticated;

notify pgrst, 'reload schema';

select 'reservas ativas' as verificacao, count(*) from public.gift_reservations where cancelled_at is null;
