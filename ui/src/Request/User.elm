module Request.User exposing (login, storeSession, list)

import Json.Decode as Decode
import Data.User as User exposing (User, ID)
import Data.AuthToken exposing (AuthToken, header)
import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Ports


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | email : String, password : String } -> Http.Request User
login { email, password } =
    let
        user =
            Encode.object
                [ ( "username", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body =
            Http.jsonBody user
    in
        Decode.field "user" User.decoder
            |> Http.post "/v1/users/login" body


logout : AuthToken -> Http.Request String
logout token =
    Http.request
        { method = "POST"
        , headers = [ header (Just token) ]
        , url = "/v1/users/logout"
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


list : AuthToken -> Http.Request User
list token =
    Http.request
        { method = "GET"
        , headers = [ header (Just token) ]
        , url = "/v1/users"
        , body = Http.emptyBody
        , expect = Http.expectJson User.decoder
        , timeout = Nothing
        , withCredentials = False
        }


get : ID -> AuthToken -> Http.Request User
get id token =
    Http.request
        { method = "GET"
        , headers = [ header (Just token) ]
        , url = "/v1/users/" ++ User.idToString id
        , body = Http.emptyBody
        , expect = Http.expectJson User.decoder
        , timeout = Nothing
        , withCredentials = False
        }
