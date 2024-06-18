INSERT INTO currency (name, denomination) VALUES
('USD', 2),
('EUR', 2)
ON CONFLICT (name)
DO UPDATE SET
  denomination = EXCLUDED.denomination;

INSERT INTO users (username) VALUES
('testuser')
ON CONFLICT (username)
DO NOTHING;
