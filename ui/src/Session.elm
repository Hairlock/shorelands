module Session exposing (Session, freshSession, navKey)

import Browser.Navigation as Nav


type Session
    = Guest Nav.Key


navKey : Session -> Nav.Key
navKey (Guest key) =
    key


freshSession : Nav.Key -> Session
freshSession key =
    Guest key
