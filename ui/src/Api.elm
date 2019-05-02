module Api exposing (get, post)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (required)


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


post : Endpoint -> Body -> Decoder a -> Http.Request a
post url body decoder =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = Http.expectJson decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }
