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
import Rotom.Type.Error (XGError(..), ToXGError(..))

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
findUser req = do
    ver <- pure $ findRotomVer req
    case ver of
        Nothing -> pure Nothing
        Just ver' -> queryOne "select id, mkzi from yshu where id = ?" [ver']

requireHandler :: PG.Connection -> XGAuthHandler XGUser
requireHandler conn = mkAuthHandler $ \req -> do
    user <- runReaderT (findUser req) conn
    maybe (throwError $ toServantError AuthUserNeed) pure user

maybeHandler :: PG.Connection -> XGAuthHandler (Maybe XGUser)
maybeHandler conn = mkAuthHandler $ \req -> runReaderT (findUser req) conn

authContext :: PG.Connection -> Context XGContextType
authContext conn = requireHandler conn :. maybeHandler conn :. EmptyContext

-- | 为layout准备的Context，我们不能为了显示路由信息，就需要启动一个数据库。
emptyContext :: Context XGContextType
emptyContext = justHandler :. nothingHandler :. EmptyContext
    where justHandler :: XGAuthHandler XGUser
          justHandler = mkAuthHandler $ const (throwError err404)

          nothingHandler :: XGAuthHandler (Maybe XGUser)
          nothingHandler = mkAuthHandler $ const (pure Nothing)
