module Sub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Messages exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ text "Sub"
        , a [ href "#main" ] [ text "メイン" ]
        ]
