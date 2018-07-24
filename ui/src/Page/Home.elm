module Page.Home exposing (..)

import Html exposing (..)
import Data.Session as Session exposing (Session)


-- MODEL --


type alias Model =
    { errors : List Error
    }


initialModel : Model
initialModel =
    { errors = []
    }


init : Session -> Model
init session =
    initialModel


type Field
    = Form


type alias Error =
    ( Field, String )


type Msg
    = NoOp


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            model ! []


view : Session -> Model -> Html Msg
view session model =
    div [] [ text "home-page" ]
