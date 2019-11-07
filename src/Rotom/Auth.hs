-- | 验证相关
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Auth ( XGContextType
                  , MaybeAuth
                  , RequireAuth
                  , authContext
                  ) where

import Servant
import Servant.Server.Experimental.Auth
import Network.Wai (Request, requestHeaders)
import qualified Database.PostgreSQL.Simple as PG

import qualified Data.ByteString as BS
import Data.ByteString.Char8 (unpack)
import Data.List (find)
import Data.Maybe (listToMaybe, maybe)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Reader (runReaderT)

import Rotom.Type
import Rotom.Type.App (XGApp, throw)

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

requireHandler :: XGAuthHandler XGUser
requireHandler = mkAuthHandler $ \req -> do
    conn <- liftIO createConn
    user <- runReaderT (findUser req) conn
    maybe (throwError err403{ errBody = "你他娘谁啊！" }) pure user

maybeHandler :: XGAuthHandler (Maybe XGUser)
maybeHandler = mkAuthHandler $ \req -> liftIO createConn >>= runReaderT (findUser req)

authContext :: Context XGContextType
authContext = requireHandler :. maybeHandler :. EmptyContext
