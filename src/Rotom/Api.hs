-- | rotom接口汇总。
--
-- 相当于总路由入口和定义。
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}
module Rotom.Api ( API
                 , api
                 , apiRoute
                 ) where

import Servant
import Rotom.Type
import Rotom.Type.User (XGUser)

import qualified Database.PostgreSQL.Simple as PG

type RootAPI = Get '[PlainText] String

rootAPI :: XGApp String
rootAPI = pure "你好啊！"

type RunAPI = Get '[JSON] Int

runAPI :: XGApp [PG.Only Int]
runAPI = query' "select 1"

type UserAPI = "user" :> Capture "id" Int :> Get '[JSON] (Maybe XGUser)

userAPI :: Int -> XGApp (Maybe XGUser)
userAPI id = do
    user <- queryOne "select id, mkzi from yshu where id = ?" [id]
    pure $ user

-- 所有路由汇总
type API = RootAPI :<|> UserAPI

apiRoute :: ServerT API XGApp
apiRoute = rootAPI :<|> userAPI

api :: Proxy API
api = Proxy
