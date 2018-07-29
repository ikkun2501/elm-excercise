module App exposing (..)

import Http
import Html exposing (..)
import Json.Decode exposing (string, Decoder, list)
import Json.Decode.Pipeline exposing (required, decode)
import Html.Events exposing (onClick, onInput)
import Html.Attributes
    exposing
        ( class
        , src
        , type_
        , value
        , disabled
        )


type alias User =
    { id : String
    , name : String
    , description : String
    }


type alias Model =
    { screenName : String
    , profile : Maybe User
    , users : List User
    , message : Maybe String
    }


type Msg
    = UpdateScreenName String
    | FetchUser
    | LoadUser (Result Http.Error User)
    | FetchUsers
    | LoadUsers (Result Http.Error (List User))


initialModel : Model
initialModel =
    Model "" Nothing [] Nothing


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchUsers )


profileDetailView : Maybe User -> Html Msg
profileDetailView user =
    case user of
        Just user ->
            div [ class "profile" ]
                [ h3 [] [ text "ユーザ詳細" ]
                , div []
                    [ h5 [] [ text user.id ]
                    , div [] [ text user.name ]
                    , div [] [ text user.description ]
                    ]
                ]

        Nothing ->
            text ""


profileView : User -> Html Msg
profileView user =
    li [ class "profile" ] [ text user.id ]


message : Maybe String -> Html Msg
message message =
    case message of
        Just m ->
            p [] [ text m ]

        Nothing ->
            text ""


loadProfileView : Model -> Html Msg
loadProfileView model =
    div [ class "load-profile" ]
        [ message model.message
        , h4 [] [ text "ユーザ検索" ]
        , input
            [ type_ "text"
            , value model.screenName
            , onInput UpdateScreenName
            ]
            []
        , button
            [ disabled (model.screenName == "")
            , onClick FetchUser
            ]
            [ text "検索" ]
        , p [] [ text model.screenName ]
        , h4 [] [ text "ユーザ一覧" ]
        , ul [] (List.map profileView model.users)
        , profileDetailView model.profile
        ]


view : Model -> Html Msg
view model =
    loadProfileView model


usersDecoder : Decoder (List User)
usersDecoder =
    list userDecoder


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "id" string
        |> required "name" string
        |> required "description" string


fetchUsers : Cmd Msg
fetchUsers =
    let
        url =
            "http://localhost:3000/user"

        request =
            Http.get url usersDecoder
    in
        Http.send LoadUsers request


fetchUser : String -> Cmd Msg
fetchUser screenName =
    let
        url =
            "http://localhost:3000/user/" ++ screenName

        request =
            Http.get url userDecoder
    in
        Http.send LoadUser request


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateScreenName screenName ->
            ( { model | screenName = screenName }, Cmd.none )

        FetchUser ->
            ( model, fetchUser model.screenName )

        LoadUser result ->
            case result of
                Ok user ->
                    ( { model | profile = Just user, message = Nothing }, Cmd.none )

                Err _ ->
                    ( { model | message = Just "該当するユーザはいませんでした。" }, Cmd.none )

        FetchUsers ->
            ( model, fetchUsers )

        LoadUsers result ->
            case result of
                Ok users ->
                    ( { model | users = users }, Cmd.none )

                Err _ ->
                    ( initialModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
