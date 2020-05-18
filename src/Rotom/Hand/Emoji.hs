{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE QuasiQuotes #-}

-- | 表情管理
module Rotom.Hand.Emoji ( API
                        , api
                        ) where

import Servant
import Rotom.Type
import Rotom.Type.Emoji

import GHC.Generics (Generic)
import Data.Text (Text)
import Data.Aeson (FromJSON)

type API = "表情" :> CreateAPI

api :: XGUser -> ServerT API XGApp
api user = createAPI user

throwNil :: Maybe a -> XGApp a
throwNil = liftMaybe NotFoundBNQK

---
--- 创建表情
---
data XGCreateForm = CreateForm { name :: Text
                               , link :: Text
                               , group :: Int
                               } deriving (Generic)

instance FromJSON XGCreateForm

type CreateAPI = ReqBody '[JSON] XGCreateForm :> Post '[JSON] XGBNQK

createsql = [sql| insert into "bnqk"
                  ("mkzi", "lmjp", "ffzu_id", "yshu_id")
                  values (?, ?, ?, ?)
                  returning * |]

createAPI :: XGUser -> XGCreateForm -> XGApp XGBNQK
createAPI User{..} CreateForm{..} = do
    queryOne createsql (name, link, group, userId) >>= throwNil
