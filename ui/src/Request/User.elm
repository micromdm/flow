module Request.User exposing (login, storeSession)

import Json.Decode as Decode
import Data.User as User exposing (User)
import Http
import Json.Encode as Encode
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
