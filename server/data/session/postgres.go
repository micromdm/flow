package session

import (
	"context"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/pkg/errors"
	sq "gopkg.in/Masterminds/squirrel.v1"

	"github.com/micromdm/flow/server/id"
)

type Postgres struct {
	db *sqlx.DB
}

func NewPostgres(db *sqlx.DB) *Postgres {
	return &Postgres{db: db}
}

func (d *Postgres) CreateSession(ctx context.Context, token []byte, userID string) (*Session, error) {
	session := &Session{
		ID:         id.New(),
		Token:      token,
		UserID:     userID,
		CreatedAt:  time.Now().UTC(),
		AccessedAt: time.Now().UTC(),
	}

	query, args, err := sq.StatementBuilder.PlaceholderFormat(sq.Dollar).
		Insert("session").
		Columns(
			"id",
			"user_id",
			"token",
			"created_at",
			"accessed_at",
		).
		Values(
			session.ID,
			session.UserID,
			session.Token,
			session.CreatedAt,
			session.AccessedAt,
		).ToSql()

	if err != nil {
		return nil, errors.Wrapf(err, "building pg sql statement for create session %s", userID)
	}

	_, err = d.db.Exec(query, args...)
	return session, errors.Wrapf(err, "creating session in postgres %s", userID)
}
