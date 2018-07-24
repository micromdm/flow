module Data.User exposing (User, ID, decoder, encode, idDecoder, idParser, idToHtml, idToString)

import Html exposing (Html)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import UrlParser
import Data.AuthToken as AuthToken exposing (AuthToken)


type alias User =
    { id : ID
    , username : String
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
        |> required "id" idDecoder
        |> required "username" Decode.string
        |> required "full_name" Decode.string
        |> required "email" Decode.string
        |> required "created_at" Decode.int
        |> required "updated_at" Decode.int
        |> required "token" AuthToken.decoder


encode : User -> Value
encode user =
    Encode.object
        [ ( "id", encodeID user.id )
        , ( "username", Encode.string user.username )
        , ( "full_name", Encode.string user.fullName )
        , ( "email", Encode.string user.email )
        , ( "created_at", Encode.int user.createdAt )
        , ( "updated_at", Encode.int user.updatedAt )
        , ( "token", AuthToken.encode user.token )
        ]



-- IDENTIFIERS --


type ID
    = ID String


idToString : ID -> String
idToString (ID id) =
    id


idParser : UrlParser.Parser (ID -> a) a
idParser =
    UrlParser.custom "ID" (Ok << ID)


idDecoder : Decoder ID
idDecoder =
    Decode.map ID Decode.string


encodeID : ID -> Value
encodeID (ID id) =
    Encode.string id


idToHtml : ID -> Html msg
idToHtml (ID id) =
    Html.text id
