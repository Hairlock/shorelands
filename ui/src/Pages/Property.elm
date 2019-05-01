module Pages.Property exposing (Model, Msg, init, toSession, update, view)

import Config exposing (Config)
import Gallery as Gallery
import Gallery.Image as Image
import Html exposing (Html, a, button, div, form, h1, hr, i, iframe, img, input, li, span, text, textarea, ul)
import Html.Attributes exposing (attribute, class, disabled, height, href, id, placeholder, required, src, style, type_, value, width)
import Html.Events exposing (..)
import Http
import Property exposing (GenericAttributes, MapUrl, Property(..), Slug, fetch, genericAttrs)
import Property.Category as Category exposing (Category)
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (Route)
import Session exposing (Session)
import Task exposing (Task)


type alias Model =
    { property : WebData Property
    , imageGallery : Maybe Gallery.State
    , images : Maybe (List String)
    , session : Session
    , showContactForm : Bool
    , email : String
    , message : String
    , config : Config
    }


init : Config -> Session -> Slug -> ( Model, Cmd Msg )
init config session slug =
    let
        fetchProperty =
            Property.fetch config slug
                |> Http.toTask
                |> Task.attempt (RemoteData.fromResult >> PropertyLoaded)
    in
    ( { property = Loading
      , imageGallery = Nothing
      , images = Nothing
      , session = session
      , showContactForm = False
      , email = ""
      , message = ""
      , config = config
      }
    , fetchProperty
    )


type Msg
    = PropertyLoaded (WebData Property)
    | ImageGalleryMsg Gallery.Msg
    | ToggleContactForm
    | EmailInput String
    | MessageInput String
    | ContactSubmit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ImageGalleryMsg imgMsg ->
            case model.imageGallery of
                Just imgGallery ->
                    ( { model
                        | imageGallery =
                            Just <| Gallery.update imgMsg imgGallery
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        PropertyLoaded data ->
            let
                ( imageList, gallery ) =
                    case data of
                        Success prop ->
                            let
                                { images } =
                                    genericAttrs prop
                            in
                            ( Just images, Just <| Gallery.init (List.length images) )

                        _ ->
                            ( Nothing, Nothing )
            in
            ( { model
                | property = data
                , images = imageList
                , imageGallery = gallery
              }
            , Cmd.none
            )

        ToggleContactForm ->
            ( { model | showContactForm = not model.showContactForm }, Cmd.none )

        EmailInput email ->
            ( { model | email = email }, Cmd.none )

        MessageInput message ->
            ( { model | message = message }, Cmd.none )

        ContactSubmit ->
            ( model, Cmd.none )


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
                propertyCard model model.imageGallery generic prop
            }

        Loading ->
            { title = "Property"
            , content = div [] []
            }

        _ ->
            { title = "Property"
            , content = div [] [ text "Property failed to load" ]
            }


propertyCard : Model -> Maybe Gallery.State -> GenericAttributes -> Property -> Html Msg
propertyCard model imageGallery generic property =
    let
        { title, slug, category, size, tagline, images, mapurl } =
            generic
    in
    div [ class "property-card container" ]
        [ h1 [ class "title" ] [ text title ]
        , case imageGallery of
            Just gallery ->
                Html.map ImageGalleryMsg <|
                    Gallery.view imageConfig gallery [ Gallery.Arrows ] (imageSlides model.config slug images)

            Nothing ->
                div [] []
        , amenitiesList property
        , div [ class "tagline" ] [ text tagline ]
        , div [ class "breakdown" ] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut sagittis mollis tincidunt. Duis vel interdum turpis, ac tempus justo. Mauris gravida suscipit sem, sit amet feugiat leo mollis eu. Aenean ac tempor mi. Praesent sed venenatis mi. Sed in cursus arcu, in molestie lorem. Cras in massa laoreet, iaculis magna vitae, accumsan ligula. Mauris eget scelerisque metus, tempus bibendum nisl. Curabitur scelerisque varius ex in consectetur. Phasellus bibendum bibendum eros, sit amet finibus dolor porta non. Proin pretium, dolor ac tincidunt euismod, lectus purus tincidunt leo, at condimentum risus purus scelerisque purus. Vivamus porttitor velit nec tortor vulputate, vitae pellentesque justo euismod." ]
        , div [ class "inline" ]
            [ button [ class "contact-btn", onClick ToggleContactForm ] [ text "Contact Us" ]
            , div [ class "price-box" ] [ text "Price: USD 34,000,000" ]
            ]
        , if model.showContactForm then
            div [ class "contact-box", id "contact-box" ] <| contactBox model generic

          else
            div [] []
        , div [ class "static-map" ] [ staticMap mapurl ]
        , if not <| model.showContactForm then
            div [ class "contact-box", id "contact-box" ] <| contactBox model generic

          else
            div [] []
        ]


contactBox : Model -> GenericAttributes -> List (Html Msg)
contactBox { showContactForm, email } { title } =
    [ --  div [ class "view-form", onClick ToggleContactForm ] [ text "Find out more" ]
      form [ class "contact-form", onSubmit ContactSubmit ]
        [ div []
            [ h1 [ class "title" ] [ text "Message us about this property" ]
            ]
        , div []
            [ input [ type_ "text", value title, disabled True ] []
            ]
        , div []
            [ input
                [ type_ "email"
                , placeholder "Email Address"
                , onInput EmailInput
                , required True
                ]
                []
            ]
        , div []
            [ textarea
                [ placeholder "Enter your message here"
                , onInput MessageInput
                , required True
                ]
                []
            ]
        , div []
            [ button
                [ type_ "submit"
                ]
                [ text "Submit" ]
            ]
        ]
    ]


isEmpty : String -> Bool
isEmpty =
    String.isEmpty << String.trim


staticMap : MapUrl -> Html Msg
staticMap mapurl =
    iframe
        [ src <| "https://www.google.com/maps/embed?pb=" ++ mapurl
        , height 450
        , width 600
        , style "border" "0"
        , attribute "frameborder" "0"
        , attribute "allowfullscreen" ""
        ]
        []


amenitiesList : Property -> Html Msg
amenitiesList property =
    div [ class "amenities" ]
        [ case property of
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
                    , li [ class "amenities-item" ]
                        [ span [ class "fa-li" ]
                            [ i [ class "fas fa-bed" ] [] ]
                        , text <| String.fromInt bedrooms ++ " bedrooms"
                        ]
                    , li [ class "amenities-item" ]
                        [ span [ class "fa-li" ]
                            [ i [ class "fas fa-bed" ] [] ]
                        , text <| String.fromInt bedrooms ++ " bedrooms"
                        ]
                    , li [ class "amenities-item" ]
                        [ span [ class "fa-li" ]
                            [ i [ class "fas fa-bed" ] [] ]
                        , text <| String.fromInt bedrooms ++ " bedrooms"
                        ]
                    ]
        ]


imageSlides : Config -> Slug -> List String -> List ( String, Html msg )
imageSlides config slug =
    let
        url img =
            config.apiUrl ++ "/images/" ++ slug ++ "/" ++ img
    in
    List.map (\x -> ( x, Image.slide (url x) Image.Cover ))


imageConfig : Gallery.Config
imageConfig =
    Gallery.config
        { id = "image-gallery"
        , transition = 500
        , width = Gallery.vw 60
        , height = Gallery.px 400
        }


toSession : Model -> Session
toSession model =
    model.session
