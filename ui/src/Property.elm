module Property exposing (Property(..), Slug, fetch, fetchAll, genericAttrs, GenericAttributes)

import Api
import Api.Endpoint as Endpoint
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


type alias GenericAttributes =
    { title : String
    , slug : String
    , category : Category
    , tagline : String
    , size : Int
    }


type alias HomeAttributes =
    { title : String
    , slug : String
    , category : Category
    , tagline : String
    , size : Int
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
    , drainage : Bool
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
        |> required "drainage" Decode.bool
        |> Decode.map Land


decodeHome : Decoder Property
decodeHome =
    Decode.succeed HomeAttributes
        |> required "title" Decode.string
        |> required "slug" Decode.string
        |> required "category" categoryDecoder
        |> required "tagline" Decode.string
        |> required "size" Decode.int
        |> required "bedrooms" Decode.int
        |> required "bathrooms" Decode.int
        |> required "pool" Decode.bool
        |> Decode.map Home



-- Getters


genericAttrs : Property -> GenericAttributes
genericAttrs property =
    let
        extract { title, slug, category, tagline, size } =
            GenericAttributes title slug category tagline size
    in
    case property of
        Land attrs ->
            extract attrs

        Home attrs ->
            extract attrs


fetchAll : Category -> Http.Request (List Property)
fetchAll category =
    let
        params =
            [ Url.Builder.string "category" (Category.toString category) ]
    in
    Decode.list decoder
        |> Api.get (Endpoint.properties params)


fetch : String -> Http.Request Property
fetch slug =
    let
        params =
            [ Url.Builder.string "slug" slug ]
    in
    decoder
        |> Api.get (Endpoint.property params)
