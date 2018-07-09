package token

import (
	"crypto/md5"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/pkg/errors"
	"golang.org/x/crypto/nacl/sign"
)

const (
	pubFile  = "token.pub"
	privFile = "token.priv"
)

func NewKey(keyDir string) (publicKey *[32]byte, privateKey *[64]byte, err error) {
	pub, priv, err := sign.GenerateKey(rand.Reader)
	if err != nil {
		return nil, nil, errors.Wrap(err, "generate new key for tokens")
	}

	pubPath := filepath.Join(keyDir, pubFile)
	if err := saveHex(pubPath, pub[:]); err != nil {
		os.Remove(pubPath)
		return nil, nil, errors.Wrap(err, "saving publicKey key")
	}

	privPath := filepath.Join(keyDir, privFile)
	if err := saveHex(privPath, priv[:]); err != nil {
		os.Remove(pubPath)
		os.Remove(privPath)
		return nil, nil, errors.Wrap(err, "saving privateKey")
	}

	return pub, priv, nil
}

func LoadKey(keyDir string) (publicKey *[32]byte, privateKey *[64]byte, err error) {
	pubPath := filepath.Join(keyDir, pubFile)
	pub, err := openHex(pubPath)
	if err != nil {
		return nil, nil, errors.Wrap(err, "loading public key")
	}

	privPath := filepath.Join(keyDir, privFile)
	priv, err := openHex(privPath)
	if err != nil {
		return nil, nil, errors.Wrap(err, "loading private key")
	}

	publicKey, privateKey = new([32]byte), new([64]byte)
	copy((*publicKey)[:], pub)
	copy((*privateKey)[:], priv)
	return publicKey, privateKey, nil
}

func Fingeprint(privateKey *[64]byte) string {
	return fmt.Sprintf("%x", md5.New().Sum(privateKey[32:]))
}

func saveHex(path string, data []byte) error {
	f, err := os.Create(path)
	if err != nil {
		return errors.Wrapf(err, "create file %s", path)
	}
	defer f.Close()

	_, err = hex.NewEncoder(f).Write(data)
	return errors.Wrapf(err, "write hex key to file %s", path)
}

func openHex(path string) ([]byte, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, errors.Wrapf(err, "open file %s", path)
	}
	defer f.Close()
	data, err := ioutil.ReadAll(hex.NewDecoder(f))
	return data, errors.Wrapf(err, "read hex data from file %s", path)
}
