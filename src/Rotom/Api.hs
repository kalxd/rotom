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

import qualified Rotom.Hand.FFZU as FFZU

import qualified Database.PostgreSQL.Simple as PG

type AllAPI = FFZU.API

-- 所有路由汇总
type API = RequireAuth :> AllAPI

apiRoute :: ServerT API XGApp
apiRoute user = FFZU.api user

api :: Proxy API
api = Proxy
