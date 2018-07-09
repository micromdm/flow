module Data.User exposing (User, Username, decoder, encode, usernameDecoder, usernameParser, usernameToHtml, usernameToString)

import Html exposing (Html)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import UrlParser
import Data.AuthToken as AuthToken exposing (AuthToken)


type alias User =
    { id : String
    , username : Username
    , fullName : String
    , email : String
    , createdAt : Int
    , updatedAt : Int
    , token : AuthToken
    }



-- SERIALIZATION --


decoder : Decoder User
decoder =
    decode User
        |> required "id" Decode.string
        |> required "username" usernameDecoder
        |> required "full_name" Decode.string
        |> required "email" Decode.string
        |> required "created_at" Decode.int
        |> required "updated_at" Decode.int
        |> required "token" AuthToken.decoder


encode : User -> Value
encode user =
    Encode.object
        [ ( "id", Encode.string user.id )
        , ( "username", encodeUsername user.username )
        , ( "full_name", Encode.string user.fullName )
        , ( "email", Encode.string user.email )
        , ( "created_at", Encode.int user.createdAt )
        , ( "updated_at", Encode.int user.updatedAt )
        , ( "token", AuthToken.encode user.token )
        ]



-- IDENTIFIERS --


type Username
    = Username String


usernameToString : Username -> String
usernameToString (Username username) =
    username


usernameParser : UrlParser.Parser (Username -> a) a
usernameParser =
    UrlParser.custom "USERNAME" (Ok << Username)


usernameDecoder : Decoder Username
usernameDecoder =
    Decode.map Username Decode.string


encodeUsername : Username -> Value
encodeUsername (Username username) =
    Encode.string username


usernameToHtml : Username -> Html msg
usernameToHtml (Username username) =
    Html.text username
