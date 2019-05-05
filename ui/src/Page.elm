module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Html, a, div, footer, h2, i, img, li, nav, option, select, text, ul)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import Property.Category exposing (Category(..))
import Route exposing (Route(..))


type Page
    = Other
    | Home
    | Properties
    | Property


view : Page -> { title : String, content : Html msg } -> Document msg
view page { title, content } =
    { title = title
    , body = [ div [ class "main" ] (viewHeader page :: content :: [ viewFooter ]) ]
    }


viewHeader : Page -> Html msg
viewHeader page =
    let
        navItems =
            [ { link = Route.href (Route.Properties Homes), title = "Houses" }
            , { link = Route.href (Route.Properties Land), title = "Land" }
            , { link = Route.href (Route.Properties All), title = "All Properties" }
            , { link = Route.href Route.Home, title = "Contact Us" }
            ]

        navItemLi link title =
            li [ class "nav__item" ]
                [ a [ link ] [ text title ]
                ]
    in
    nav [ class <| "nav" ++ pageToString page ]
        [ div [ class "container" ]
            [ div
                [ class "nav__brand" ]
                [ a [ href "/" ]
                    [ img [ src "/logo/shorelands.png" ] [] ]
                ]
            , ul [ class "nav__items" ]
                (List.map (\{ link, title } -> navItemLi link title) navItems)
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "footer" ]
        [ div [ class "container" ]
            [ h2 [ class "footer-hero" ]
                [ text "Looking for a property? Send us an"
                , a [ class "hero__link", href "mailto: cdsealy@hotmail.com" ]
                    [ text " email" ]
                ]
            ]
        , div [ class "container" ]
            [ ul [ class "footer-links" ]
                [ li [ class "footer-links__item" ]
                    [ a [ href "/properties", class "footer-links__item-link" ]
                        [ text "Properties" ]
                    ]
                , li [ class "footer-links__item" ]
                    [ a [ href "/faq", class "footer-links__item-link" ]
                        [ text "Faq" ]
                    ]
                , li [ class "footer-links__item" ]
                    [ a [ href "/about-us", class "footer-links__item-link" ]
                        [ text "About us" ]
                    ]
                ]
            ]
        ]


pageToString : Page -> String
pageToString page =
    case page of
        Home ->
            " -home"

        Properties ->
            " -properties"

        Property ->
            " -property"

        Other ->
            " -other"
