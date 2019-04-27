module Pages.Property exposing (Model, Msg, init, toSession, update, view)

import Html exposing (Html, a, button, div, h1, hr, i, img, li, span, text, ul)
import Html.Attributes exposing (class, src)
import Html.Events exposing (..)
import Http
import Property exposing (GenericAttributes, Property(..), Slug, fetch, genericAttrs)
import Property.Category as Category exposing (Category)
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (Route)
import Session exposing (Session)
import Task exposing (Task)


type alias Model =
    { property : WebData Property
    , session : Session
    }


init : Session -> Slug -> ( Model, Cmd Msg )
init session slug =
    let
        fetchProperty =
            Property.fetch slug
                |> Http.toTask
                |> Task.attempt (RemoteData.fromResult >> PropertyLoaded)
    in
    ( { property = Loading
      , session = session
      }
    , fetchProperty
    )


type Msg
    = PropertyLoaded (WebData Property)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PropertyLoaded data ->
            ( { model | property = data }, Cmd.none )


view : Model -> { title : String, content : Html Msg }
view model =
    case model.property of
        Success prop ->
            let
                generic =
                    genericAttrs prop

                { title } =
                    generic
            in
            { title = title
            , content =
                div
                    [ class "property-card container" ]
                    [ propertyCard generic prop ]
            }

        Loading ->
            { title = "Property"
            , content = div [] []
            }

        _ ->
            { title = "Property"
            , content = div [] [ text "Property failed to load" ]
            }


propertyCard : GenericAttributes -> Property -> Html Msg
propertyCard generic property =
    let
        { title, slug, category, size, tagline } =
            generic
    in
    div []
        [ text title
        ]


toSession : Model -> Session
toSession model =
    model.session
