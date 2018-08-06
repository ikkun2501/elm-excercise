module App exposing (..)

import Http
import Html exposing (..)
import Json.Decode exposing (string, Decoder, list)
import Json.Decode.Pipeline exposing (required, decode)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy)
import Html.Keyed as Keyed


type alias Task =
    String


type alias TodoId =
    Int


type alias SearchWord =
    String


type Status
    = Complete
    | Active


type SearchStatus
    = SearchStatus Status
    | AllSearch


type alias Todo =
    { todoId : TodoId
    , task : Task
    , status : Status
    }


type Msg
    = UpdateTodo Task
    | RegisterTodo
    | RemoveTodo TodoId
    | ChangeStatus TodoId Status
    | InputSearchWord SearchWord
    | ChangeSearchStatus SearchStatus


type alias Model =
    { inputTask : Task
    , todos : List Todo
    , todoIdSequence : Int
    , searchWord : String
    , searchStatus : SearchStatus
    }


initialModel : Model
initialModel =
    { inputTask = ""
    , todos = []
    , todoIdSequence = 0
    , searchWord = ""
    , searchStatus = SearchStatus Active
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ div [ class "field" ]
            [ label [ class "label" ] [ text "検索" ]
            , input [ class "input", type_ "text", value model.searchWord, onInput InputSearchWord ] []
            ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "ステータス" ]
            , label [ class "radio" ] [ input [ type_ "radio", name "searchStatus", checked (model.searchStatus == SearchStatus Active), onClick (ChangeSearchStatus (SearchStatus Active)) ] [], text "Active" ]
            , label [ class "radio" ] [ input [ type_ "radio", name "searchStatus", checked (model.searchStatus == SearchStatus Complete), onClick (ChangeSearchStatus (SearchStatus Complete)) ] [], text "Complete" ]
            , label [ class "radio" ] [ input [ type_ "radio", name "searchStatus", checked (model.searchStatus == AllSearch), onClick (ChangeSearchStatus AllSearch) ] [], text "All" ]
            ]
        , div
            [ class "field is-grouped" ]
            [ p [ class "control is-expanded" ] [ input [ class "input", type_ "text", value model.inputTask, onInput UpdateTodo ] [] ]
            , button [ class "button is-primary", onClick RegisterTodo ] [ text "追加" ]
            ]
        , lazy todosView model
        ]


todosView : Model -> Html Msg
todosView model =
    Keyed.ul []
        (model.todos
            |> (List.filter
                    (\todo ->
                        case model.searchStatus of
                            SearchStatus status ->
                                status == todo.status

                            AllSearch ->
                                True
                    )
               )
            |> (List.filter (\todo -> String.contains model.searchWord todo.task))
            |> (List.map todoKeyedView)
        )


todoKeyedView : Todo -> ( String, Html Msg )
todoKeyedView todo =
    ( toString todo.todoId, todoView todo )


todoView : Todo -> Html Msg
todoView todo =
    case todo.status of
        Complete ->
            li []
                [ div []
                    [ input [ class "toggle", type_ "checkbox", checked (todo.status == Complete), onClick (ChangeStatus todo.todoId Active) ] []
                    , span [ style [ ( "text-decoration", "line-through" ) ] ] [ text todo.task ]
                    , button [ class "button", onClick (RemoveTodo todo.todoId) ] [ text "削除" ]
                    ]
                ]

        Active ->
            li []
                [ div []
                    [ input [ class "toggle", type_ "checkbox", checked (todo.status == Complete), onClick (ChangeStatus todo.todoId Complete) ] []
                    , span [] [ text todo.task ]
                    , button [ class "button", onClick (RemoveTodo todo.todoId) ] [ text "削除" ]
                    ]
                ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTodo task ->
            ( { model | inputTask = task }, Cmd.none )

        RegisterTodo ->
            ( { model
                | todos =
                    model.todos
                        ++ [ { todoId = model.todoIdSequence
                             , task = model.inputTask
                             , status = Active
                             }
                           ]
                , inputTask = ""
                , todoIdSequence = model.todoIdSequence + 1
              }
            , Cmd.none
            )

        RemoveTodo removeTodoId ->
            ( { model | todos = (List.filter (\todo -> todo.todoId /= removeTodoId) model.todos) }, Cmd.none )

        ChangeStatus todoId s ->
            let
                changeStatus todo =
                    if todo.todoId == todoId then
                        { todo | status = s }
                    else
                        todo
            in
                ( { model | todos = (List.map changeStatus model.todos) }, Cmd.none )

        InputSearchWord searchWord ->
            ( { model | searchWord = searchWord }, Cmd.none )

        ChangeSearchStatus searchStatus ->
            ( { model | searchStatus = searchStatus }, Cmd.none )


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
