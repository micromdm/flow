module Main exposing (main)

import Html exposing (..)


type Page
    = Blank
    | NotFound


type PageState
    = Loaded Page


type alias Model =
    { pageState : PageState
    }


initialPage : Page
initialPage =
    Blank


init : ( Model, Cmd msg )
init =
    let
        initialModel =
            { pageState = Loaded initialPage }
    in
        ( initialModel, Cmd.none )



-- UPDATE --


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            div [] [ text "Hello World" ]



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN --


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
