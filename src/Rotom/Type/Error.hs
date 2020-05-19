-- | 全局错误定义
-- 虽然自定义了新错误类型，但XGApp只接受ServerError，
-- 所以最后只保留下ServerError，catchE无法正确catch到具体类型。
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
module Rotom.Type.Error ( XGError(..)
                        , ToXGError(..)
                        ) where

import Servant.Server
import Data.Aeson ((.=), object, encode)
import Data.Text as T

data XGError = NoUserE -- 未找到用户
             | NoGroupE -- 未找到分组
             | NoEmojiE -- 未找到表情
             | AuthE -- 用户未登录
             | AuthOwnE -- 从属不正确
             | OtherE T.Text -- 其他错误

-- | 转化为自定义错误码。
customErrorCode :: XGError -> Int
customErrorCode NoUserE = 101
customErrorCode NoGroupE = 102
customErrorCode NoEmojiE = 103
customErrorCode AuthE = 201
customErrorCode AuthOwnE = 202
customErrorCode _ = 1

-- | 转化成servant对应错误，即http对应状态码。
toHttpError :: XGError -> ServantErr
toHttpError NoUserE = err404
toHttpError NoGroupE = err404
toHttpError NoEmojiE = err404
toHttpError AuthE = err401
toHttpError AuthOwnE = err401
toHttpError _ = err500

-- | 转化成对应错误提示。
errMsg :: XGError -> T.Text
errMsg NoUserE = "用户未找到。"
errMsg NoGroupE = "分组未找到。"
errMsg NoEmojiE = "表情未找到。"
errMsg AuthE = "你他娘谁啊？！"
errMsg AuthOwnE = "该资源不属于你。"
errMsg (OtherE msg) = msg

-- 内部中间状态，方便写实例。
newtype XGErrorInfo = ErrorBox (XGError, T.Text)

-- | 内部错误相互转化。
class ToXGError a where
    toError :: a -> XGErrorInfo

    toServantError :: a -> ServantErr
    toServantError a = let ErrorBox (e, msg) = toError a
                           code = customErrorCode e
                           err = toHttpError e
                           header = [("Content-Type", "application/json")]
                           body = encode $ object [ "内容" .= msg
                                                  , "错误码" .= fromEnum code
                                                  ]
                       in err { errHeaders = header
                              , errBody = body
                              }

instance ToXGError XGError where
    toError (OtherE msg) = curry ErrorBox (OtherE msg) msg
    toError e = curry ErrorBox e $ errMsg e

instance ToXGError T.Text where
    toError = toError . OtherE

instance ToXGError (XGError, T.Text) where
    toError = ErrorBox
