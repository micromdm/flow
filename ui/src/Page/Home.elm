module Page.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onSubmit, onInput)
import Data.User exposing (User)
import Request.Helpers exposing (httpErrorToString)
import Request.User exposing (storeSession)
import Http
import Route


-- MODEL --


type alias Model =
    { errors : List Error
    , email : String
    , password : String
    }


initialModel : Model
initialModel =
    { errors = []
    , email = ""
    , password = ""
    }


type Field
    = Form
    | Email
    | Password


type alias Error =
    ( Field, String )


type Msg
    = SetEmail String
    | SetPassword String
    | SubmitForm
    | LoginCompleted (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPassword password ->
            { model | password = password } ! []

        SetEmail email ->
            { model | email = email } ! []

        SubmitForm ->
            model ! [ Http.send LoginCompleted <| Request.User.login model ]

        LoginCompleted (Err error) ->
            { model | errors = [ ( Form, httpErrorToString error ) ] } ! []

        LoginCompleted (Ok user) ->
            model ! [ storeSession user, Route.modifyUrl Route.Home ]


view : Model -> Html Msg
view model =
    div [] [ viewForm ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ input
            [ onInput SetEmail
            , placeholder "Email"
            ]
            []
        , input
            [ onInput SetPassword
            , placeholder "Password"
            ]
            []
        , button [] [ text "Sign in" ]
        ]
