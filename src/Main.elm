module Main exposing (main)

import Html exposing (..)
import Navigation exposing (Location)
import Json.Decode as Decode exposing (Value)
import Route exposing (Route)
import Page.Home as Home


type Page
    = Blank
    | NotFound
    | Home Home.Model


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
    | HomeMsg Home.Msg


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
                transition (Home Home.initialModel) ! []

            Just Route.Root ->
                model ! [ Route.modifyUrl Route.Home ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )
    in
        case ( msg, page ) of
            ( NoOp, _ ) ->
                model ! []

            ( SetRoute route, _ ) ->
                setRoute route model

            ( HomeMsg subMsg, Home subModel ) ->
                toPage Home HomeMsg Home.update subMsg subModel

            ( _, NotFound ) ->
                -- Disregard incoming messages when we're on the
                -- NotFound page.
                model ! []

            ( _, _ ) ->
                -- Disregard incoming messages when we're on the
                -- NotFound page.
                model ! []


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage page


viewPage : Page -> Html Msg
viewPage page =
    case page of
        NotFound ->
            text "404"

        Blank ->
            text ""

        Home subModel ->
            Home.view subModel |> Html.map HomeMsg



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
