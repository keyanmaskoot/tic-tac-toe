{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE TemplateHaskell   #-}


module Vessel where


import ClassyPrelude hiding (join)
import Data.Function ((&))
import Data.Monoid ((<>))
import Data.Aeson (encode, decode)
import Network.WebSockets (WebSocketsData)
import qualified Network.WebSockets as WS
import Elm.Derive
import Player (ElmPlayer)
import Game (ElmGame, GameResult)
import qualified Game


data Vessel
  = Empty
  | GameNotFound
  | GameIsFull
  | InvalidRequest
  | RegistrationRequest    String ElmPlayer
  | RegistrationSuccessful ElmGame
  | PlayerLeaving          String ElmPlayer
  | GameStateRequest       String String
  | OpponentLeft
  | OpponentJoined         ElmGame
  | Collection            [Vessel]
  | GameStateUpdate        ElmGame
  | OpponentMoved          ElmGame
  | SetMarkAt              String ElmPlayer (Int, Int)
  | GameEnded   GameResult ElmGame
  deriving (Generic, Show)

deriveBoth defaultOptions ''Vessel

instance WebSocketsData Vessel where
  -- {{{
  fromLazyByteString bs =
    decode bs & fromMaybe Empty

  toLazyByteString =
    encode

  fromDataMessage dM =
    case dM of
      WS.Text byteStr _ ->
        WS.fromLazyByteString byteStr
      WS.Binary byteStr ->
        WS.fromLazyByteString byteStr
  -- }}}

instance Semigroup Vessel where
  -- {{{
  Empty           <> v               = v
  v               <> Empty           = v
  (Collection vs) <> v               = Collection (vs ++ [v])
  v               <> (Collection vs) = Collection (v : vs)
  v1              <> v2              = Collection [v1, v2]
  -- }}}

instance Monoid Vessel where
  -- {{{
  mempty = Empty
  -- }}}
