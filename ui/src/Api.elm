module Api exposing (get)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (required)
import Http exposing (Body, Expect)


get : Endpoint -> Decoder a -> Http.Request a
get url decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson decoder
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , withCredentials = False
        }


