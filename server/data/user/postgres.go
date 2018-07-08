package user

import (
	"context"

	"github.com/jmoiron/sqlx"
	"github.com/pkg/errors"
	sq "gopkg.in/Masterminds/squirrel.v1"
)

type Postgres struct {
	db *sqlx.DB
}

func NewPostgres(db *sqlx.DB) *Postgres {
	return &Postgres{db: db}
}

func (d *Postgres) Create(ctx context.Context, username, fullname, email, password string) (*User, error) {
	user, err := newUser(username, fullname, email, password)
	if err != nil {
		return nil, errors.Wrap(err, "create user for pg")
	}

	query, args, err := sq.StatementBuilder.PlaceholderFormat(sq.Dollar).
		Insert("users").
		Columns(
			"id",
			"username",
			"fullname",
			"email",
			"password",
			"salt",
			"created_at",
		).
		Values(
			user.ID,
			user.Username,
			user.FullName,
			user.Email,
			user.Password,
			user.Salt,
			user.CreatedAt,
		).ToSql()

	if err != nil {
		return nil, errors.Wrapf(err, "building pg sql statement for create user %s", username)
	}

	_, err = d.db.Exec(query, args...)
	return user, errors.Wrapf(err, "creating user in postgres %s", username)
}
