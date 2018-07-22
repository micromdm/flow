package session

import (
	"context"
	"net/http"
	"time"

	"github.com/go-kit/kit/endpoint"
	"github.com/pkg/errors"

	"github.com/micromdm/flow/server/data/user"
	"github.com/micromdm/flow/server/httputil"
	"github.com/micromdm/flow/server/token"
)

func (svc *SessionService) Login(ctx context.Context, email, password string) (*user.APIUser, error) {
	usr, err := svc.userdb.FindUser(ctx, "", email)
	if err != nil {
		return nil, authenticationError{reason: errors.Wrapf(err, "find user %s for login", email).Error()}
	}

	if err := usr.ValidatePassword(password); err != nil {
		return nil, authenticationError{reason: errors.Wrapf(err, "wrong password for user %s", email).Error()}
	}

	signed, err := token.NewSignedToken(svc.privateKey, usr.ID)
	if err != nil {
		return nil, errors.Wrap(err, "create signed token on login")
	}

	_, err = svc.sessiondb.CreateSession(ctx, signed, usr.ID)
	if err != nil {
		return nil, errors.Wrap(err, "create session on login")
	}

	apiUser := &user.APIUser{
		ID:        usr.ID,
		Username:  usr.Username,
		FullName:  usr.FullName,
		Email:     usr.Email,
		CreatedAt: usr.CreatedAt.UnixNano(),
		UpdatedAt: usr.UpdatedAt.UnixNano(),
		Token:     string(signed),
	}

	return apiUser, nil
}

type loginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type loginResponse struct {
	User *user.APIUser `json:"user"`
	Err  error         `json:"-"`
}

func (r loginResponse) Failed() error { return r.Err }

func decodeLoginRequest(ctx context.Context, r *http.Request) (interface{}, error) {
	var req loginRequest
	err := httputil.DecodeJSONRequest(r, &req)
	return req, err
}

func MakeLoginEndpoint(svc Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (interface{}, error) {
		req := request.(loginRequest)
		user, err := svc.Login(ctx, req.Username, req.Password)
		return loginResponse{User: user, Err: err}, nil
	}
}

func (mw loggingMiddleware) Login(ctx context.Context, email, password string) (usr *user.APIUser, err error) {
	defer func(begin time.Time) {
		_ = mw.logger.Log(
			"method", "Login",
			"email", "email",
			"err", err,
			"took", time.Since(begin),
		)
	}(time.Now())

	usr, err = mw.next.Login(ctx, email, password)
	return
}

type authenticationError struct {
	reason string

	// client reason is used to provide
	// a different error message to the client
	// when security is a concern
	clientReason string
}

func (e authenticationError) Error() string {
	return e.reason
}

func (e authenticationError) AuthenticationError() string {
	if e.clientReason != "" {
		return e.clientReason
	}
	return "email or password do not match"
}

func (e authenticationError) StatusCode() int {
	return http.StatusUnauthorized
}
