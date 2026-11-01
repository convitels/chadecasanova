-- CHA DE CASA NOVA — SABRINA & LUCAS
-- Execute no SQL Editor do projeto Supabase qtxdtjvgnknfzpttrvhl.
-- Faça backup antes. Este script cria/ajusta as tabelas usadas pelo site e sincroniza a lista de presentes.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.gifts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Outros',
  purchase_url text,
  price numeric(10,2),
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
alter table public.gifts add column if not exists category text not null default 'Outros';
alter table public.gifts add column if not exists purchase_url text;
alter table public.gifts add column if not exists price numeric(10,2);
alter table public.gifts add column if not exists sort_order integer not null default 0;

create table if not exists public.gift_reservations (
  id uuid primary key default gen_random_uuid(),
  gift_id uuid not null references public.gifts(id),
  guest_name text not null,
  cancellation_token_hash text not null,
  created_at timestamptz not null default now(),
  cancelled_at timestamptz,
  cancelled_by_name text
);
alter table public.gift_reservations add column if not exists cancelled_at timestamptz;
alter table public.gift_reservations add column if not exists cancelled_by_name text;
alter table public.gift_reservations add column if not exists cancellation_token_hash text;

create table if not exists public.rsvps (
  id uuid primary key default gen_random_uuid(),
  guest_name text not null,
  attending boolean not null,
  guest_count integer not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.site_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Catálogo oficial: IDs estáveis usados pelo site e pelas reservas.
insert into public.gifts (id, name, category, purchase_url, price, sort_order) values
('3b8214da-dca0-5889-a9a0-21f352a5bd77'::uuid, 'Liquidificador', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB50246468?matt_tool=38524122&pdp_filters=item_id:MLB5431230760&ua=gsFwefYKKB_X4KjTFNvJSJkPYuJkmqOpjNxZzoj_9e2gHDWY#origin=share&sid=share&wid=MLB5431230760&action=copy', ''), NULL, 1),
('9add1032-fc89-593d-a745-7a0ff8365c8d'::uuid, 'Air fryer', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB40550797?matt_tool=38524122&pdp_filters=item_id:MLB7751907582&ua=au9velmw25WqnWh22nOkmCYujBzWRWAwaIoZ8-qdZqVMjsRV#origin=share&sid=share&wid=MLB7751907582&action=copy', ''), NULL, 2),
('57258beb-12c0-5044-ab9f-c5eb91f15c3f'::uuid, 'Sanduicheira', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB22517436?attributes=COLOR:MLB22517436&matt_tool=38524122&pdp_filters=item_id:MLB4309475388&ua=N9IcP8PoVrt07qK2RB3JHoQQQl5f9wK6OCJAf5rKH9JERMV5#origin=share&sid=share&action=copy', ''), NULL, 3),
('2a183484-7bfb-5382-9392-b82d8f1a492f'::uuid, 'Batedeira', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB18278476?attributes=COLOR:MLB18278476,VOLTAGE:MLB18278476&matt_tool=38524122&pdp_filters=item_id:MLB2107759529&ua=gcoIyo4NnGWCGwppZA__BWA772aBMZhkPAmb454laqzvR4ix#origin=share&sid=share&action=copy', ''), NULL, 4),
('4872391a-adbf-59f2-96e2-cff46031a999'::uuid, 'Multiprocessador', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU5598104360?matt_tool=38524122&pdp_filters=item_id:MLB7841041018&ua=cedvw6Zi0QErUBR2kx5vB2qzzfAmQxM3Ekhp15M_sU9EakSW#origin=share&sid=share&wid=MLB7841041018&action=copy', ''), NULL, 5),
('b7ef5d3b-93a1-5239-a5d9-84e029c21255'::uuid, 'Jogo de panelas', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU1160704522?matt_tool=38524122&pdp_filters=item_id:MLB7143036282&ua=QqfQZnI8j_Q-HMgZd2u6utMKUZq7J2mr5lVzDg4YCQc45YlY#origin=share&sid=share&wid=MLB7143036282&action=copy', ''), NULL, 6),
('640e230d-f0ae-520d-99f3-3d5d2455cb06'::uuid, 'Panela de pressão', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB61738923?matt_tool=38524122&pdp_filters=item_id:MLB5106982677&ua=cn1_hMZkxsTFSN_2DBgylo9koAwnNFQbe2i6VR2Q40Ka91b9#origin=share&sid=share&wid=MLB5106982677&action=copy', ''), NULL, 7),
('3da621bb-ab07-580d-ab08-7487f82bacf9'::uuid, 'Formas de bolo', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB52421585?matt_tool=38524122&pdp_filters=item_id:MLB4127412633&ua=XIjkqFSOtPijFshb-y-gtafyvPL4FF-yYggUQ3GkccKsVM61#origin=share&sid=share&wid=MLB4127412633&action=copy', ''), NULL, 8),
('4caf6f9f-c10d-56c4-bca9-8183422311ef'::uuid, 'Utensílios de cozinha', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB79494417?matt_tool=38524122&pdp_filters=item_id:MLB7664094526&ua=7Xy3p01K1B-6iQzEJSh4d8AQg8x4KxvzdW_L0rWzsmEH-rzH#origin=share&sid=share&wid=MLB7664094526&action=copy', ''), NULL, 9),
('0907c80f-2825-5844-9ec1-bec277935f1d'::uuid, 'Tábua de corte', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU3118686696?matt_tool=38524122&pdp_filters=item_id:MLB4027938361&ua=36wLllyrD6elK6J0B1YsZitqt6I0YU3nwNBKAvIKlO0QOvQ-#origin=share&sid=share&wid=MLB4027938361&action=copy', ''), NULL, 10),
('63fa9aa1-4226-5bc0-97e5-3d73e3f33bd0'::uuid, 'Amolador de faca', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB54139573?matt_tool=38524122&pdp_filters=item_id:MLB5662788518&ua=7nVYIQEX3l3bhi3DjYBC-x-qTY438qLneSzW4msGRm8AsWUH#origin=share&sid=share&wid=MLB5662788518&action=copy', ''), NULL, 11),
('0673355f-ba5c-594d-be13-766f803621ba'::uuid, 'Medidores', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB54099733?matt_tool=38524122&pdp_filters=item_id:MLB4181266827&ua=ZAqjfm4Q_eoVUss0DaUmmH6oMJQhcyBMBO0P3frKuc_udMPe#origin=share&sid=share&wid=MLB4181266827&action=copy', ''), NULL, 12),
('607e9b52-94e2-5d75-964d-4c286a1d9875'::uuid, 'Jogo de pratos', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU5497050740?matt_tool=38524122&pdp_filters=item_id:MLB5377370165&ua=dnxS-J5iLxSVguQM65vVRs7mTYALGwWhJV6nZriYhdCly_L7#origin=share&sid=share&wid=MLB5377370165&action=copy', ''), NULL, 13),
('429ff6ee-ac15-5f91-9464-d62de5bcd579'::uuid, 'Jogo de copos', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB78425687?matt_tool=38524122&pdp_filters=item_id:MLB7522944742&ua=6M41azt-9Q9Hyhr3Czl8dp8ZOS9Q4Keq_4_Gm_nSCNyMoXJp#origin=share&sid=share&wid=MLB7522944742&action=copy', ''), NULL, 14),
('e761df54-f4ea-5718-b621-a24c7fccdff0'::uuid, 'Jogo de xícaras', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU5138829615?matt_tool=38524122&pdp_filters=item_id:MLB7624610344&ua=e0fQYAjGN9QDuSulMFCvF0FbAL2ADAh8S8i5udznOy0tXprt#origin=share&sid=share&wid=MLB7624610344&action=copy', ''), NULL, 15),
('581cf5cf-5f7e-5ae6-9fbc-24864f1749b2'::uuid, 'Jogo de taças', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU4643241640?matt_tool=38524122&pdp_filters=item_id:MLB7359077426&ua=g2HAfuYAYrYQPGeogwee77rhsCfOe-rKpLgj6rC6I8WhGIpI#origin=share&sid=share&wid=MLB7359077426&action=copy', ''), NULL, 16),
('6664e787-0dbd-5e9d-a557-f99f537dc583'::uuid, 'Talheres', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB36709502?matt_tool=38524122&pdp_filters=item_id:MLB3970525547&ua=N7eHVrQzVXhjXl7rX_M5EljOwhEGDBOazQf2CT5jQsvW_lU9#origin=share&sid=share&wid=MLB3970525547&action=copy', ''), NULL, 17),
('83b36ab9-9b5c-51a9-831c-24d80c7098eb'::uuid, 'Faqueiro', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU4648319856?matt_tool=38524122&pdp_filters=item_id:MLB5017408237&ua=dgEsPtkgEZaaNwDRwefSQNCfrMu5DVOxmLx3tktY23Pe9qPa#origin=share&sid=share&wid=MLB5017408237&action=copy', ''), NULL, 18),
('9cebb3b5-f7ea-5871-9e72-c3cf16124615'::uuid, 'Travessas', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB68669531?matt_tool=38524122&pdp_filters=item_id:MLB4637120445&ua=GQ7MOfJOtUguqS_M9BZhPi5hrkaREgPOe1z0UWRdJZc8L5xc#origin=share&sid=share&wid=MLB4637120445&action=copy', ''), NULL, 19),
('776346cb-6827-5a9d-9fd4-e4c7b32060ec'::uuid, 'Jarra de vidro', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB30422754?matt_tool=38524122&pdp_filters=item_id:MLB6982482836&ua=kUEt6AKCHa-nqm3mspR4kvpEh0ppm6uwRprl6fw0IMIHgk1i#origin=share&sid=share&wid=MLB6982482836&action=copy', ''), NULL, 20),
('f1d3f841-5ef5-5beb-a58b-e9f5a963c59f'::uuid, 'Garrafa de café', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB10005805?matt_tool=38524122&pdp_filters=item_id:MLB5573178268&ua=KPN8FXGA783Ub6wH92J2WLm0RjL2bQvLxNYMt9YksmHKfhLf#origin=share&sid=share&wid=MLB5573178268&action=copy', ''), NULL, 21),
('cfec89f0-72f1-5bcf-a84e-29cb81829807'::uuid, 'Boleira', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB75079296?matt_tool=38524122&pdp_filters=item_id:MLB4861205543&ua=Sq1g_2DSZ7dMZOJuviytC8j1LE257SXUi6esQlhiZzNECDP9#origin=share&sid=share&wid=MLB4861205543&action=copy', ''), NULL, 22),
('29d32e05-254a-5680-8f8b-40403e7bbda7'::uuid, 'Potes de mantimentos', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB70039210?matt_tool=38524122&pdp_filters=item_id:MLB6864258918&ua=p1MlBhhDscuHj8AO4fTVxTkWld1tbk7DOTt5w7D0hxZswmoX#origin=share&sid=share&wid=MLB6864258918&action=copy', ''), NULL, 23),
('bbfd005c-a02f-529e-b848-d837956fe9d8'::uuid, 'Potes de vidro', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB53222689?matt_tool=38524122&pdp_filters=item_id:MLB5574851656&ua=aGqSbRcvhuCy3bS7LVy4v57R1TExT1i39gN1RyqEVrdLuSBR#origin=share&sid=share&wid=MLB5574851656&action=copy', ''), NULL, 24),
('bb5ba461-bbc7-55eb-b958-479d26b5d76e'::uuid, 'Saleiro', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB26331078?matt_tool=38524122&pdp_filters=item_id:MLB3932889655&ua=WwimZyNTdYJC6uVG1eHsYrj4V_XOIuj8MVEyClXfGKZkEKQC#origin=share&sid=share&wid=MLB3932889655&action=copy', ''), NULL, 25),
('cdf74d1f-f34d-5d1c-8779-fb4bec36689d'::uuid, 'Porta-temperos', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU4697678148?matt_tool=38524122&pdp_filters=item_id:MLB7390061522&ua=qy2XffjPu0fSbytYMN33OoMqWtjOc4aIRhyNs9z4a5h3cy8d#origin=share&sid=share&wid=MLB7390061522&action=copy', ''), NULL, 26),
('c3d21532-57d2-5e03-8782-10326bd31253'::uuid, 'Fruteira', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB75534293?matt_tool=38524122&pdp_filters=item_id:MLB4917733783&ua=z8JSOyldJ2RlUkKMDKzxE9TCH_6qhIxmaqVHAcvU8QX9UIAh#origin=share&sid=share&wid=MLB4917733783&action=copy', ''), NULL, 27),
('c4cd6dfe-8630-5326-bd70-83c79710488d'::uuid, 'Escorredor de louça', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB75732433?matt_tool=38524122&pdp_filters=item_id:MLB4942100423&ua=8RBxUieTqtvzuLNXhiafuxv_RLYrKIP6kX9b9dpF6ZRQwQWW#origin=share&sid=share&wid=MLB4942100423&action=copy', ''), NULL, 28),
('be067823-9fa6-5ce0-b0fe-9ea431d33b36'::uuid, 'Escorredores de cozinha', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU4152112296?matt_tool=38524122&pdp_filters=item_id:MLB7021272782&ua=R3ATg6R7Yin-pknksAnWTZKJAz6KzNMESYrItMHk45Z0N4Ok#origin=share&sid=share&wid=MLB7021272782&action=copy', ''), NULL, 29),
('eb061a0d-2173-572d-94da-62c305285a2b'::uuid, 'Organizador de pia', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU3237628602?matt_tool=38524122&pdp_filters=item_id:MLB5505763778&ua=eFFmRQRQ2rdxGa8NMbqyyDJ1w_HmL6ZfH45-7ZVzJD_Rz0gd#origin=share&sid=share&wid=MLB5505763778&action=copy', ''), NULL, 30),
('aa7c201e-7403-5ac4-b50a-128129b308df'::uuid, 'Jogo americano', 'Cozinha', NULLIF('https://produto.mercadolivre.com.br/MLB-3453984537?attributes=PATTERN_NAME:UHJldG8=&matt_tool=38524122&ua=KsnMR61_BBXzi-WBYUnRvJ3oubUiERhYdNb7–Mj8cs4sA45#origin=share&sid=share&action=copy', ''), NULL, 31),
('cbd2da50-aeda-5b5c-8924-3567504fd5cb'::uuid, 'Guardanapos', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/p/MLB63279379?matt_tool=38524122&pdp_filters=item_id:MLB4373286869&ua=WV0NxWClZ-3Hnnp9XM2lfS9EWMXHEBExR1mW0Umf9nDM49Oq#origin=share&sid=share&wid=MLB4373286869&action=copy', ''), NULL, 32),
('6a2f3f4c-c752-5619-9f08-8cb785bfb7d4'::uuid, 'Tapetes de cozinha', 'Cozinha', NULLIF('https://www.mercadolivre.com.br/up/MLBU3914816763?attributes=COLOR:MLBU3914816763&matt_tool=38524122&pdp_filters=item_id:MLB6666081114&ua=JAJfCwA72DJsXGNU7Bq66M8RDQcoZdsTKoQiQC3dlswP4gZy#origin=share&sid=share&wid=MLB6666081114&action=copy', ''), NULL, 33),
('c3d4b38d-f85b-5d46-b881-4959427221d0'::uuid, 'Almofadas para sofá', 'Sala', NULLIF('https://www.mercadolivre.com.br/p/MLB59631352?matt_tool=38524122&pdp_filters=item_id:MLB5784443708&ua=XwXNwu2eSC80q8iavJsmUNuv_HyIMZeUK7UmMgVaT4jyCJvb#origin=share&sid=share&wid=MLB5784443708&action=copy', ''), NULL, 34),
('14fb9b8c-82ab-54cf-a199-b83f08bcdc75'::uuid, 'Cortina', 'Sala', NULLIF('https://produto.mercadolivre.com.br/MLB-1920593249?attributes=COLOR_SECONDARY_COLOR:Q29ydGluYSBCcmFuY2E=&matt_tool=38524122&ua=PY2QBK9zKKlonYqUAUwE0HVcmKpCry4mYMzYZ2Ac_ajqPw4V#origin=share&sid=share&action=copy', ''), NULL, 35),
('e43c9b1b-e621-5042-84e7-eb2b91741106'::uuid, 'Tapete para sala', 'Sala', NULLIF('https://www.mercadolivre.com.br/up/MLBU3863943796?matt_tool=38524122&pdp_filters=item_id:MLB6582812744&ua=5FCM3mm5bAcnaZRsGAXzx_XhsOgVvsL9OdPTQ9WknqrwObIZ#origin=share&sid=share&wid=MLB6582812744&action=copy', ''), NULL, 36),
('77fda0ce-fc2a-5dc1-a8a9-c9f57d6053dd'::uuid, 'Ventilador de teto', 'Sala', NULLIF('https://www.mercadolivre.com.br/p/MLB35556218?matt_tool=38524122&pdp_filters=item_id:MLB2735052332&ua=Enfp9AoZRhSO4hvuG3fv4qbGsEvsYhtjb-lT_9FDvpOESSln#origin=share&sid=share&wid=MLB2735052332&action=copy', ''), NULL, 37),
('bb7458f3-c5c1-57df-9cf0-b629856ecbd6'::uuid, 'Ventilador de mesa', 'Sala', NULLIF('https://www.mercadolivre.com.br/p/MLB18932157?attributes=DIAMETER:MLB18932161,BLADES_MATERIAL:MLB18932161,STRUCTURE_COLOR-BLADES_COLOR:MLB18932157&matt_tool=38524122&pdp_filters=item_id:MLB4481885400&ua=hLRa6TnV9QefHFviGv56ObQ5vhDnKffviC3aWA3Z8ec42zxM#origin=share&sid=share&wid=MLB4481885400&action=copy', ''), NULL, 38),
('3ad0b937-b130-5fe1-85d4-28f9bb53ac0c'::uuid, 'Porta-chaves', 'Sala', NULLIF('https://www.mercadolivre.com.br/p/MLB69066055?matt_tool=38524122&pdp_filters=item_id:MLB4652483041&ua=NOU3xdvIA7umJ6fxHv0zJn9psqCFdPMwLOH-Peo8WToRTAbw#origin=share&sid=share&wid=MLB4652483041&action=copy', ''), NULL, 39),
('3a581645-37ad-587b-ab35-47e13eda8b08'::uuid, 'Protetor de colchão king impermeável', 'Quarto', NULLIF('https://produto.mercadolivre.com.br/MLB-6232908584?matt_tool=38524122&ua=Y2G31ZPfNU3-EaFuEM3VcoDUsv1p04bxzutmxYcQyd0jYozl#origin=share&sid=share&action=whatsapp', ''), NULL, 40),
('f186688d-c32f-57f9-bf78-27ad099214bd'::uuid, 'Kit de tapetes para banheiro', 'Banheiro', NULLIF('https://produto.mercadolivre.com.br/MLB-2747522301?matt_tool=38524122&ua=61_HondIPU7LWm3quwzC5Dk13V7syweFdM9Vxx1sc_lbehen#origin=share&sid=share&action=copy', ''), NULL, 41),
('3edf994a-f96d-5a26-a62b-fd45f2524d06'::uuid, 'Toalhas de banho e rosto', 'Banheiro', NULLIF('', ''), NULL, 42),
('b3275a2f-0b5e-5d1f-b1cb-81d1a3c127e9'::uuid, 'Mop spray', 'Limpeza e lavanderia', NULLIF('https://www.mercadolivre.com.br/up/MLBU5392768616?matt_tool=38524122&pdp_filters=item_id:MLB7746195682&ua=TtdvfewaOvnBlhAH1aRWxjxwwo0kWojYEsXjiBhhjz8LL9HA#origin=share&sid=share&wid=MLB7746195682&action=copy', ''), NULL, 43),
('c5a27bb9-298c-542d-85ab-b038e354911c'::uuid, 'Baldes', 'Limpeza e lavanderia', NULLIF('https://www.mercadolivre.com.br/p/MLB53604208?matt_tool=38524122&pdp_filters=item_id:MLB5553647542&ua=RN96FaKoEGpxRP2hAvokQI98-ZaRoeD5L-Dh_Gcwv17vrmNE#origin=share&sid=share&wid=MLB5553647542&action=copy', ''), NULL, 44),
('8f8d1f65-8902-50c1-97c4-c6c1b071cf07'::uuid, 'Panos de chão', 'Limpeza e lavanderia', NULLIF('https://produto.mercadolivre.com.br/MLB-3323138915?matt_tool=38524122&ua=UAz0i_nhghlB0Q9DE-LdVLZd1fgPm-Q_g_AvNDoaQ-c2jKvh#origin=share&sid=share&action=copy', ''), NULL, 45),
('86c3d1e3-1c69-580d-afd5-ceb179b608c2'::uuid, 'Aspirador de pó', 'Limpeza e lavanderia', NULLIF('https://www.mercadolivre.com.br/p/MLB15977316?matt_tool=38524122&pdp_filters=item_id:MLB3860624948&ua=jZmYebDZg53vmi5Q6JteXcW_U6AHCMx6E5hUmAvL8nUk9Pqv#origin=share&sid=share&wid=MLB3860624948&action=copy', ''), NULL, 46),
('2458f268-d084-54e9-be8d-625435e40723'::uuid, 'Ferro de passar roupa', 'Limpeza e lavanderia', NULLIF('', ''), NULL, 47),
('a36ce095-5645-56d2-90b5-f29645cc1aa2'::uuid, 'Tábua de passar roupa', 'Limpeza e lavanderia', NULLIF('', ''), NULL, 48)
on conflict (id) do update set
  name=excluded.name,
  category=excluded.category,
  purchase_url=excluded.purchase_url,
  price=excluded.price,
  sort_order=excluded.sort_order;

-- RLS: o público lê presentes e disponibilidade; gravações públicas passam pelas RPCs abaixo.
alter table public.gifts enable row level security;
alter table public.gift_reservations enable row level security;
alter table public.rsvps enable row level security;
alter table public.site_admins enable row level security;
drop policy if exists "public can read gifts" on public.gifts;
create policy "public can read gifts" on public.gifts for select to anon, authenticated using (true);
drop policy if exists "admins read reservations" on public.gift_reservations;
create policy "admins read reservations" on public.gift_reservations for select to authenticated using (exists(select 1 from public.site_admins a where a.user_id=auth.uid()));
drop policy if exists "admins read rsvps" on public.rsvps;
create policy "admins read rsvps" on public.rsvps for select to authenticated using (exists(select 1 from public.site_admins a where a.user_id=auth.uid()));
drop policy if exists "admins read site admins" on public.site_admins;
create policy "admins read site admins" on public.site_admins for select to authenticated using (user_id=auth.uid());

grant select on public.gifts to anon, authenticated;
grant select on public.gift_reservations to authenticated;
grant select on public.rsvps to authenticated;
grant select on public.site_admins to authenticated;

-- Remove apenas as funções antigas para permitir recriá-las caso o tipo de retorno tenha mudado.
-- Não apaga as tabelas nem as reservas existentes. Não use CASCADE.
drop function if exists public.reserve_gift(uuid, text);
drop function if exists public.cancel_gift_reservation(uuid, text);
drop function if exists public.submit_rsvp(text, boolean, integer);

create or replace function public.reserve_gift(p_gift_id uuid, p_guest_name text)
returns jsonb language plpgsql security definer set search_path=public,extensions as $$
declare v_reservation_id uuid; v_token text; v_name text;
begin
  v_name:=trim(coalesce(p_guest_name,''));
  if char_length(v_name)<2 or char_length(v_name)>100 then raise exception 'Informe um nome válido (de 2 a 100 caracteres).'; end if;
  if not exists(select 1 from public.gifts where id=p_gift_id) then raise exception 'Presente não encontrado.'; end if;
  if exists(select 1 from public.gift_reservations where gift_id=p_gift_id and cancelled_at is null) then raise exception 'Esse presente já foi reservado.'; end if;
  v_token:=encode(extensions.gen_random_bytes(32),'hex');
  insert into public.gift_reservations(gift_id,guest_name,cancellation_token_hash)
  values(p_gift_id,v_name,encode(extensions.digest(v_token,'sha256'),'hex')) returning id into v_reservation_id;
  return jsonb_build_object('reservation_id',v_reservation_id,'cancellation_token',v_token);
end; $$;

create or replace function public.cancel_gift_reservation(p_reservation_id uuid,p_cancellation_token text)
returns boolean language plpgsql security definer set search_path=public,extensions as $$
declare v_count integer;
begin
  update public.gift_reservations set cancelled_at=now(), cancelled_by_name=guest_name
  where id=p_reservation_id and cancelled_at is null
    and cancellation_token_hash=encode(extensions.digest(p_cancellation_token,'sha256'),'hex');
  get diagnostics v_count=row_count;
  return v_count=1;
end; $$;

create or replace function public.submit_rsvp(p_guest_name text,p_attending boolean,p_guest_count integer default 1)
returns uuid language plpgsql security definer set search_path=public as $$
declare v_id uuid; v_name text;
begin
  v_name:=trim(coalesce(p_guest_name,''));
  if char_length(v_name)<2 or char_length(v_name)>100 then raise exception 'Informe um nome válido.'; end if;
  if p_guest_count is null or p_guest_count<1 or p_guest_count>20 then raise exception 'Quantidade inválida.'; end if;
  insert into public.rsvps(guest_name,attending,guest_count) values(v_name,coalesce(p_attending,false),p_guest_count) returning id into v_id;
  return v_id;
end; $$;

revoke all on function public.reserve_gift(uuid,text) from public;
revoke all on function public.cancel_gift_reservation(uuid,text) from public;
revoke all on function public.submit_rsvp(text,boolean,integer) from public;
grant execute on function public.reserve_gift(uuid,text) to anon,authenticated;
grant execute on function public.cancel_gift_reservation(uuid,text) to anon,authenticated;
grant execute on function public.submit_rsvp(text,boolean,integer) to anon,authenticated;

-- Importante: após criar o usuário em Authentication > Users, copie o UUID e execute:
-- insert into public.site_admins(user_id) values ('COLE-AQUI-O-UUID-DO-USUARIO'::uuid);

-- Corrige os três nomes também nos registros que já existiam no banco.
update public.gifts set name = case
  when id = '86c3d1e3-1c69-580d-afd5-ceb179b608c2'::uuid then 'Aspirador de pó'
  when id = '2458f268-d084-54e9-be8d-625435e40723'::uuid then 'Ferro de passar roupa'
  when id = 'a36ce095-5645-56d2-90b5-f29645cc1aa2'::uuid then 'Tábua de passar roupa'
end
where id in (
  '86c3d1e3-1c69-580d-afd5-ceb179b608c2'::uuid,
  '2458f268-d084-54e9-be8d-625435e40723'::uuid,
  'a36ce095-5645-56d2-90b5-f29645cc1aa2'::uuid
);

select 'presentes cadastrados' as verificacao, count(*) as quantidade from public.gifts;
