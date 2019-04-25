module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Html, a, div, footer, h2, img, li, nav, text, ul)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)


type Page
    = Other
    | Home
    | Properties


view : Page -> { title : String, content : Html msg } -> Document msg
view page { title, content } =
    { title = title
    , body = viewHeader page :: content :: [ viewFooter ]
    }


viewHeader : Page -> Html msg
viewHeader page =
    let
        navItems =
            [ { link = "/properties/all", title = "Properties" }
            , { link = "/faq", title = "FAQ" }
            , { link = "/about", title = "About Us" }
            ]

        navItemLi link title =
            li [ class "nav__item" ]
                [ a [ href link ] [ text title ]
                ]
    in
    nav [ class "nav" ]
        [ div [ class "container" ]
            [ div
                [ class "nav__brand" ]
                [ a [ href "/" ]
                    [ img [ src "/images/shorelands_logo.svg" ] [] ]
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
                    [ text "email" ]
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
