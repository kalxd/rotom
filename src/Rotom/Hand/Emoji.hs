{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}
-- | 表情管理
module Rotom.Hand.Emoji ( API
                        , api
                        ) where

import Servant
import Rotom.Type
import Rotom.Type.Emoji

import Data.Text (Text)
import Data.Aeson (FromJSON(..), (.:), withObject)

type API = "表情" :> CreateAPI

api :: XGUser -> ServerT API XGApp
api user = createAPI user

throwNil :: Maybe a -> XGApp a
throwNil = liftMaybe NotFoundBNQK

-- | 表情相关表单定义。
data XGEmojiForm = EmojiForm { name :: Text
                             , link :: Text
                             , groupId :: Int
                             }

instance FromJSON XGEmojiForm where
    parseJSON = withObject "EmojiForm" $ \o -> EmojiForm <$> o .: "名字"
                                               <*> o .: "链接"
                                               <*> o .: "分组id"

type CreateAPI = "创建"
                 :> ReqBody '[JSON] XGEmojiForm
                 :> Post '[JSON] XGEmoji

c_emoji = [sql| insert into "表情"
                ("名字", "链接", "分组id")
                values (?, ?, ?)
                returning * |]

-- | 新建表情。
createAPI :: XGUser -> XGEmojiForm -> XGApp XGEmoji
createAPI _ EmojiForm{..} = queryOne c_emoji (name, link, groupId) >>= throwNil
