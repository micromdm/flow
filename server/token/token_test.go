package token

import (
	"crypto/md5"
	"crypto/rand"
	"fmt"
	"testing"

	"github.com/micromdm/flow/server/id"
	"golang.org/x/crypto/nacl/sign"
)

func TestToken(t *testing.T) {
	pub, priv, err := sign.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}

	userID := id.New()
	signed, err := NewSignedToken(priv, userID)
	if err != nil {
		t.Fatal(err)
	}

	tok, err := Read(pub, signed)
	if err != nil {
		t.Fatal(err)
	}

	if have, want := tok.UserID, userID; have != want {
		t.Errorf("token does not match. have %s, want %s", have, want)
	}

	keyID, err := KeyID(signed)
	if err != nil {
		t.Fatal(err)
	}

	if have, want := keyID, tok.KeyID; have != want {
		t.Errorf("token KeyID not match. have %s, want %s", have, want)
	}
}

func TestFingerprint(t *testing.T) {
	pub, priv, err := sign.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	pubsum := fmt.Sprintf("%x", md5.New().Sum(pub[:]))
	pubsumFromPriv := Fingeprint(priv)
	if have, want := pubsumFromPriv, pubsum; have != want {
		t.Errorf("fingerprint does not match: have %s, want %s", have, want)
	}
}
