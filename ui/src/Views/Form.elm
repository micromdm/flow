module Views.Form exposing (viewErrors, password)

import Html exposing (Attribute, Html, fieldset, li, text, ul)
import Html.Attributes exposing (class, type_)


viewErrors : List ( a, String ) -> Html msg
viewErrors errors =
    errors
        |> List.map (\( _, error ) -> li [] [ text error ])
        |> ul [ class "error-messages" ]


password : List (Attribute msg) -> List (Html msg) -> Html msg
password attrs =
    Html.input ([ type_ "password" ] ++ attrs)
