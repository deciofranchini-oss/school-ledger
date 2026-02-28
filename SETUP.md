# Gerenciamento de Pagamentos — Décio & Bruna
## Guia de Configuração: Supabase + GitHub Pages

---

## VISÃO GERAL DA ARQUITETURA

```
[iPhone / Android / Desktop]
         │
         ▼
  GitHub Pages (index.html)        ← frontend estático, gratuito
         │
         ▼ HTTPS / REST API
  Supabase (PostgreSQL)             ← banco de dados na nuvem, gratuito
         │
    ┌────┴────────────────┐
    │  transactions       │
    │  categories         │
    │  parties            │
    │  config             │
    └─────────────────────┘

Arquivos anexados → IndexedDB local do browser (por dispositivo)
```

---

## PASSO 1 — CRIAR PROJETO SUPABASE

1. Acesse **https://supabase.com** e clique em **Start your project**
2. Faça login com GitHub ou Google
3. Clique em **New project**
4. Preencha:
   - **Name:** `pagamentos-decio-bruna`
   - **Database Password:** crie uma senha forte e **anote-a**
   - **Region:** `South America (São Paulo)` ← menor latência no Brasil
5. Clique em **Create new project** e aguarde ~2 minutos

---

## PASSO 2 — EXECUTAR O SQL (criar tabelas + dados)

1. No painel Supabase, clique em **SQL Editor** (ícone `</>` na barra lateral)
2. Clique em **+ New query**
3. Abra o arquivo `supabase-schema.sql` deste pacote
4. Copie TODO o conteúdo e cole no editor
5. Clique em **Run** (▶️) ou pressione `Ctrl+Enter`
6. Verifique o resultado ao final — deve aparecer algo como:
   ```
   categorias | partes | configs | total_txs | pagas | recebidas | previsoes
   6          | 2      | 1       | 74        | 27    | 16        | 31
   ```
7. Se aparecer erro, clique em **Reset** e tente novamente

---

## PASSO 3 — OBTER AS CREDENCIAIS

1. No painel Supabase, clique em **Settings** (engrenagem ⚙️)
2. Clique em **API** no menu lateral
3. Copie e anote dois valores:
   - **Project URL** → ex: `https://abcdefghijk.supabase.co`
   - **anon / public** (em "Project API Keys") → chave JWT longa

> ⚠️ Use SEMPRE a chave **anon** (pública). NUNCA exponha a chave `service_role`.

---

## PASSO 4 — PUBLICAR NO GITHUB

### 4a. Criar repositório

1. Acesse **https://github.com** e faça login
2. Clique em **+** → **New repository**
3. Configure:
   - **Repository name:** `pagamentos-decio-bruna` (ou qualquer nome)
   - **Visibility:** `Private` ✅ (recomendado — dados pessoais)
   - NÃO marque "Initialize with README"
4. Clique em **Create repository**

### 4b. Fazer upload dos arquivos

**Opção A — via interface GitHub (mais simples):**

1. Na página do repositório vazio, clique em **uploading an existing file**
2. Arraste os seguintes arquivos:
   - `index.html`
   - `manifest.json`
   - `sw.js`
   - `icon-192.png`
   - `icon-512.png`
   - `icon.svg`
3. Adicione uma mensagem de commit: `Initial release v6 — Supabase`
4. Clique em **Commit changes**

**Opção B — via Git CLI:**
```bash
cd pagamentos-decio-bruna/
git init
git add index.html manifest.json sw.js icon-192.png icon-512.png icon.svg
git commit -m "Initial release v6 — Supabase"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/pagamentos-decio-bruna.git
git push -u origin main
```

### 4c. Ativar GitHub Pages

1. No repositório, clique em **Settings** (aba superior)
2. No menu lateral, clique em **Pages**
3. Em **Source**, selecione:
   - Branch: `main`
   - Folder: `/ (root)`
4. Clique em **Save**
5. Aguarde ~1 minuto. A URL aparecerá:
   ```
   https://SEU_USUARIO.github.io/pagamentos-decio-bruna/
   ```

