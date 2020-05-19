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
import qualified  Rotom.Action.Group as GroupA

import qualified Data.Text as T
import Data.Aeson (FromJSON(..), (.:), withObject)

-- | 分组API
type API = "分组" :> (AllAPI :<|> CreateAPI :<|> UpdateAPI)

api :: XGUser -> ServerT API XGApp
api user = allAPI user :<|> createAPI user :<|> updateAPI user

type AllAPI = "列表" :> Get '[JSON] [XGGroup]

-- | 更新、创建分组的http body。
newtype XGFormBody = FormBody { groupName :: T.Text }

instance FromJSON XGFormBody where
    parseJSON = withObject "FormBody" $ \o -> FormBody <$> o .: "名字"

-- | 查找所有分组。
allAPI :: XGUser -> XGApp [XGGroup]
allAPI User{..} = query q [userId]
    where q = [sql| select
                    "id", "名字", "用户id", "创建日期"
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
                    returning * |]

-- | 重命名分组，即更新
type UpdateAPI = Capture "id" Int
                 :> "更新"
                 :> ReqBody '[JSON] XGFormBody :> Patch '[JSON] XGGroup

-- | 更新分组。
updateAPI :: XGUser -> Int -> XGFormBody -> XGApp XGGroup
updateAPI user id FormBody{..} = do
    let q = [sql| update "分组"
                  set "名字" = ? where "id" = ?
                  returning * |]
    GroupA.guardAll id user
    queryOne q (groupName, id) >>= GroupA.throwNil
