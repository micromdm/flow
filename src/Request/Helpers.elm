module Request.Helpers exposing (httpErrorToString)

import Http


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.Timeout ->
            "Timeout!"

        Http.NetworkError ->
            "Network Error"

        Http.BadPayload status message ->
            "status: " ++ (toString status) ++ " " ++ (toString message)

        Http.BadStatus status ->
            "status: " ++ (toString status)

        Http.BadUrl status ->
            "status: " ++ (toString status)