---

## PASSO 5 — PRIMEIRA ABERTURA DO APP

1. Abra a URL do GitHub Pages no browser
2. Aparecerá a tela **"Conectar ao Supabase"**
3. Preencha:
   - **PROJECT URL:** cole a URL copiada no Passo 3
   - **ANON PUBLIC KEY:** cole a chave anon copiada no Passo 3
4. Clique em **Conectar →**
5. O app conectará, validará e abrirá normalmente com os dados do Supabase

> ✅ As credenciais ficam salvas no `localStorage` do browser.  
> Na próxima abertura o app conectará automaticamente.

---

## PASSO 6 — INSTALAR COMO APP (PWA)

### iPhone / iPad (Safari):
1. Abra a URL no Safari
2. Toque em **Compartilhar** (ícone de seta para cima)
3. Role e toque em **"Adicionar à Tela de Início"**
4. Toque em **Adicionar**

### Android (Chrome):
1. Abra a URL no Chrome
2. Toque no menu ⋮ → **"Adicionar à tela inicial"**

### Desktop (Chrome / Edge):
1. Clique no ícone 📲 na barra de endereços
2. Clique em **Instalar**

---

## USANDO EM MÚLTIPLOS DISPOSITIVOS

1. Abra a URL do GitHub Pages em qualquer dispositivo
2. Informe as mesmas credenciais do Supabase
3. Todos os dispositivos compartilham o mesmo banco de dados em tempo real

---

## SEGURANÇA

| Item | Detalhe |
|------|---------|
| **PIN de acesso** | `191291` — altere em `LOCK_PIN` no `index.html` |
| **Repositório privado** | Não expõe código ao público |
| **Anon key** | Permite operações CRUD sem autenticação (single-user, seguro para uso pessoal privado) |
| **RLS desativado** | Adequado para app de uso familiar único. Para múltiplos usuários, ative RLS no Supabase |
| **Arquivos anexados** | Ficam APENAS no dispositivo local (IndexedDB) — não sincronizam entre dispositivos |

---

## ATUALIZAÇÕES FUTURAS

Para atualizar o app após mudanças no `index.html`:

**Via GitHub (interface):**
1. Abra o arquivo `index.html` no GitHub
2. Clique no lápis ✏️ (editar)
3. Substitua o conteúdo, faça commit
4. GitHub Pages publica automaticamente em ~1 min

**Via Git CLI:**
```bash
git add index.html
git commit -m "Update: descrição da mudança"
git push
```

---

## BACKUP DOS DADOS

No app, vá em **Configurações → Backup → Exportar JSON**.  
O backup inclui todas as transações, categorias e configurações do Supabase.

Para restaurar: **Configurações → Backup → Importar JSON**.

---

## TROUBLESHOOTING

| Problema | Solução |
|----------|---------|
| "Falha na conexão" | Verifique URL (deve terminar em `.supabase.co`) e anon key |
| Dados não aparecem | Confirme que o SQL foi executado com sucesso (Passo 2) |
| App não abre após update | Force-refresh: `Ctrl+Shift+R` (desktop) ou limpe cache do Safari |
| Tela branca | Abra DevTools (F12) → Console e reporte o erro |
| PIN não funciona | O PIN é `191291` — altere `LOCK_PIN` no código se necessário |
| Credenciais salvas não funcionam | Toque em "Desconectar Supabase" em Configurações e re-insira |

---

## ESTRUTURA DE ARQUIVOS

```
pagamentos-decio-bruna/
├── index.html          ← App completo (PWA single-file)
├── manifest.json       ← Configuração PWA (nome, ícones, cores)
├── sw.js               ← Service Worker (cache offline)
├── icon-192.png        ← Ícone 192×192
├── icon-512.png        ← Ícone 512×512
├── icon.svg            ← Ícone vetorial
└── supabase-schema.sql ← SQL para criar banco (execute no Supabase)
```

---

*App v6.0 — Supabase + GitHub Pages | Fevereiro 2026*
