module Main exposing (..)

import Html exposing (..)
import View exposing (view)
import Models exposing (Msg(..), Model, Task, TaskId)


-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { tasks =
        [ Task 0 False "hello & welcome to this todo list!" False
        , Task 1 True "things are pretty self explanatory" False
        , Task 1 False "so get to work, ya overachiever!" False
        ]
    , newtask = ""
    , edit = ""
    , currentID = 2
    }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        CreateTask writetask ->
            ( { model | newtask = writetask }, Cmd.none )

        EditTask edittask ->
            ( { model | edit = edittask }, Cmd.none )

        AddTask ->
            if model.newtask == "" then
                ( model, Cmd.none )
            else
                ( { model
                    | tasks = Task model.currentID False model.newtask False :: model.tasks
                    , currentID = model.currentID + 1
                  }
                , Cmd.none
                )

        DeleteTask taskId ->
            let
                newTasks =
                    List.filter (\t -> t.id /= taskId) model.tasks
            in
                ( { model | tasks = newTasks }, Cmd.none )

        ToggleCheck taskId ->
            let
                newTasks =
                    List.map (toggleDone taskId) model.tasks
            in
                ( { model | tasks = newTasks }, Cmd.none )

        ToggleEdit taskId ->
            let
                newTasks =
                    List.map (toggleEdit taskId) model.tasks
            in
                ( { model | tasks = newTasks }, Cmd.none )

        SaveEdit taskId ->
            if model.edit == "" then
                let
                    newTasks =
                        List.map (toggleEdit taskId) model.tasks
                in
                    ( { model | tasks = newTasks }, Cmd.none )
            else
                let
                    newTasks =
                        List.map (saveTask taskId model.edit) model.tasks
                in
                    ( { model
                        | tasks = newTasks
                        , newtask = ""
                      }
                    , Cmd.none
                    )


toggleDone : TaskId -> Task -> Task
toggleDone taskId task =
    if task.id == taskId then
        Task task.id (not task.done) task.action task.editing
    else
        task


toggleEdit : TaskId -> Task -> Task
toggleEdit taskId task =
    if task.id == taskId then
        Task task.id task.done task.action (not task.editing)
    else
        task


saveTask : TaskId -> String -> Task -> Task
saveTask taskId edit task =
    if task.id == taskId then
        Task task.id task.done edit (not task.editing)
    else
        task
