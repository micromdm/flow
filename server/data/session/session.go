package session

import (
	"time"
)

type Session struct {
	ID         string
	UserID     string
	Token      []byte
	CreatedAt  time.Time
	AccessedAt time.Time
}
