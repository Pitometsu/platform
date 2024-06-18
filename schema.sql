CREATE TABLE IF NOT EXISTS users
  ( id UUID DEFAULT gen_random_uuid() PRIMARY KEY
  , username varchar(500) UNIQUE NOT NULL );

CREATE TABLE IF NOT EXISTS currency
  ( id UUID DEFAULT gen_random_uuid() PRIMARY KEY
  , name varchar(5) UNIQUE NOT NULL
  , denomination int NOT NULL );

CREATE TABLE IF NOT EXISTS users_currency
  ( users_id UUID REFERENCES users (id) ON UPDATE CASCADE
  , currency_id UUID REFERENCES currency (id) ON UPDATE CASCADE
  , amount bigint NOT NULL -- Denormalization
  , CONSTRAINT users_currency_pkey PRIMARY KEY (users_id, currency_id) );

DROP TYPE IF EXISTS operations CASCADE;
CREATE TYPE operations AS enum ('debit', 'credit');

CREATE TABLE IF NOT EXISTS tx
  ( id UUID DEFAULT gen_random_uuid() PRIMARY KEY
  , users_id UUID REFERENCES users (id) ON UPDATE CASCADE
  , currency_id UUID REFERENCES currency (id) ON UPDATE CASCADE
  , kind operations NOT NULL
  , amount bigint CHECK (amount >= 0) NOT NULL );
