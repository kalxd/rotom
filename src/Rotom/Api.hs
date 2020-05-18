{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

-- | rotom接口汇总。
--
-- 相当于总路由入口和定义。

module Rotom.Api ( API
                 , api
                 , apiRoute
                 ) where

import Servant
import Rotom.Auth (RequireAuth)
import Rotom.Type

import qualified Rotom.Hand.Group as Group
import qualified Rotom.Hand.Emoji as Emoji

import qualified Database.PostgreSQL.Simple as PG

type AllAPI = Group.API :<|> Emoji.API

-- 所有路由汇总
type API = RequireAuth :> AllAPI

apiRoute :: ServerT API XGApp
apiRoute user = Group.api user :<|> Emoji.api user

api :: Proxy API
api = Proxy
