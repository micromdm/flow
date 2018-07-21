-- +goose Up
-- SQL in this section is executed when the migration is applied.
CREATE TABLE IF NOT EXISTS users (
    id text PRIMARY KEY NOT NULL,
    username text NOT NULL DEFAULT '',
    fullname text NOT NULL DEFAULT '',
    email text NOT NULL DEFAULT '',
    password text NOT NULL DEFAULT '',
    salt text NOT NULL DEFAULT '',
    created_at timestamp without time zone default (now() at time zone 'utc'),
    updated_at timestamp without time zone default (now() at time zone 'utc')
);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
DROP TABLE IF EXISTS users;