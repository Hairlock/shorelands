module Pages.Properties exposing (Model, Msg, init, toSession, update, view)

import Html exposing (Html, a, button, div, h1, hr, i, img, li, span, text, ul)
import Html.Attributes exposing (class, src)
import Html.Events exposing (..)
import Http
import Property exposing (Property(..), fetchAll, genericAttrs)
import Property.Category as Category exposing (Category)
import RemoteData exposing (RemoteData(..), WebData)
import Session exposing (Session)
import Task exposing (Task)


type alias Model =
    { properties : WebData (List Property)
    , searchCategory : Category
    , session : Session
    }


init : Session -> Category -> ( Model, Cmd Msg )
init session searchCategory =
    let
        fetchProperties =
            Property.fetchAll
                |> Http.toTask
                |> Task.attempt (RemoteData.fromResult >> PropertiesLoaded)
    in
    ( { properties = Loading
      , searchCategory = searchCategory
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
                        Category.toString model.searchCategory
                in
                div
                    [ class "properties-list container" ]
                    (List.map propertiesCard props)

            -- ([ h1 [] [ text (category ++ " for sale!") ] ]
            --     ++ List.map propertiesCard props
            -- )
            Loading ->
                div [] []

            _ ->
                div [] [ text "Properties failed to load" ]
    }


propertiesCard : Property -> Html Msg
propertiesCard property =
    let
        { title, slug, category, size, tagline } =
            genericAttrs property

        amenities =
            amenitiesList
    in
    div [ class "properties-card" ]
        [ h1 [ class "header" ] [ text title ]
        , hr [ class "divider" ] []
        , div [ class "card-content" ]
            [ div [] [ img [ class "property-picture", src <| "/images/" ++ slug ++ ".jpg" ] [] ]
            , div []
                [ div [] [ amenities property ]
                , div [ class "tag-line" ] [ text tagline ]
                , a [ class "select-btn" ] [ text "See More" ]
                ]
            ]
        ]


amenitiesList : Property -> Html Msg
amenitiesList property =
    case property of
        Land { size, drainage } ->
            ul [ class "fa-ul amenities-list" ]
                [ li [ class "amenities-item" ]
                    [ span [ class "fa-li" ]
                        [ i [ class "fas fa-ruler-combined" ] [] ]
                    , text <| String.fromInt size ++ " sq ft."
                    ]
                ]

        Home { size, pool, bedrooms } ->
            ul [ class "fa-ul amenities-list" ]
                [ li [ class "amenities-item" ]
                    [ span [ class "fa-li" ]
                        [ i [ class "fas fa-ruler-combined" ] [] ]
                    , text <| String.fromInt size ++ " sq ft."
                    ]
                , li [ class "amenities-item" ]
                    [ span [ class "fa-li" ]
                        [ i [ class "fas fa-bed" ] [] ]
                    , text <| String.fromInt bedrooms ++ " bedrooms"
                    ]
                ]


toSession : Model -> Session
toSession model =
    model.session
