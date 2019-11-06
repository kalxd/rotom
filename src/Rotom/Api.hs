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
import Rotom.Type.Auth (MaybeAuth)

import qualified Database.PostgreSQL.Simple as PG

type RootAPI = Get '[PlainText] String

rootAPI :: XGApp String
rootAPI = pure "你好啊！"

type RunAPI = Get '[JSON] Int

runAPI :: XGApp [PG.Only Int]
runAPI = query' "select 1"

type UserAPI = "user" :> Capture "id" Int :> MaybeAuth :> Get '[JSON] (Maybe XGUser)

userAPI :: Int -> Maybe XGUser -> XGApp (Maybe XGUser)
userAPI = const pure

-- 所有路由汇总
type API = RootAPI :<|> UserAPI

apiRoute :: ServerT API XGApp
apiRoute = rootAPI :<|> userAPI

api :: Proxy API
api = Proxy
