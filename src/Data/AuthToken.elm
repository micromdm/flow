module Data.AuthToken exposing (AuthToken, decoder, encode, header)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Http


type AuthToken
    = AuthToken String


encode : AuthToken -> Value
encode (AuthToken token) =
    Encode.string token


decoder : Decoder AuthToken
decoder =
    Decode.string
        |> Decode.map AuthToken


header : Maybe AuthToken -> Http.Header
header maybeToken =
    case maybeToken of
        Nothing ->
            Http.header "" ""

        Just (AuthToken token) ->
            Http.header "Authorization" ("Bearer " ++ token)
