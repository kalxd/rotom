-- | 验证相关
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Type.Auth ( XGContextType
                       , MaybeAuth
                       , RequireAuth
                       , authContext
                       ) where

import Servant
import Servant.Server.Experimental.Auth

import Network.Wai (Request)
import Rotom.Type.User (XGUser(..))

type XGAuthHandler = AuthHandler Request
type XGContextType = '[XGAuthHandler XGUser, XGAuthHandler (Maybe XGUser)]

-- | 验证正确用户
type RequireAuth = AuthProtect "require-auth"

type instance AuthServerData (AuthProtect "require-auth") = XGUser

-- | 可能不存在的用户
type MaybeAuth = AuthProtect "maybe-auth"

type instance AuthServerData (AuthProtect "maybe-auth") = Maybe XGUser

requireHandler :: XGAuthHandler XGUser
requireHandler = mkAuthHandler $ \req -> pure $ User 1 "haoren"

maybeHandler :: XGAuthHandler (Maybe XGUser)
maybeHandler = mkAuthHandler $ \req -> pure Nothing

authContext :: Context XGContextType
authContext = requireHandler :. maybeHandler :. EmptyContext
