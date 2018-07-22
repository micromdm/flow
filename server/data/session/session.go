package session

import (
	"time"
)

type Session struct {
	ID         string
	UserID     string
	Token      []byte
	CreatedAt  time.Time `db:"created_at"`
	AccessedAt time.Time `db:"accessed_at"`
}
