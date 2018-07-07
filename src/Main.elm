module Main exposing (main)

import Html exposing (..)
import Navigation exposing (Location)
import Json.Decode as Decode exposing (Value)
import Route exposing (Route)


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


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        }



-- UPDATE --


type Msg
    = NoOp
    | SetRoute (Maybe Route)


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition page =
            { model | pageState = Loaded page }
    in
        case maybeRoute of
            Nothing ->
                { model | pageState = Loaded NotFound } ! []

            Just Route.Home ->
                transition Blank ! []

            Just Route.Root ->
                model ! [ Route.modifyUrl Route.Home ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        SetRoute route ->
            setRoute route model



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage page


viewPage : Page -> Html msg
viewPage page =
    case page of
        NotFound ->
            text "404"

        Blank ->
            text ""



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
