module Request.Helpers exposing (httpErrorToString)

import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.Timeout ->
            "Timeout!"

        Http.NetworkError ->
            "Network Error"

        Http.BadPayload status message ->
            "status: " ++ (toString status) ++ " " ++ (toString message)

        Http.BadStatus response ->
            let
                failed =
                    Debug.log "Http.BadStatus: " response
            in
                response.body
                    |> decodeString (field "error" string)
                    |> Result.withDefault (toString failed)

        Http.BadUrl status ->
            "status: " ++ (toString status)
