package token

import (
	"encoding/base64"
	"encoding/json"
	"time"

	"github.com/pkg/errors"
	"golang.org/x/crypto/nacl/sign"
)

type Token struct {
	UserID   string `json:"user_id"`
	IssuedAt int64  `json:"issued_at"`
	KeyID    string `json:"key_id"`
}

// NewSignedToken creates and signs a Token for the userID.
// The returned token is base64 encoded using the RawURLEncoding format.
func NewSignedToken(privateKey *[64]byte, userID string) ([]byte, error) {
	tok := Token{
		UserID:   userID,
		IssuedAt: time.Now().UTC().UnixNano(),
		KeyID:    Fingeprint(privateKey),
	}

	b, err := json.Marshal(&tok)
	if err != nil {
		return nil, errors.Wrapf(err, "marshal token for user %s", userID)
	}

	out := make([]byte, 0, len(b)+sign.Overhead)
	out = sign.Sign(out, b, privateKey)

	enc := base64.RawURLEncoding
	buf := make([]byte, enc.EncodedLen(len(out)))
	enc.Encode(buf, out)
	return buf, nil
}

// KeyID reads to key fingerprint from the encoded token.
func KeyID(encoded []byte) (string, error) {
	tok, _, err := readWithoutOpen(encoded)
	if err != nil {
		return "", errors.Wrap(err, "read token to determine fingerprint")
	}
	return tok.KeyID, nil
}

func readWithoutOpen(encoded []byte) (*Token, []byte, error) {
	enc := base64.RawURLEncoding
	buf := make([]byte, enc.DecodedLen(len(encoded)))
	_, err := enc.Decode(buf, encoded)
	if err != nil {
		return nil, nil, errors.Wrap(err, "reading b64 encoded token")
	}

	raw := buf[sign.Overhead:]
	var tok Token
	err = json.Unmarshal(raw, &tok)
	return &tok, buf, nil
}

// Read reads a base64.RawURLEncoding encoded token.
func Read(publicKey *[32]byte, encoded []byte) (*Token, error) {
	enc := base64.RawURLEncoding
	buf := make([]byte, enc.DecodedLen(len(encoded)))
	_, err := enc.Decode(buf, encoded)
	if err != nil {
		return nil, errors.Wrap(err, "reading b64 encoded token")
	}

	out := make([]byte, 0, len(buf)-sign.Overhead)
	out, b := sign.Open(out, buf, publicKey)
	if !b {
		return nil, errors.New("could not verify token signature")
	}

	var tok Token
	err = json.Unmarshal(out, &tok)
	return &tok, errors.Wrap(err, "unmarshal token")
}
