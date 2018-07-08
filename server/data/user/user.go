package user

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"time"

	"github.com/micromdm/flow/server/id"
	"github.com/pkg/errors"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID        string
	Username  string
	FullName  string
	Email     string
	Password  []byte
	Salt      string
	CreatedAt time.Time
}

func (u *User) ValidatePassword(password string) error {
	saltAndPass := []byte(fmt.Sprintf("%s%s", password, u.Salt))
	return bcrypt.CompareHashAndPassword(u.Password, saltAndPass)
}

func (u *User) SetPassword(plaintext string, keySize, cost int) error {
	salt, err := generateRandomText(keySize)
	if err != nil {
		return err
	}

	withSalt := []byte(fmt.Sprintf("%s%s", plaintext, salt))
	hashed, err := bcrypt.GenerateFromPassword(withSalt, cost)
	if err != nil {
		return err
	}

	u.Salt = salt
	u.Password = hashed
	return nil
}

const (
	passwordKeySize = 27
	bcryptCost      = 10
)

func generateRandomText(keySize int) (string, error) {
	key := make([]byte, keySize)
	_, err := rand.Read(key)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(key), nil
}

func newUser(username, fullname, email, password string) (*User, error) {
	user := &User{
		ID:        id.New(),
		Username:  username,
		FullName:  fullname,
		Email:     email,
		CreatedAt: time.Now().UTC(),
	}

	err := user.SetPassword(password, passwordKeySize, bcryptCost)
	return user, errors.Wrapf(err, "set password for new user %s", username)
}
