{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}

-- | 全局错误定义
-- 虽然自定义了新错误类型，但XGApp只接受ServantErr，
-- 所以最后只保留下ServantErr，catchE无法正确catch到具体类型。

module Rotom.Type.Error ( XGError(..)
                        , ToXGError(..)
                        ) where

import Servant.Server
import Data.Aeson ((.=), object, encode)
import Data.Text as T

-- | 错误状态码
data XGErrorCode = NoYSHUCode -- 无用户
                 | NoFFZUCode -- 无分组
                 | NoBNQKCode -- 无表情
                 | AuthUserCode -- 用户权限
                 | OtherCode -- 其他，一般用于用户信息提示，只需要显示对应信息，不用处理该错误。
                 deriving (Eq)

pickServantError :: XGErrorCode -> ServantErr
pickServantError NoYSHUCode = err404
pickServantError NoFFZUCode = err404
pickServantError NoBNQKCode = err404
pickServantError AuthUserCode = err401
pickServantError OtherCode = err302

-- | 错误具体内容，目前我们只关心对应的错误码及可读信息。
newtype XGErrorInfo = ErrorInfo (XGErrorCode, T.Text)

errorInfo :: XGErrorCode -> T.Text -> XGErrorInfo
errorInfo = curry ErrorInfo

instance Enum XGErrorCode where
    fromEnum NoYSHUCode = 101
    fromEnum NoFFZUCode = 102
    fromEnum NoBNQKCode = 103
    fromEnum AuthUserCode = 201
    fromEnum OtherCode = 0

    toEnum 101 = NoYSHUCode
    toEnum 102 = NoFFZUCode
    toEnum 103 = NoBNQKCode
    toEnum 201 = AuthUserCode
    toEnum _ = OtherCode

class ToXGError a where
    toError :: a -> XGErrorInfo

    toServantError :: a -> ServantErr
    toServantError a = let ErrorInfo (code, msg) = toError a
                           err = pickServantError code
                           header = [("Content-Type", "application/json")]
                           body = encode $ object [ "err" .= msg
                                                  , "code" .= fromEnum code
                                                  ]
                       in err { errHeaders = header
                              , errBody = body
                              }

data XGError = NotFoundYSHU -- 未找到用户
             | NotFoundFFZZ -- 未找到分组
             | NotFoundBNQK -- 未找到表情
             | AuthUserNeed -- 用户未登录
             | OtherError T.Text -- 其他错误

instance ToXGError XGError where
    toError NotFoundYSHU = errorInfo NoYSHUCode "找不到用户。"
    toError NotFoundFFZZ = errorInfo NoFFZUCode "找不到分组。"
    toError NotFoundBNQK = errorInfo NoBNQKCode "找不到表情。"
    toError AuthUserNeed = errorInfo AuthUserCode "你他娘谁啊！"
    toError (OtherError msg) = errorInfo OtherCode msg

instance ToXGError T.Text where
    toError = errorInfo OtherCode

instance ToXGError (XGErrorCode, T.Text) where
    toError = uncurry errorInfo
