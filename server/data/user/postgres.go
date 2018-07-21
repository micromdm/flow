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

func (d *Postgres) CreateUser(ctx context.Context, username, fullname, email, password string) (*User, error) {
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
			"updated_at",
		).
		Values(
			user.ID,
			user.Username,
			user.FullName,
			user.Email,
			string(user.Password),
			user.Salt,
			user.CreatedAt,
			user.UpdatedAt,
		).ToSql()

	if err != nil {
		return nil, errors.Wrapf(err, "building pg sql statement for create user %s", username)
	}

	_, err = d.db.Exec(query, args...)
	return user, errors.Wrapf(err, "creating user in postgres %s", username)
}

func (d *Postgres) FindUser(ctx context.Context, id, email string) (*User, error) {
	var eq sq.Eq
	switch {
	case id != "":
		eq = sq.Eq{"id": id}
	case email != "":
		eq = sq.Eq{"email": email}
	default:
		return nil, errors.New("id or email must be specified to find user")
	}

	query, args, err := sq.StatementBuilder.PlaceholderFormat(sq.Dollar).
		Select("*").From("users").Where(eq).Limit(1).ToSql()

	if err != nil {
		return nil, errors.Wrap(err, "building sql to find user")
	}

	var user User
	err = d.db.QueryRowx(query, args...).StructScan(&user)
	return &user, errors.Wrap(err, "finding user")
}
