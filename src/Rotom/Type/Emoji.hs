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

data XGEmoji = Emoji { emojiId :: Int
                     , emojiName :: Text
                     , emojiLink :: Text
                     , emojiGroupId :: Int
                     , emojiCreateAt :: ZonedTime
                     } deriving (Generic, FromRow)

instance ToJSON XGEmoji where
    toJSON Emoji{..} = object [ "id" .= emojiId
                              , "名字" .= emojiName
                              , "链接" .= emojiLink
                              , "分组id" .= emojiGroupId
                              , "创建日期" .= emojiCreateAt
                              ]
