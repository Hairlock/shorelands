module Pages.Home exposing (Model, Msg, init, toSession, update, view)

import Html exposing (Html, div, text, video)
import Html.Attributes exposing (class, src)
import Html.Events exposing (..)
import Http
import Property exposing (Property, fetchAll, slug)
import RemoteData exposing (RemoteData(..), WebData)
import Session exposing (Session)
import Task exposing (Task)


type alias Model =
    { session : Session
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      }
    , Cmd.none
    )


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Shorelands Real Estate"
    , content =
        loopedVideo
    }


loopedVideo : Html msg
loopedVideo =
    video
        [ class "video-player", src "https://www.youtube.com/watch?v=DGIXT7ce3vQ" ]
        []


toSession : Model -> Session
toSession model =
    model.session
