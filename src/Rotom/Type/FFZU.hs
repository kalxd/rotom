{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
-- | 分组类型

module Rotom.Type.FFZU where

import GHC.Generics (Generic)
import qualified Data.Text as T
import Data.Aeson (ToJSON(..), (.=), object)
import Data.Time.LocalTime (ZonedTime)
import Database.PostgreSQL.Simple (FromRow(..))

data XGFFZU = FFZU { ffzzID :: Int
                   , ffzzName :: T.Text
                   , ffzzUserID :: Int
                   , ffzzCreateAt :: ZonedTime
                   } deriving (Generic, FromRow)

instance ToJSON XGFFZU where
    toJSON FFZU{..} = object [ "id" .= ffzzID
                             , "name" .= ffzzName
                             , "createat" .= ffzzCreateAt
                             ]

