package session

import (
	"context"

	"github.com/go-kit/kit/log"

	"github.com/micromdm/flow/server/data/session"
	"github.com/micromdm/flow/server/data/user"
)

type Service interface {
	Login(ctx context.Context, email, password string) (*user.APIUser, error)
}

type UserStore interface {
	FindUser(ctx context.Context, id, email string) (*user.User, error)
}

type SessionStore interface {
	CreateSession(ctx context.Context, token []byte, userID string) (*session.Session, error)
}

type SessionService struct {
	publicKey  *[32]byte
	privateKey *[64]byte
	userdb     UserStore
	sessiondb  SessionStore
}

type Params struct {
	PublicKey  *[32]byte
	PrivateKey *[64]byte
	UserDB     UserStore
	SessiondDB SessionStore
}

func NewService(p Params) *SessionService {
	svc := &SessionService{
		publicKey:  p.PublicKey,
		privateKey: p.PrivateKey,
		userdb:     p.UserDB,
		sessiondb:  p.SessiondDB,
	}

	return svc
}

type Middleware func(Service) Service

func LoggingMiddleware(logger log.Logger) Middleware {
	return func(next Service) Service {
		return &loggingMiddleware{
			next:   next,
			logger: logger,
		}
	}
}

type loggingMiddleware struct {
	next   Service
	logger log.Logger
}
