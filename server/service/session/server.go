package sessionsvc

import (
	"github.com/go-kit/kit/endpoint"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"

	"github.com/micromdm/flow/server/httputil"
)

type Endpoints struct {
	LoginEndpoint endpoint.Endpoint
}

func MakeServerEndpoints(s Service, outer endpoint.Middleware, others ...endpoint.Middleware) Endpoints {
	return Endpoints{
		LoginEndpoint: endpoint.Chain(outer, others...)(MakeLoginEndpoint(s)),
	}
}

func RegisterHTTPHandlers(r *mux.Router, e Endpoints, options ...httptransport.ServerOption) {
	// POST   /v1/login
	r.Methods("POST").Path("/v1/login").Handler(httptransport.NewServer(
		e.LoginEndpoint,
		decodeLoginRequest,
		httputil.EncodeJSONResponse,
		options...,
	))
}
