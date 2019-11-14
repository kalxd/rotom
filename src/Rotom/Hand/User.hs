{-# LANGUAGE OverloadedStrings #-}
-- | 用户相关

module Rotom.Hand.User where

import Rotom.Type
import Rotom.Type.User (XGUser)

import qualified Data.ByteString as BS

-- |找出我们的用户。
findByToken :: BS.ByteString -> XGApp (Maybe XGUser)
findByToken token = queryOne "select id, mkzi from yshu where md5(id || mkzi) = ?" [token]
