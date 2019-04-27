module Api.Endpoint exposing (Endpoint, properties, property, request)

import Http
import Property.Category exposing (Category)
import Url.Builder exposing (QueryParameter)


request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , withCredentials : Bool
    }
    -> Http.Request a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , withCredentials = config.withCredentials
        }


type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Url.Builder.crossOrigin "http://localhost:5000"
        ("api" :: paths)
        queryParams
        |> Endpoint


properties : List QueryParameter -> Endpoint
properties params =
    url [ "properties" ] params


property : List QueryParameter -> Endpoint
property params =
    url [ "property" ] params
