module Api.Endpoint exposing (Endpoint, properties, property, request)

import Config exposing (Config)
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


url : Config -> List String -> List QueryParameter -> Endpoint
url config paths queryParams =
    Url.Builder.crossOrigin config.apiUrl
        ("api" :: paths)
        queryParams
        |> Endpoint


properties : Config -> List QueryParameter -> Endpoint
properties config params =
    url config [ "properties" ] params


property : Config -> List QueryParameter -> Endpoint
property config params =
    url config [ "property" ] params
