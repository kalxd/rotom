-- | 全局错误定义
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Type.Error ( XGNotFound(..)
                        , XGAuthError(..)
                        , XGError(..)
                        , transToServantError
                        ) where

import Servant.Server
import qualified Data.ByteString.Lazy as BS
import Data.Aeson (ToJSON(..), (.=), object, encode)

-- | 本模块内部使用的Error结构，
-- | 主要用于输出JSON。
newtype XGErrorJSON = ErrorJSON (BS.ByteString)

instance ToJSON XGErrorJSON where
    toJSON (ErrorJSON msg) = object ["error" .= BS.unpack msg]

-- | 资源不存在错误
data XGNotFound = NoUser

instance ToJSON XGNotFound where
    toJSON NoUser = toJSON $ ErrorJSON "用户未找到"

-- | 验证错误
data XGAuthError = AuthUserError

instance ToJSON XGAuthError where
    toJSON AuthUserError = toJSON $ ErrorJSON "你他娘谁啊！"

-- | 内部错误
newtype XGServerError = InnerError (BS.ByteString)

instance ToJSON XGServerError where
    toJSON (InnerError msg) = toJSON $ ErrorJSON msg

-- | 全部错误
data XGError = NotFound XGNotFound
             | AuthError XGAuthError
             | ServerError XGServerError

encodeError :: ToJSON a => ServantErr -> a -> ServantErr
encodeError err body = err { errBody = encode body
                           , errHeaders = [("Content-Type", "application/json")]
                           }

-- | 转化成Servant内部的Error。
transToServantError :: XGError -> ServantErr
transToServantError (NotFound e) = encodeError err404 e
transToServantError (AuthError e) = encodeError err403 e
transToServantError (ServerError e) = encodeError err500 e
