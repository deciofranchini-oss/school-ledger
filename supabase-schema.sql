-- ================================================================
-- GERENCIAMENTO DE PAGAMENTOS — DÉCIO & BRUNA
-- Supabase / PostgreSQL — Schema + Seed Data completo
-- ================================================================
-- Como usar:
--   Supabase Dashboard → SQL Editor → New Query → colar tudo → Run
-- ================================================================


-- ── EXTENSÕES ────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";


-- ── DROP (para re-executar limpo se necessário) ──────────────────
drop table if exists transactions cascade;
drop table if exists parties     cascade;
drop table if exists config      cascade;
drop table if exists categories  cascade;


-- ================================================================
-- TABELAS
-- ================================================================

-- Categorias de pagamento
create table categories (
  key         text        primary key,
  label       text        not null,
  color       text        not null default '#8E8E93',
  is_system   boolean     not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Partes (beneficiários / responsáveis)
create table parties (
  id          serial      primary key,
  name        text        not null,
  emoji       text        not null default '👤',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Configurações gerais (acordo financeiro, etc.)
create table config (
  k           text        primary key,
  value       jsonb       not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

-- Transações (pagamentos, recebimentos, previsões)
create table transactions (
  id             serial      primary key,
  amount         numeric(12,2) not null,
  type           text        not null check (type in ('PAID','RECEIVED','FORECAST')),
  category_key   text        not null references categories(key) on update cascade,
  party_id       integer     references parties(id) on delete set null,
  party_legacy   text,                       -- 'Me' | 'Father' (dados históricos)
  date           date        not null,
  academic_year  integer     not null,
  academic_month integer     not null check (academic_month between 1 and 12),
  is_late        boolean     not null default false,
  student        text,                       -- 'Lara' | 'Chloe' | 'Ambas'
  notes          text,
  tags           text,
  file_name      text,                       -- nome do arquivo anexado
  file_type      text,                       -- mime type
  file_data      text,                       -- base64 (anexos)
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Índices de performance
create index idx_txs_year    on transactions(academic_year);
create index idx_txs_month   on transactions(academic_month);
create index idx_txs_type    on transactions(type);
create index idx_txs_date    on transactions(date);
create index idx_txs_cat     on transactions(category_key);
create index idx_txs_party   on transactions(party_id);


-- ================================================================
-- ROW LEVEL SECURITY
-- ================================================================
-- App single-user acessado via anon key → RLS desativado
alter table categories   disable row level security;
alter table parties      disable row level security;
alter table config       disable row level security;
alter table transactions disable row level security;

-- Permissões para anon key (GitHub Pages)
grant usage  on schema public to anon;
grant all on categories              to anon;
grant all on parties                 to anon;
grant all on config                  to anon;
grant all on transactions            to anon;
grant usage, select on sequence parties_id_seq      to anon;
grant usage, select on sequence transactions_id_seq to anon;


-- ================================================================
-- TRIGGER: updated_at automático
-- ================================================================
create or replace function _set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger trg_categories_upd   before update on categories
  for each row execute function _set_updated_at();
create trigger trg_parties_upd      before update on parties
  for each row execute function _set_updated_at();
create trigger trg_config_upd       before update on config
  for each row execute function _set_updated_at();
create trigger trg_transactions_upd before update on transactions
  for each row execute function _set_updated_at();


-- ================================================================
-- SEED DATA
-- ================================================================

-- ── Categorias ──────────────────────────────────────────────────
insert into categories (key, label, color, is_system) values
  ('mensalidade', 'Mensalidade',         '#3B5BDB', true),
  ('pensao',      'Pensão Alimentícia',  '#C0392B', true),
  ('matricula',   'Matrícula',           '#C05C1A', true),
  ('material',    'Material',            '#1A7F7A', true),
  ('uniforme',    'Uniforme',            '#6B4FBB', true),
  ('extra',       'Extra',               '#2E7D55', true);

-- ── Configuração do acordo financeiro ───────────────────────────
insert into config (k, value) values
  ('accord', '{"type":"pct","pct":50,"val":0}');

-- ── Partes ───────────────────────────────────────────────────────
insert into parties (id, name, emoji) values
  (1, 'Décio e Bruna', '👨‍👩‍👧'),
  (2, 'Pai',           '👨');
-- Sincronizar sequência
select setval('parties_id_seq', 2);


-- ================================================================
-- TRANSAÇÕES 2025
-- ================================================================

-- Mensalidades 2025 (12 meses — Décio e Bruna)
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (4998.41,'PAID','mensalidade',1,'2025-01-05',2025,1, false,'Ambas','Mensalidade Janeiro/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-02-05',2025,2, false,'Ambas','Mensalidade Fevereiro/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-03-05',2025,3, false,'Ambas','Mensalidade Março/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-04-05',2025,4, false,'Ambas','Mensalidade Abril/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-05-05',2025,5, false,'Ambas','Mensalidade Maio/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-06-05',2025,6, false,'Ambas','Mensalidade Junho/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-07-05',2025,7, false,'Ambas','Mensalidade Julho/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-08-05',2025,8, false,'Ambas','Mensalidade Agosto/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-09-05',2025,9, false,'Ambas','Mensalidade Setembro/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-10-05',2025,10,false,'Ambas','Mensalidade Outubro/2025','mensalidade'),
  (4998.41,'PAID','mensalidade',1,'2025-11-05',2025,11,false,'Ambas','Mensalidade Novembro/2025','mensalidade'),
  (4998.40,'PAID','mensalidade',1,'2025-12-05',2025,12,false,'Ambas','Mensalidade Dezembro/2025','mensalidade');

-- Matrícula 2025
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (4256.88,'PAID','matricula',1,'2025-01-05',2025,1,false,'Ambas','Matrícula anual 2025','matricula');

-- Material 2025
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (724.50,'PAID','material',1,'2025-01-05',2025,1,false,'Ambas','Material Janeiro/2025','material'),
  (724.50,'PAID','material',1,'2025-04-05',2025,4,false,'Ambas','Material Abril/2025','material'),
  (724.50,'PAID','material',1,'2025-07-05',2025,7,false,'Ambas','Material Julho/2025','material'),
  (724.50,'PAID','material',1,'2025-09-05',2025,9,false,'Ambas','Material Setembro/2025','material');

-- Extra 2025
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (1084.23,'PAID','extra',1,'2025-01-05',2025,1,false,'Ambas','Extra Jan/2025','extra');

-- Pensão Alimentícia 2025 (recebida do Pai)
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (2000.00,'RECEIVED','pensao',2,'2025-01-05',2025,1, false,'Ambas','Pensão Janeiro/2025','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-02-05',2025,2, false,'Ambas','Pensão Fevereiro/2025','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-03-05',2025,3, false,'Ambas','Pensão Março/2025','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-04-05',2025,4, false,'Ambas','Pensão Abril/2025','pensao'),
  (1000.00,'RECEIVED','pensao',2,'2025-05-06',2025,5, true, 'Ambas','Pensão Maio/2025 — com atraso','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-06-05',2025,6, false,'Ambas','Pensão Junho/2025','pensao'),
  (1000.00,'RECEIVED','pensao',2,'2025-07-03',2025,7, false,'Ambas','Pensão Julho/2025 — parcela 1','pensao'),
  (1000.00,'RECEIVED','pensao',2,'2025-07-17',2025,7, true, 'Ambas','Pensão Julho/2025 — parcela 2 atraso','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-08-05',2025,8, false,'Ambas','Pensão Agosto/2025','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-09-05',2025,9, false,'Ambas','Pensão Setembro/2025','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-10-04',2025,10,false,'Ambas','Pensão Outubro/2025','pensao'),
  (2000.00,'RECEIVED','pensao',2,'2025-11-05',2025,11,false,'Ambas','Pensão Novembro/2025','pensao'),
  (1500.00,'RECEIVED','pensao',2,'2025-11-22',2025,11,true, 'Ambas','Pensão Nov/2025 — complemento atraso','pensao'),
  (3500.00,'RECEIVED','pensao',2,'2025-12-05',2025,12,false,'Ambas','Pensão Dezembro/2025','pensao');


-- ================================================================
-- TRANSAÇÕES 2026
-- ================================================================

-- Mensalidades 2026 (jan-mar confirmadas)
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (5666.85,'PAID','mensalidade',1,'2026-01-05',2026,1,false,'Ambas','Mensalidade Janeiro/2026','mensalidade'),
  (5666.85,'PAID','mensalidade',1,'2026-02-05',2026,2,false,'Ambas','Mensalidade Fevereiro/2026','mensalidade'),
  (2778.76,'PAID','mensalidade',1,'2026-02-27',2026,3,false,'Lara', 'Mensalidade Março/2026 — Lara','mensalidade');

-- Matrícula + Material + Extra 2026
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (1491.29,'PAID','matricula',1,'2026-01-05',2026,1,false,'Ambas','Matrícula 2026','matricula'),
  (1047.33,'PAID','material', 1,'2026-01-05',2026,1,false,'Ambas','Material Jan/2026','material'),
  (1503.41,'PAID','extra',    1,'2026-02-05',2026,2,false,'Ambas','Excursão — parcela 1','extra,excursao');

-- Pensão 2026 (jan-fev recebidas com atraso)
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (2000.00,'RECEIVED','pensao',2,'2026-01-12',2026,1,true,'Ambas','Pensão Jan/2026 — com atraso','pensao'),
  (2500.00,'RECEIVED','pensao',2,'2026-02-07',2026,2,true,'Ambas','Pensão Fev/2026 — com atraso','pensao');

-- PREVISÕES 2026: Mensalidades Abr–Dez
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (5666.85,'FORECAST','mensalidade',1,'2026-04-05',2026,4, false,'Ambas','Mensalidade Abril/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-05-05',2026,5, false,'Ambas','Mensalidade Maio/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-06-05',2026,6, false,'Ambas','Mensalidade Junho/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-07-05',2026,7, false,'Ambas','Mensalidade Julho/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-08-05',2026,8, false,'Ambas','Mensalidade Agosto/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-09-05',2026,9, false,'Ambas','Mensalidade Setembro/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-10-05',2026,10,false,'Ambas','Mensalidade Outubro/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-11-05',2026,11,false,'Ambas','Mensalidade Novembro/2026 (previsão)','mensalidade,forecast'),
  (5666.85,'FORECAST','mensalidade',1,'2026-12-05',2026,12,false,'Ambas','Mensalidade Dezembro/2026 (previsão)','mensalidade,forecast');

-- PREVISÕES 2026: Pensão Mar–Dez
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (2000.00,'FORECAST','pensao',2,'2026-03-10',2026,3, false,'Ambas','Pensão Março/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-04-10',2026,4, false,'Ambas','Pensão Abril/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-05-10',2026,5, false,'Ambas','Pensão Maio/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-06-10',2026,6, false,'Ambas','Pensão Junho/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-07-10',2026,7, false,'Ambas','Pensão Julho/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-08-10',2026,8, false,'Ambas','Pensão Agosto/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-09-10',2026,9, false,'Ambas','Pensão Setembro/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-10-10',2026,10,false,'Ambas','Pensão Outubro/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-11-10',2026,11,false,'Ambas','Pensão Novembro/2026 (previsão)','pensao,forecast'),
  (2000.00,'FORECAST','pensao',2,'2026-12-10',2026,12,false,'Ambas','Pensão Dezembro/2026 (previsão)','pensao,forecast');

-- PREVISÕES 2026: Excursão Mar–Ago
insert into transactions
  (amount,type,category_key,party_id,date,academic_year,academic_month,is_late,student,notes,tags)
values
  (429.00,'FORECAST','extra',1,'2026-03-05',2026,3,false,'Ambas','Excursão Março/2026 (previsão)','extra,excursao,forecast'),
  (429.00,'FORECAST','extra',1,'2026-04-05',2026,4,false,'Ambas','Excursão Abril/2026 (previsão)','extra,excursao,forecast'),
  (429.00,'FORECAST','extra',1,'2026-05-05',2026,5,false,'Ambas','Excursão Maio/2026 (previsão)','extra,excursao,forecast'),
  (429.00,'FORECAST','extra',1,'2026-06-05',2026,6,false,'Ambas','Excursão Junho/2026 (previsão)','extra,excursao,forecast'),
  (429.00,'FORECAST','extra',1,'2026-07-05',2026,7,false,'Ambas','Excursão Julho/2026 (previsão)','extra,excursao,forecast'),
  (429.00,'FORECAST','extra',1,'2026-08-05',2026,8,false,'Ambas','Excursão Agosto/2026 (previsão)','extra,excursao,forecast');


-- ================================================================
-- VERIFICAÇÃO FINAL
-- ================================================================
select
  (select count(*) from categories)                      as categorias,
  (select count(*) from parties)                         as partes,
  (select count(*) from config)                          as configs,
  (select count(*) from transactions)                    as total_txs,
  (select count(*) from transactions where type='PAID')      as pagas,
  (select count(*) from transactions where type='RECEIVED')  as recebidas,
  (select count(*) from transactions where type='FORECAST')  as previsoes;
