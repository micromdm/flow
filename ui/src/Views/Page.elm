module Views.Page exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.User as User exposing (User, ID)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | Login


frame : Maybe User -> ActivePage -> Html msg -> Html msg
frame user page content =
    div [ class "page-frame" ]
        [ viewHeader page user
        , content
        , viewFooter
        ]


viewHeader : ActivePage -> Maybe User -> Html msg
viewHeader page user =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", href page ] [ text "flow" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] (viewProfile page user)
            ]
        ]


viewProfile : ActivePage -> Maybe User -> List (Html msg)
viewProfile page maybeUser =
    let
        linkTo =
            navbarLink page
    in
        case maybeUser of
            Nothing ->
                [ linkTo Route.Home [ text "Documentation" ] ]

            Just user ->
                [ linkTo Route.Home [ text "Settings" ]
                , linkTo Route.Home [ text user.username ]
                , linkTo Route.Logout [ text "Sign Out" ]
                ]


href : ActivePage -> Attribute msg
href page =
    case page of
        Login ->
            Route.href Route.Login

        _ ->
            Route.href Route.Home


navbarLink : ActivePage -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive page route ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


isActive : ActivePage -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Login, Route.Login ) ->
            True

        _ ->
            False


viewFooter : Html msg
viewFooter =
    footer [] []
