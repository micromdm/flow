module Main exposing (main)

import Html exposing (..)
import Navigation exposing (Location)
import Json.Decode as Decode exposing (Value)
import Route exposing (Route)
import Ports
import Page.Home as Home
import Page.Login as Login
import Data.Session exposing (Session)
import Data.User as User exposing (User, ID)
import Views.Page as Page exposing (ActivePage)


type Page
    = Blank
    | NotFound
    | Login Login.Model
    | Home Home.Model


type PageState
    = Loaded Page


type alias Model =
    { session : Session
    , pageState : PageState
    }


initialPage : Page
initialPage =
    Blank


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , session = { user = decodeUserFromJson val }
        }


decodeUserFromJson : Value -> Maybe User
decodeUserFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString User.decoder >> Result.toMaybe)



-- UPDATE --


type Msg
    = NoOp
    | SetRoute (Maybe Route)
    | HomeMsg Home.Msg
    | LoginMsg Login.Msg
    | SetUser (Maybe User)


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition page =
            { model | pageState = Loaded page }

        cmdFromAuth maybeRoute =
            let
                routeCmd =
                    case maybeRoute of
                        Nothing ->
                            Cmd.none

                        Just route ->
                            Route.modifyUrl route
            in
                case model.session.user of
                    Nothing ->
                        Route.modifyUrl Route.Login

                    Just _ ->
                        routeCmd
    in
        case maybeRoute of
            Nothing ->
                { model | pageState = Loaded NotFound } ! []

            Just Route.Login ->
                { model | pageState = Loaded (Login Login.initialModel) } ! []

            Just Route.Logout ->
                let
                    session =
                        model.session
                in
                    ( { model | session = { session | user = Nothing } }
                    , Cmd.batch
                        [ Ports.storeSession Nothing
                        , Route.modifyUrl Route.Login
                        ]
                    )

            Just Route.Home ->
                transition (Home (Home.init model.session)) ! [ cmdFromAuth Nothing ]

            Just Route.Root ->
                model ! [ cmdFromAuth <| Just Route.Home ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        session =
            model.session

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

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Login.update subMsg subModel

                    newModel =
                        case msgFromPage of
                            Login.NoOp ->
                                model

                            Login.SetUser user ->
                                { model | session = { user = Just user } }
                in
                    ( { newModel | pageState = Loaded (Login pageModel) }
                    , Cmd.map LoginMsg cmd
                    )

            ( HomeMsg subMsg, Home subModel ) ->
                toPage Home HomeMsg (Home.update session) subMsg subModel

            ( SetUser user, _ ) ->
                let
                    cmd =
                        -- If we just signed out, then redirect to Login.
                        if session.user /= Nothing && user == Nothing then
                            Route.modifyUrl Route.Login
                        else
                            Cmd.none
                in
                    { model | session = { session | user = user } } ! [ cmd ]

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
            div []
                [ viewPage model.session page
                , br [] []
                , br [] []
                , text <| toString model
                ]


viewPage : Session -> Page -> Html Msg
viewPage session page =
    let
        frame =
            Page.frame session.user
    in
        case page of
            NotFound ->
                text "404"
                    |> frame Page.Other

            Blank ->
                text ""
                    |> frame Page.Other

            Login subModel ->
                Login.view session subModel
                    |> frame Page.Login
                    |> Html.map LoginMsg

            Home subModel ->
                Home.view session subModel
                    |> frame Page.Home
                    |> Html.map HomeMsg



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Sub.map SetUser sessionChange ]


sessionChange : Sub (Maybe User)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue User.decoder >> Result.toMaybe)



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
