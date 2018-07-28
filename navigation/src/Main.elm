module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Messages exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ text "Main"
        , a [ href "#sub" ] [ text "サブ" ]
        ]
