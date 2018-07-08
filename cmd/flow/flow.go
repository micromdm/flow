package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/go-kit/kit/log"
	"github.com/go-kit/kit/log/level"
	"github.com/gorilla/mux"
	"github.com/kolide/kit/actor"
	"github.com/kolide/kit/logutil"
	"github.com/oklog/run"

	"github.com/micromdm/flow/server/bindata"
)

func main() {
	logger := logutil.NewServerLogger(true)

	var g run.Group
	{
		// this actor handles an os interrupt signal and terminates the server.
		sig := make(chan os.Signal, 1)
		g.Add(func() error {
			signal.Notify(sig, os.Interrupt)
			select {
			case <-sig:
				level.Info(logger).Log("msg", "beginnning shutdown")
				return nil
			}
		}, func(err error) {
			level.Info(logger).Log("msg", "interrupted", "err", err)
			close(sig)
		})
	}

	{
		runner := runServer(logger)
		g.Add(runner.Execute, runner.Interrupt)
	}

	if err := g.Run(); err != nil {
		level.Info(logger).Log("err", err)
		os.Exit(1)
	}
}

func runServer(logger log.Logger) *actor.Actor {
	var handler http.Handler
	{
		r := mux.NewRouter()
		frontendHandler := bindata.ServeFrontend(logger)
		assetHandler := bindata.ServeStaticAssets("/assets/")
		r.PathPrefix("/assets/").Handler(assetHandler)
		r.Handle("/", frontendHandler)
		handler = r
	}

	server := &http.Server{Addr: ":8080", Handler: handler}

	return &actor.Actor{
		Execute: func() error {
			err := server.ListenAndServe()
			if err == http.ErrServerClosed {
				return nil
			}
			return err
		},
		Interrupt: func(err error) {
			ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
			defer cancel()

			if err := server.Shutdown(ctx); err != nil {
				level.Info(logger).Log("msg", "http proxy shutdown", "err", err)
			}
		},
	}
}
