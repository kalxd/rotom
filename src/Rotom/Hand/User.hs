{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
-- | 用户相关

module Rotom.Hand.User where

import Servant
import Rotom.Type
import Rotom.Type.User (XGUser)

import qualified Data.ByteString as BS

s_token = [sql| select
              id, 用户名, from 用户视图
              where token = ?
              |]
-- | 找出我们的用户。
findByToken :: BS.ByteString -> XGApp (Maybe XGUser)
findByToken token = queryOne s_token [token]
