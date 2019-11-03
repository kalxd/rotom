-- | 全局错误定义
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Type.Error where

import Servant.Server
import qualified Data.ByteString.Lazy as BS

-- | 未找到
data XGNotFound = NoUser

-- | 内部错误
newtype XGServerError = InnerError (BS.ByteString)

-- | 全部错误
data XGError = NotFound XGNotFound
             | ServerError XGServerError

transToServantError :: XGError -> ServantErr
transToServantError (NotFound e) = handleNotFound e
    where handleNotFound NoUser = err404 { errBody = "用户未找到" }
transToServantError (ServerError e) = handlerInnerError e
    where handlerInnerError (InnerError s) = err500 { errBody = s }
