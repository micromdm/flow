module Request.User exposing (login)

import Data.AuthToken exposing (AuthToken, header)
import Json.Decode as Decode
import Data.User as User exposing (User)
import Http
import Json.Encode as Encode


login : { r | email : String, password : String } -> Http.Request User
login { email, password } =
    let
        user =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body =
            Encode.object [ ( "user", user ) ]
                |> Http.jsonBody
    in
        Decode.field "user" User.decoder
            |> Http.post "/v1/users/login" body
