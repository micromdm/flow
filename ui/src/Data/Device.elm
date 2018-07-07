module Data.Device exposing (..)


type alias Device =
    { platform : String
    , version : Version
    , uuid : String
    , serial : String
    }


type Version
    = Version
        { major : Int
        , minor : Int
        , patch : Int
        , build : String
        }


versionToString : Version -> String
versionToString (Version r) =
    (toString r.major) ++ "." ++ (toString r.minor) ++ "." ++ (toString r.patch)


withBuildID : Version -> String
withBuildID version =
    case version of
        Version r ->
            (versionToString version) ++ " " ++ r.build
