module Property.Category exposing (Category, categoryDecoder, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Url.Parser


type Category
    = Home
    | Land
    | All


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
        Home ->
            "Homes"

        Land ->
            "Land"

        All ->
            "All"


toCategory : String -> Maybe Category
toCategory str =
    case str of
        "homes" ->
            Just Home

        "land" ->
            Just Land

        "all" ->
            Just All

        _ ->
            Nothing
