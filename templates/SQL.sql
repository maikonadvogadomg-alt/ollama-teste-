-- ASSISTENTE JURÍDICO — SQLite Local
-- Sem dependência de nuvem
-- Sem cobranças abusivas

-- Usuários
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

-- Configurações
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Snippets (Playground)
CREATE TABLE IF NOT EXISTS snippets (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL DEFAULT 'Untitled',
  html TEXT NOT NULL DEFAULT '',
  css TEXT NOT NULL DEFAULT '',
  js TEXT NOT NULL DEFAULT '',
  mode TEXT NOT NULL DEFAULT 'html'
);

-- Ementas Jurídicas
CREATE TABLE IF NOT EXISTS ementas (
  id TEXT PRIMARY KEY,
  titulo TEXT NOT NULL,
  categoria TEXT NOT NULL DEFAULT 'Geral',
  texto TEXT NOT NULL
);

-- Templates de Prompt
CREATE TABLE IF NOT EXISTS prompt_templates (
  id TEXT PRIMARY KEY,
  titulo TEXT NOT NULL,
  categoria TEXT NOT NULL DEFAULT 'Geral',
  texto TEXT NOT NULL
);

-- Templates de Documento
CREATE TABLE IF NOT EXISTS doc_templates (
  id TEXT PRIMARY KEY,
  titulo TEXT NOT NULL,
  categoria TEXT NOT NULL DEFAULT 'Geral',
  conteudo TEXT NOT NULL,
  docx_base64 TEXT,
  docx_filename TEXT
);

-- HISTÓRICO DE IA (AUDITORIA!) ⭐
CREATE TABLE IF NOT EXISTS ai_history (
  id TEXT PRIMARY KEY,
  action TEXT NOT NULL,
  input_preview TEXT NOT NULL DEFAULT '',
  result TEXT NOT NULL,
  model TEXT DEFAULT '',
  provider TEXT DEFAULT '',
  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,
  estimated_cost REAL DEFAULT 0,
  chat_history TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Processos Monitorados
CREATE TABLE IF NOT EXISTS processos_monitorados (
  id TEXT PRIMARY KEY,
  numero TEXT NOT NULL,
  tribunal TEXT NOT NULL,
  apelido TEXT NOT NULL DEFAULT '',
  classe TEXT NOT NULL DEFAULT '',
  orgao_julgador TEXT NOT NULL DEFAULT '',
  data_ajuizamento TEXT NOT NULL DEFAULT '',
  ultima_movimentacao TEXT NOT NULL DEFAULT '',
  ultima_movimentacao_data TEXT NOT NULL DEFAULT '',
  assuntos TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'ativo',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Conversas (Chat)
CREATE TABLE IF NOT EXISTS conversations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL DEFAULT 'Nova Conversa',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Mensagens (Chat)
CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  conversation_id INTEGER NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(conversation_id) REFERENCES conversations(id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_ai_history_created_at 
  ON ai_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_processos_numero 
  ON processos_monitorados(numero);
CREATE INDEX IF NOT EXISTS idx_messages_conversation 
  ON messages(conversation_id);
