-- Initialize database schema for TP
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO items (name) VALUES ('Item A') ON CONFLICT DO NOTHING;
INSERT INTO items (name) VALUES ('Item B') ON CONFLICT DO NOTHING;
