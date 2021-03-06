-- | 分组
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Hand.Group ( API
                        , api
                        ) where

import Servant
import Rotom.Type
import Rotom.Type.Group
import Rotom.Type.Emoji
import qualified  Rotom.Action.Group as GroupA

import qualified Data.Text as T
import Data.Aeson (FromJSON(..), (.:), withObject)
import qualified Database.PostgreSQL.Simple as PG

-- | 分组API
type API = "分组"
           :> (AllAPI
               :<|> CreateAPI
               :<|> UpdateAPI
               :<|> DestroyAllAPI
               :<|> DestroySoftAPI
               :<|> EmojiAPI)

api :: XGUser -> ServerT API XGApp
api user = allAPI user
           :<|> createAPI user
           :<|> updateAPI user
           :<|> destroyAllAPI user
           :<|> destroySoftAPI user
           :<|> emojiAPI user

type AllAPI = "列表" :> Get '[JSON] [XGGroup]

-- | 更新、创建分组的http body。
newtype XGFormBody = FormBody { groupName :: T.Text }

instance FromJSON XGFormBody where
    parseJSON = withObject "FormBody" $ \o -> FormBody <$> o .: "名字"

-- | 查找所有分组。
allAPI :: XGUser -> XGApp [XGGroup]
allAPI User{..} = query q [userId]
    where q = [sql| select
                    "id", "名字", "用户id", "创建日期", (select count(*) from "表情" where "表情"."分组id" = "分组".id) as "数量"
                    from "分组"
                    where "用户id" = ? |]

-- | 创建分组
type CreateAPI = "创建"
                 :> ReqBody '[JSON] XGFormBody
                 :> Post '[JSON] XGGroup

createAPI :: XGUser -> XGFormBody -> XGApp XGGroup
createAPI User{..} FormBody{..} = queryOne q (groupName, userId) >>= GroupA.throwNil
    where q = [sql| insert into "分组"
                    ("名字", "用户id")
                    values (?, ?)
                    returning *, 0 |]

-- | 重命名分组，即更新
type UpdateAPI = Capture "id" Int
                 :> "更新"
                 :> ReqBody '[JSON] XGFormBody
                 :> Patch '[JSON] XGGroup

-- | 更新分组。
updateAPI :: XGUser -> Int -> XGFormBody -> XGApp XGGroup
updateAPI user id FormBody{..} = do
    let q = [sql| update "分组"
                  set "名字" = ? where "id" = ?
                  returning *, (select count(*) from "表情" where "表情"."分组id" = "分组.id") |]
    GroupA.guard user id
    queryOne q (groupName, id) >>= GroupA.throwNil

type DestroyAllAPI = Capture "id" Int
                     :> "全部清除"
                     :> Delete '[JSON] ()

-- | 硬性删除分组。
destroyAllAPI :: XGUser -> Int -> XGApp ()
destroyAllAPI user id = do
    GroupA.guard user id
    transaction $ \conn -> do
        let q1 = [sql| delete from "表情" where "分组id" = ? |]
        let q2 = [sql| delete from "分组" where "id" = ? |]
        PG.execute conn q1 [id]
        PG.execute conn q2 [id]
    pure ()

data XGMoveForm = MoveForm { moveId :: Int }

instance FromJSON XGMoveForm where
    parseJSON = withObject "MoveForm" $ \o -> o .: "下个分组id"

type DestroySoftAPI = Capture "id" Int
                      :> ReqBody '[JSON] XGMoveForm
                      :> Patch '[JSON] ()

-- | 软性删除分组。
destroySoftAPI :: XGUser -> Int -> XGMoveForm -> XGApp ()
destroySoftAPI user id MoveForm{..} = do
    const <$> GroupA.guard user id <*> GroupA.guard user moveId
    transaction $ \conn -> do
        let q1 = [sql| update "表情" set "分组id" = ? where id = ? |]
        let q2 = [sql| delete from "分组" where id = ? |]
        PG.execute conn q1 (moveId, id)
        PG.execute conn q2 [id]
    pure ()

type EmojiAPI = Capture "id" Int
                :> "表情列表"
                :> Get '[JSON] [XGEmoji]

-- | 一组分组下的表情。
emojiAPI :: XGUser -> Int -> XGApp [XGEmoji]
emojiAPI user id = do
    GroupA.guard user id
    let q = [sql| select
                  "id", "名字", "链接", "分组id", "创建日期"
                  from "表情"
                  where "分组id" = ?
                  order by id desc |]
    query q [id]
