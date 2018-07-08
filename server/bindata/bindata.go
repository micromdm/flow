package bindata

import (
	"io"
	"net/http"

	"github.com/elazarl/go-bindata-assetfs"
	"github.com/go-kit/kit/log"
)

func newBinaryFileSystem(root string) *assetfs.AssetFS {
	return &assetfs.AssetFS{
		Asset:     Asset,
		AssetDir:  AssetDir,
		AssetInfo: AssetInfo,
		Prefix:    root,
	}
}

func ServeFrontend(logger log.Logger) http.Handler {
	herr := func(w http.ResponseWriter, err string) {
		logger.Log("err", err)
		http.Error(w, err, http.StatusInternalServerError)
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fs := newBinaryFileSystem("/")
		file, err := fs.Open("index.html")
		if err != nil {
			herr(w, "load index.html: "+err.Error())
			return
		}
		defer file.Close()
		_, err = io.Copy(w, file)
		if err != nil {
			herr(w, "write file to ResponseWriter: "+err.Error())
			return
		}
	})
}

func ServeStaticAssets(path string) http.Handler {
	return http.StripPrefix(path, http.FileServer(newBinaryFileSystem("/assets")))
}
