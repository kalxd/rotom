-- | 验证相关
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Auth ( XGContextType
                  , MaybeAuth
                  , RequireAuth
                  , authContext
                  , emptyContext
                  ) where

import Servant
import Servant.Server.Experimental.Auth
import Network.Wai (Request, requestHeaders)
import qualified Database.PostgreSQL.Simple as PG

import qualified Data.ByteString as BS
import Data.List (find)
import Data.Maybe (maybe)
import Control.Monad.Trans.Reader (runReaderT)

import Rotom.Type
import Rotom.Type.App (XGApp, throw)
import Rotom.Type.Config (XGAppConfig(appDB))
import Rotom.Type.Error (XGError(..), ToXGError(..))
import qualified Rotom.Hand.User as UserH

type XGAuthHandler = AuthHandler Request
type XGContextType = '[XGAuthHandler XGUser, XGAuthHandler (Maybe XGUser)]

-- | 验证正确用户
type RequireAuth = AuthProtect "require-auth"

type instance AuthServerData (AuthProtect "require-auth") = XGUser

-- | 可能不存在的用户
type MaybeAuth = AuthProtect "maybe-auth"

type instance AuthServerData (AuthProtect "maybe-auth") = Maybe XGUser

-- 查找头部
findRotomVer :: Request -> Maybe (BS.ByteString)
findRotomVer = fmap snd . find f . requestHeaders
    where f (name, _) = name == "rotom"

findUser :: Request -> XGApp (Maybe XGUser)
findUser req = case findRotomVer req of
                   Nothing -> pure Nothing
                   Just ver -> UserH.findByToken ver

requireHandler :: XGAppConfig -> XGAuthHandler XGUser
requireHandler config = mkAuthHandler $ \req -> do
    runReaderT (findUser req >>= liftMaybe AuthUserNeed) config

maybeHandler :: XGAppConfig -> XGAuthHandler (Maybe XGUser)
maybeHandler config = mkAuthHandler $ \req -> runReaderT (findUser req) config

authContext :: XGAppConfig -> Context XGContextType
authContext config = requireHandler config :. maybeHandler config :. EmptyContext

-- | 为layout准备的Context，我们不能为了显示路由信息，就需要启动一个数据库。
emptyContext :: Context XGContextType
emptyContext = justHandler :. nothingHandler :. EmptyContext
    where justHandler :: XGAuthHandler XGUser
          justHandler = mkAuthHandler $ const (throwError err404)

          nothingHandler :: XGAuthHandler (Maybe XGUser)
          nothingHandler = mkAuthHandler $ const (pure Nothing)
