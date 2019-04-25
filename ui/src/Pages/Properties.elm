module Pages.Properties exposing (Model, Msg, init, toSession, update, view)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (..)
import Http
import Property exposing (Property, fetchAll, slug)
import Property.Category as Category exposing (Category)
import RemoteData exposing (RemoteData(..), WebData)
import Session exposing (Session)
import Task exposing (Task)


type alias Model =
    { properties : WebData (List Property)
    , category : Category
    , session : Session
    }


init : Session -> Category -> ( Model, Cmd Msg )
init session category =
    let
        fetchProperties =
            Property.fetchAll
                |> Http.toTask
                |> Task.attempt (RemoteData.fromResult >> PropertiesLoaded)
    in
    ( { properties = Loading
      , category = category
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
                let
                    category =
                        Category.toString model.category
                in
                div
                    [ class "properties-list container" ]
                    [ h1 [] [ text (category ++ " for sale!") ] ]

            -- (List.map (\p -> div [] [ text (slug p) ]) props)
            Loading ->
                div [] []

            _ ->
                div [] [ text "Properties failed to load" ]
    }


toSession : Model -> Session
toSession model =
    model.session
