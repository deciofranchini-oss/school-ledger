# CHANGELOG — School Ledger (Refactor + Forecast + IA Offline)

## Adicionado
- **Forecast / Previsões**
  - Campo booleano `isForecast` nas transações (pagamentos futuros).
  - KPI de **Previsão** no dashboard e total separado do **Total Pago**.
  - Gráfico exclusivo **Forecast por mês** (distribuição anual).
  - Badges visuais `previsão` na lista de transações.
- **Relatórios**
  - Coluna **Data de Pagamento (Pai)** no relatório (derivada de transações de pensão do mês).
  - Indicador **“Pago fora do prazo”** aparece **ao lado da data** (não mais no percentual).
  - Coluna **Total Previsão** no relatório e total anual de previsões.
  - Regras:
    - Ano específico: sempre exibe **12 meses** (mesmo sem registros).
    - “Todos”: exibe **apenas anos existentes** na base (sem anos vazios).
- **Campo dinâmico “Parte”**
  - Store persistente `parties` (IndexedDB).
  - Dropdown de Parte com opção **“+ Adicionar nova…”** (cria e persiste automaticamente).
  - Gestão completa (criar/editar/excluir) no painel **Configurações**.
- **IA gratuita (offline) baseada em projetos open-source do GitHub**
  - Novo `AI Service` com extração de texto:
    - **pdf.js** (PDF)
    - **tesseract.js** (OCR de imagens)
  - Parser heurístico para sugerir: valor, data, categoria, tipo, parte e atraso.
  - Camada de abstração para trocar a estratégia de “IA” no futuro sem reescrever UI.

## Modificado
- **Persistência**
  - IndexedDB atualizado para **v3** adicionando object store `parties`.
  - Ajuste de seed: popula categorias e partes padrão, mantendo compatibilidade de dados.
- **Dashboard**
  - Totais e gráficos agora separam:
    - **Pago (efetivo)**: `type=PAID && isForecast=false`
    - **Previsão**: `isForecast=true`
- **Exportações**
  - CSV agora inclui `isForecast`.
  - Excel exportado como `.xls` (HTML compatível com Excel/Numbers).
  - PDF via “Imprimir / Salvar PDF” (print dialog).

## Removido
- Dependência de token/chave paga para IA (não há mais campo/fluxo de API key na UI).
- Lógica antiga do relatório que:
  - Escondia meses sem registros.
  - Criava “anos vazios” ao selecionar “Todos”.
  - Colocava atraso no campo de percentual.

## Refatorado
- Código monolítico do `index.html` foi quebrado em módulos ES6 (GitHub Pages friendly):
  - `app/main.js` (controller + rendering + handlers)
  - `app/db.js` (IndexedDB wrapper)
  - `app/seed.js` (seed inicial)
  - `app/state.js`, `app/utils.js`
  - `app/reporting.js` (reporting engine)
  - `app/settings.js` (config UI, incluindo Partes)
  - `app/aiService.js` (IA offline)
  - `app/charts.js` (gráficos)
- Service Worker atualizado para cachear os novos arquivos.

## Impacto na Base de Dados
- **Transações (`txs`)**
  - **Novo campo**: `isForecast: boolean`
  - Regras de cálculo:
    - Totais pagos excluem previsões (`isForecast=false`).
- **Novo store**: `parties`
  - Estrutura: `{ key, label, system }`

## Impacto na Persistência
- IndexedDB version bump para **3**.
- Migração automática: `parties` é criado no upgrade; seed garante partes padrão.

## Impacto na UI
- Dashboard: novo KPI “Previsão” + novo gráfico.
- Transações: badge “previsão”.
- Relatório: colunas novas (Data Pagamento Pai + Total Previsão) e regra de meses/anos.
- Configurações: nova seção “Partes” com CRUD.

## Impacto na IA
- IA agora roda **localmente**, sem chave.
- Arquitetura em camadas permite trocar heurística por outro motor no futuro.
