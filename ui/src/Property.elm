module Property exposing (Property, fetchAll, title, slug)

import Api
import Api.Endpoint as Endpoint
import Property.Category exposing (Category, categoryDecoder)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Http

type Property = 
    Property Attributes


type alias Attributes =
    { title : String
    , slug : String
    , category : Category
    }


-- Getters

title : Property -> String
title (Property property) =
    property.title

slug : Property -> String
slug (Property property) =
    property.slug


-- Fetch All

fetchAll : Http.Request (List Property)
fetchAll =
    (Decode.list decoder)
        |> Api.get (Endpoint.properties)


decoder : Decoder Property
decoder =
    Decode.succeed Attributes
        |> required "title" Decode.string
        |> required "slug" Decode.string
        |> required "category" categoryDecoder
        |> Decode.map Property