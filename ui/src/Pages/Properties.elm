module Pages.Properties exposing (Model, Msg, init, toSession, update, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (..)
import Http
import Property exposing (Property, fetchAll, slug)
import RemoteData exposing (RemoteData(..), WebData)
import Session exposing (Session)
import Task exposing (Task)


type alias Model =
    { properties : WebData (List Property)
    , session : Session
    }


init : Session -> ( Model, Cmd Msg )
init session =
    let
        fetchProperties =
            Property.fetchAll
                |> Http.toTask
                |> Task.attempt (RemoteData.fromResult >> PropertiesLoaded)
    in
    ( { properties = Loading
      , session = session
      }
    , fetchProperties
    )


type Msg
    = PropertiesLoaded (WebData (List Property))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PropertiesLoaded data ->
            ( { model | properties = data }, Cmd.none )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Properties"
    , content =
        case model.properties of
            Success props ->
                div
                    [ class "container" ]
                    (List.map (\p -> div [] [ text (slug p) ]) props)

            Loading ->
                div [] []

            _ ->
                div [] [ text "Properties failed to load" ]
    }


toSession : Model -> Session
toSession model =
    model.session
