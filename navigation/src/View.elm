module View exposing (..)

import Routing exposing (..)
import Html exposing (..)
import Model exposing (..)
import Messages exposing (..)
import Main exposing (..)
import Sub exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ page model ]


page : Model -> Html Msg
page model =
    case model.route of
        MainRoute ->
            Main.view model

        SubRoute ->
            Sub.view model

        NotFoundRoute ->
            notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
