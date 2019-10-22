-- | rotom接口汇总。
--
-- 相当于总路由入口和定义。
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Api ( API
                 , api
                 , apiRoute
                 ) where

import Servant
import Rotom.App

import qualified Database.PostgreSQL.Simple as PG

type API = RootAPI

api :: Proxy API
api = Proxy

apiRoute :: ServerT API XGApp
apiRoute = rootAPI

type RootAPI = Get '[PlainText] String

rootAPI :: XGApp String
rootAPI = pure "你好啊！"

type RunAPI = Get '[JSON] Int

runAPI :: XGApp [PG.Only Int]
runAPI = query_ "select 1"
