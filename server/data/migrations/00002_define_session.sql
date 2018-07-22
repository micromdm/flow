-- +goose Up
-- SQL in this section is executed when the migration is applied.
CREATE TABLE IF NOT EXISTS session (
    id text PRIMARY KEY NOT NULL,
    user_id text REFERENCES users(id),
    token text NOT NULL DEFAULT '',
    created_at timestamp without time zone default (now() at time zone 'utc'),
    accessed_at timestamp without time zone default (now() at time zone 'utc')
);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
DROP TABLE IF EXISTS session;
