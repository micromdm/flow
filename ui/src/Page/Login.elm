module Page.Login exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Request.Helpers exposing (httpErrorToString)
import Request.User exposing (storeSession)
import Route
import Data.Session as Session exposing (Session)
import Data.User exposing (User)
import Views.Form as Form


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


type ExternalMsg
    = NoOp
    | SetUser User



-- UPDATE --


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SetPassword password ->
            ( ( { model | password = password }
              , Cmd.none
              )
            , NoOp
            )

        SetEmail email ->
            ( ( { model | email = email }
              , Cmd.none
              )
            , NoOp
            )

        SubmitForm ->
            ( ( { model | errors = [] }
              , Http.send LoginCompleted <| Request.User.login model
              )
            , NoOp
            )

        LoginCompleted (Err error) ->
            ( ( { model | errors = [ ( Form, httpErrorToString error ) ] }
              , Cmd.none
              )
            , NoOp
            )

        LoginCompleted (Ok user) ->
            ( ( model
              , Cmd.batch [ storeSession user, Route.modifyUrl Route.Home ]
              )
            , SetUser user
            )



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text "Welcome back!" ]
                    , Form.viewErrors model.errors
                    , viewForm
                    ]
                ]
            ]
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ input
            [ onInput SetEmail
            , placeholder "Email"
            ]
            []
        , Form.password
            [ onInput SetPassword
            , placeholder "Password"
            ]
            []
        , button [] [ text "Sign in" ]
        ]
