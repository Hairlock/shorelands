module Property.Category exposing (Category(..), categoryDecoder, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Url.Parser


type Category
    = Homes
    | Land
    | All


categoryDecoder : Decoder Category
categoryDecoder =
    Decode.string
        |> Decode.andThen
            (\category ->
                case category of
                    "homes" ->
                        Decode.succeed Homes

                    "land" ->
                        Decode.succeed Land

                    "all" ->
                        Decode.succeed All

                    _ ->
                        Decode.fail <| "Unknown property category!"
            )


urlParser : Url.Parser.Parser (Category -> a) a
urlParser =
    Url.Parser.custom "Category"
        (\str ->
            toCategory str
        )


toString : Category -> String
toString category =
    case category of
        Homes ->
            "homes"

        Land ->
            "land"

        All ->
            "all"


toCategory : String -> Maybe Category
toCategory str =
    case str of
        "homes" ->
            Just Homes

        "land" ->
            Just Land

        "all" ->
            Just All

        _ ->
            Nothing
