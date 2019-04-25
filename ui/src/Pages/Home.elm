module Pages.Home exposing (Model, Msg, init, toSession, update, view)

import Html exposing (Html, a, div, h1, h2, p, source, text, video)
import Html.Attributes exposing (autoplay, class, href, loop, src, type_)
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
        div []
            [ loopedVideo
            , propertySelector
            ]
    }


loopedVideo : Html msg
loopedVideo =
    div [ class "video-player" ]
        [ video
            [ autoplay True
            , loop True
            , src "videos/beach.mp4"
            ]
            []
        , div [ class "overlay" ]
            [ h1 [] [ text "Shorelands Real Estate" ]
            , h2 [] [ text "Quality beachfront properties in Trinidad and Tobago" ]
            ]
        ]


propertySelector : Html msg
propertySelector =
    div [ class "property-selector container" ]
        [ h2 [] [ text "What are you looking for?" ]
        , div [ class "property-pills" ]
            [ div [ class "pill" ] [ a [ href "/properties/land" ] [ text "Land" ] ]
            , div [ class "pill" ] [ a [ href "/properties/homes" ] [ text "Homes" ] ]
            ]
        , div [ class "sub-text" ]
            [ p [] [ text "pick a category above to view a selection of our properties" ] ]
        ]


toSession : Model -> Session
toSession model =
    model.session
