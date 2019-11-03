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
import Rotom.App
import Rotom.Type.User (XGUser)

import qualified Database.PostgreSQL.Simple as PG

type RootAPI = Get '[PlainText] String

rootAPI :: XGApp String
rootAPI = pure "你好啊！"

type RunAPI = Get '[JSON] Int

runAPI :: XGApp [PG.Only Int]
runAPI = query_ "select 1"

type UserAPI = "user" :> Capture "id" Int :> Get '[JSON] XGUser

userAPI :: Int -> XGApp XGUser
userAPI id = do
    [user] <- query "select id, mkzi from yshu where id = ?" [id] :: XGApp [XGUser]
    pure $ user

-- 所有路由汇总
type API = RootAPI :<|> UserAPI

apiRoute :: ServerT API XGApp
apiRoute = rootAPI :<|> userAPI

api :: Proxy API
api = Proxy
