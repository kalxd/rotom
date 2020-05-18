{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

-- | 表情基本类型
module Rotom.Type.Emoji where

import GHC.Generics (Generic)
import Data.Text (Text)
import Data.Time.LocalTime (ZonedTime)
import Data.Aeson (ToJSON(..), object, (.=))
import Database.PostgreSQL.Simple (FromRow)

data XGBNQK = BNQK { bnqkID :: Int
                   , bnqkName :: Text
                   , bnqkLink :: Text
                   , bnqkGroupID :: Int
                   , bnqkUserID :: Int
                   , bnqkCreateAt :: ZonedTime
                   } deriving (Generic, FromRow)

instance ToJSON XGBNQK where
    toJSON BNQK{..} = object [ "id" .= bnqkID
                             , "name" .= bnqkName
                             , "link" .= bnqkLink
                             , "groupid" .= bnqkGroupID
                             , "userid" .= bnqkUserID
                             , "createat" .= bnqkCreateAt
                             ]
