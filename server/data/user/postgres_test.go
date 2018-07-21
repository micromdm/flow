package user

import (
	"context"
	"fmt"
	"testing"

	"github.com/jmoiron/sqlx"

	_ "github.com/lib/pq"
)

func TestCreateUser(t *testing.T) {
	db, teardown := setup(t)
	defer teardown()

	ctx := context.Background()
	user, err := db.CreateUser(ctx, "groob", "victor vrantchan", "victor@acme.co", "abcd123")
	if err != nil {
		t.Fatal(err)
	}
	fmt.Println(user.ValidatePassword("abcd123"))

}

func setup(t *testing.T) (*Postgres, func()) {
	t.Helper()

	db, err := sqlx.Open("postgres", "host=localhost port=5432 user=flow dbname=flow password=work sslmode=disable")
	if err != nil {
		t.Fatal(t, err)
	}

	_, err = db.Exec("select 1")
	if err != nil {
		t.Fatal(err)
	}

	return NewPostgres(db), func() {
		if err := db.Close(); err != nil {
			t.Fatal()
		}
	}
}
