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
import qualified Rotom.Action.Emoji as EmojiA

import Data.Text (Text)
import Data.Aeson (FromJSON(..), (.:), withObject)
import Data.Int (Int64)

type API = "表情" :> (CreateAPI :<|> UpdateAPI :<|> DestroyAPI)

api :: XGUser -> ServerT API XGApp
api user = createAPI user
           :<|> updateAPI user
           :<|> destroyAPI user

-- | 表情相关表单定义。
data XGEmojiForm = EmojiForm { formName :: Text
                             , formLink :: Text
                             , formGroupId :: Int
                             }

instance FromJSON XGEmojiForm where
    parseJSON = withObject "EmojiForm" $ \o -> EmojiForm <$> o .: "名字"
                                               <*> o .: "链接"
                                               <*> o .: "分组id"

type CreateAPI = "创建"
                 :> ReqBody '[JSON] XGEmojiForm
                 :> Post '[JSON] XGEmoji

-- | 新建表情。
createAPI :: XGUser -> XGEmojiForm -> XGApp XGEmoji
createAPI _ EmojiForm{..} = queryOne q (formName, formLink, formGroupId) >>= EmojiA.throwNil
    where q = [sql| insert into "表情"
                    ("名字", "链接", "分组id")
                    values (?, ?, ?)
                    returning * |]

type UpdateAPI = Capture "id" Int
                 :> "更新"
                 :> ReqBody '[JSON] XGEmojiForm
                 :> Patch '[JSON] XGEmoji

-- | 更新表情。
updateAPI :: XGUser -> Int -> XGEmojiForm -> XGApp XGEmoji
updateAPI user id EmojiForm{..} = do
    EmojiA.guard user id
    let q = [sql| update "表情"
                  set "名字" = ?, "链接" = ?, "分组id" = ?
                  where id = ?
                  returning * |]
    queryOne q (formName, formLink, formGroupId, id) >>= EmojiA.throwNil

type DestroyAPI = Capture "id" Int
                  :> "删除"
                  :> Delete '[JSON] Int64

-- | 删除表情。
destroyAPI :: XGUser -> Int -> XGApp Int64
destroyAPI user id = do
    EmojiA.guard user id
    let q = [sql| delete from "表情"
                  where id = ? |]
    execute q [id]
