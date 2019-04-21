module Property.Category exposing (Category, categoryDecoder, toString)

import Json.Decode as Decode exposing (Decoder)

type Category 
    = Home 
    | Land


categoryDecoder : Decoder Category
categoryDecoder =
    Decode.string
        |> Decode.andThen
            (\category ->
                case category of
                    "home" ->
                        Decode.succeed Home

                    "land" ->
                        Decode.succeed Land

                    _ ->
                        Decode.fail <| "Unknown property category!"
            )

toString : Category -> String
toString category =
    case category of
        Home ->
            "Home"

        Land ->
            "Land"