module Pages.Property exposing (Model, Msg, init, toSession, update, view)

import Config exposing (Config)
import Enquiry as Enquiry exposing (EnquiryResponse)
import Gallery as Gallery
import Gallery.Image as Image
import Html exposing (Html, a, button, div, form, h1, hr, i, iframe, img, input, li, span, text, textarea, ul)
import Html.Attributes exposing (attribute, class, disabled, height, href, id, placeholder, required, src, style, type_, value, width)
import Html.Events exposing (..)
import Http
import Ports exposing (scrollTo)
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
    , enquiryStatus : WebData EnquiryResponse
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
      , enquiryStatus = NotAsked
      }
    , fetchProperty
    )


type Msg
    = PropertyLoaded (WebData Property)
    | ImageGalleryMsg Gallery.Msg
    | GoToContactForm
    | EmailInput String
    | MessageInput String
    | SubmitEnquiry String
    | EnquiryResult (WebData EnquiryResponse)


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

        EnquiryResult data ->
            ( { model | enquiryStatus = data }, Cmd.none )

        GoToContactForm ->
            ( model, scrollTo "contact-box" )

        EmailInput email ->
            ( { model | email = email }, Cmd.none )

        MessageInput message ->
            ( { model | message = message }, Cmd.none )

        SubmitEnquiry title ->
            ( model
            , Enquiry.sendEnquiry model.config
                { email = model.email
                , message = model.message
                , title = title
                }
                |> Http.toTask
                |> Task.attempt (RemoteData.fromResult >> EnquiryResult)
            )


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
        { title, slug, category, size, price, tagline, images, mapurl } =
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
            [ button [ class "contact-btn", onClick GoToContactForm ] [ text "Contact Us" ]
            , div [ class "price-box" ] [ text <| "Price: TTD " ++ price ]
            , div [ class "map-link" ] [ a [ href "https://goo.gl/maps/f2Cvdp1iS11Vu4wL9" ] [ text "See on Map" ] ]
            ]
        , div [ class "static-map" ] [ staticMap mapurl ]
        , div [ class "contact-box", id "contact-box" ] <| contactBox model generic
        ]


contactBox : Model -> GenericAttributes -> List (Html Msg)
contactBox { showContactForm, email, enquiryStatus } { title } =
    let
        enquirySent =
            case enquiryStatus of
                Success _ ->
                    True

                _ ->
                    False
    in
    [ form [ class "contact-form", onSubmit <| SubmitEnquiry title ]
        [ div [ class "mobile-contact" ]
            [ h1 [ class "title" ]
                [ i [ class "fas fa-mobile-alt" ] []
                , a [ href "tel:+18683683823" ] [ text "1-868-368-3823" ]
                , text " or "
                , a [ href "tel:+18686802978" ] [ text "1-868-680-2978" ]
                ]
            ]
        , div []
            [ h1 [ class "title" ]
                [ i [ class "far fa-envelope" ] []
                , text "Message us about this property"
                ]
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
                ([ type_ "submit"
                 ]
                    |> addIf enquirySent (disabled True)
                )
                [ text "Submit" ]
            ]
        , div [ class "info" ]
            (case enquiryStatus of
                Success _ ->
                    [ div [ class "success" ]
                        [ div [] [ i [ class "fas fa-check" ] [] ]
                        , div [] [ text " Enquiry Received. We'll get back to you soon." ]
                        ]
                    ]

                Failure err ->
                    [ div [ class "error" ]
                        [ div [] [ i [ class "fas fa-times" ] [] ]
                        , div [] [ text " There was an error sending your request. Please try again later." ]
                        ]
                    ]

                _ ->
                    []
            )
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
                ul [ class "fa-ul amenities-list -property" ]
                    [ li [ class "amenities-item" ]
                        [ span [ class "fa-li" ]
                            [ i [ class "fas fa-ruler-combined" ] [] ]
                        , text <| String.fromInt size ++ " sq ft."
                        ]
                    ]

            Home { size, pool, bedrooms, bathrooms } ->
                ul [ class "fa-ul amenities-list -property" ]
                    ([ li [ class "amenities-item" ]
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
                            [ i [ class "fas fa-bath" ] [] ]
                        , text <| String.fromInt bathrooms ++ " bathrooms"
                        ]
                     ]
                        |> addIf pool
                            (li [ class "amenities-item" ]
                                [ span [ class "fa-li" ]
                                    [ i [ class "fas fa-swimming-pool" ] []
                                    ]
                                , text "swimming pool"
                                ]
                            )
                    )
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
        , height = Gallery.vw 30
        }


addIf : Bool -> a -> List a -> List a
addIf pred item list =
    if pred then
        list ++ [ item ]

    else
        list


toSession : Model -> Session
toSession model =
    model.session
