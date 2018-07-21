package user

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"time"

	"github.com/pkg/errors"
	"golang.org/x/crypto/bcrypt"

	"github.com/micromdm/flow/server/id"
)

type APIUser struct {
	ID        string `json:"id"`
	Username  string `json:"username"`
	FullName  string `json:"full_name"`
	Email     string `json:"email"`
	CreatedAt int64  `json:"created_at"`
	UpdatedAt int64  `json:"updated_at"`
	Token     string `json:"token"`
}

type User struct {
	ID        string
	Username  string
	FullName  string
	Email     string
	Password  []byte
	Salt      string
	CreatedAt time.Time
	UpdatedAt time.Time
}

func (u *User) ValidatePassword(password string) error {
	saltAndPass := []byte(fmt.Sprintf("%s%s", password, u.Salt))
	return bcrypt.CompareHashAndPassword(u.Password, saltAndPass)
}

func (u *User) SetPassword(plaintext string) error {
	salt, err := generateRandomText(passwordKeySize)
	if err != nil {
		return err
	}

	withSalt := []byte(fmt.Sprintf("%s%s", plaintext, salt))
	hashed, err := bcrypt.GenerateFromPassword(withSalt, bcryptCost)
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
		UpdatedAt: time.Now().UTC(),
	}

	err := user.SetPassword(password)
	return user, errors.Wrapf(err, "set password for new user %s", username)
}
