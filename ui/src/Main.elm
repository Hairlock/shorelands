port module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav exposing (Key)
import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Value)
import Page exposing (Page)
import Pages.Blank as Blank
import Pages.Home as Home
import Pages.Properties as PropertiesPage
import Pages.Property as PropertyPage
import Property
import Route exposing (Route)
import Session exposing (Session, freshSession)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, top)



-- ---------------------------
-- PORTS
-- ---------------------------


port toJs : String -> Cmd msg



-- ---------------------------
-- MODEL
-- ---------------------------


type Model
    = NotFound Session
    | Redirect Session
    | Home Home.Model
    | Properties PropertiesPage.Model
    | Property PropertyPage.Model


init : Value -> Url -> Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.fromUrl url) (Redirect (freshSession navKey))


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            Home.init session
                |> updateWith Home HomeMsg model

        Just (Route.Properties category) ->
            PropertiesPage.init session category
                |> updateWith Properties PropertiesMsg model

        Just (Route.Property slug) ->
            PropertyPage.init session slug
                |> updateWith Property PropertyMsg model


updateWith :
    (subModel -> Model)
    -> (subMsg -> Msg)
    -> Model
    -> ( subModel, Cmd subMsg )
    -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


type Msg
    = Ignored
    | ChangedRoute (Maybe Route)
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | HomeMsg Home.Msg
    | PropertiesMsg PropertiesPage.Msg
    | PropertyMsg PropertyPage.Msg



-- ---------------------------
-- UPDATE
-- ---------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ChangedRoute route, _ ) ->
            changeRouteTo route model

        ( ClickedLink urlRequest, _ ) ->
            ( model, handleUrlRequest model urlRequest )

        ( HomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home HomeMsg model

        ( PropertiesMsg subMsg, Properties properties ) ->
            PropertiesPage.update subMsg properties
                |> updateWith Properties PropertiesMsg model

        ( PropertyMsg subMsg, Property property ) ->
            PropertyPage.update subMsg property
                |> updateWith Property PropertyMsg model

        ( _, _ ) ->
            ( model, Cmd.none )


handleUrlRequest : Model -> UrlRequest -> Cmd msg
handleUrlRequest model urlRequest =
    case urlRequest of
        Internal url ->
            Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)

        External url ->
            Nav.load url


toSession : Model -> Session
toSession page =
    case page of
        NotFound session ->
            session

        Redirect session ->
            session

        Home home ->
            Home.toSession home

        Properties properties ->
            PropertiesPage.toSession properties

        Property property ->
            PropertyPage.toSession property



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Document Msg
view model =
    let
        viewPage page toMsg content =
            let
                { title, body } =
                    Page.view page content
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Home home ->
            viewPage Page.Home HomeMsg (Home.view home)

        Properties properties ->
            viewPage Page.Properties PropertiesMsg (PropertiesPage.view properties)

        Property property ->
            viewPage Page.Property PropertyMsg (PropertyPage.view property)

        Redirect _ ->
            viewPage Page.Other (\_ -> Ignored) Blank.view

        NotFound _ ->
            { title = "Not found"
            , body =
                [ Html.map (\_ -> Ignored)
                    (div [] [ text "not found" ])
                ]
            }



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }
