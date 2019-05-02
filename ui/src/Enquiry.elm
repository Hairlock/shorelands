module Enquiry exposing (EnquiryResponse, sendEnquiry)

import Api
import Api.Endpoint as Endpoint
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as JP
import Json.Encode as Encode exposing (Value)
import Task exposing (Task)


type alias EnquiryResponse =
    { success : Bool }


encodeEnquiry : { email : String, message : String, title : String } -> Value
encodeEnquiry { email, message, title } =
    Encode.object
        [ ( "title", Encode.string title )
        , ( "email", Encode.string email )
        , ( "message", Encode.string message )
        ]


sendEnquiry : Config -> { email : String, message : String, title : String } -> Http.Request EnquiryResponse
sendEnquiry config enquiry =
    let
        body =
            encodeEnquiry enquiry
                |> Http.jsonBody
    in
    Api.post (Endpoint.enquiry config)
        body
        (Decode.succeed EnquiryResponse
            |> JP.required "success" Decode.bool
        )
