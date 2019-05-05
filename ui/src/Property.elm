module Property exposing (GenericAttributes, MapUrl, Property(..), Slug, fetch, fetchAll, genericAttrs)

import Api
import Api.Endpoint as Endpoint
import Config exposing (Config)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Property.Category as Category exposing (Category, categoryDecoder)
import Url.Builder


type Property
    = Land LandAttributes
    | Home HomeAttributes


type alias Slug =
    String


type alias MapUrl =
    String


type alias GenericAttributes =
    { title : String
    , slug : String
    , category : Category
    , tagline : String
    , size : Int
    , price : String
    , images : List String
    , mapurl : String
    }


type alias HomeAttributes =
    { title : String
    , slug : String
    , category : Category
    , tagline : String
    , size : Int
    , price : String
    , images : List String
    , mapurl : String
    , bedrooms : Int
    , bathrooms : Int
    , pool : Bool
    }


type alias LandAttributes =
    { title : String
    , slug : String
    , category : Category
    , tagline : String
    , size : Int
    , price : String
    , lots : Int
    , images : List String
    , mapurl : String
    , drainage : Bool
    , planning : Bool
    }


decoder : Decoder Property
decoder =
    Decode.oneOf
        [ decodeLand
        , decodeHome
        ]


decodeLand : Decoder Property
decodeLand =
    Decode.succeed LandAttributes
        |> required "title" Decode.string
        |> required "slug" Decode.string
        |> required "category" categoryDecoder
        |> required "tagline" Decode.string
        |> required "size" Decode.int
        |> required "price" Decode.string
        |> required "lots" Decode.int
        |> required "images" (Decode.list Decode.string)
        |> required "mapurl" Decode.string
        |> required "drainage" Decode.bool
        |> required "planning" Decode.bool
        |> Decode.map Land


decodeHome : Decoder Property
decodeHome =
    Decode.succeed HomeAttributes
        |> required "title" Decode.string
        |> required "slug" Decode.string
        |> required "category" categoryDecoder
        |> required "tagline" Decode.string
        |> required "size" Decode.int
        |> required "price" Decode.string
        |> required "images" (Decode.list Decode.string)
        |> required "mapurl" Decode.string
        |> required "bedrooms" Decode.int
        |> required "bathrooms" Decode.int
        |> required "pool" Decode.bool
        |> Decode.map Home



-- Getters


genericAttrs : Property -> GenericAttributes
genericAttrs property =
    let
        extract { title, slug, category, tagline, size, price, images, mapurl } =
            GenericAttributes title slug category tagline size price images mapurl
    in
    case property of
        Land attrs ->
            extract attrs

        Home attrs ->
            extract attrs


fetchAll : Config -> Category -> Http.Request (List Property)
fetchAll config category =
    let
        params =
            [ Url.Builder.string "category" (Category.toString category) ]
    in
    Decode.list decoder
        |> Api.get (Endpoint.properties config params)


fetch : Config -> String -> Http.Request Property
fetch config slug =
    let
        params =
            [ Url.Builder.string "slug" slug ]
    in
    decoder
        |> Api.get (Endpoint.property config params)
