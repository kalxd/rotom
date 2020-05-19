-- | 表情共用业务。
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
module Rotom.Action.Emoji where

import Rotom.Type
import Rotom.Type.Emoji

-- | 强行取出表情。
throwNil :: Maybe XGEmoji -> XGApp XGEmoji
throwNil = liftMaybe NoEmojiE

-- | 查询表情，若不存在直接抛错。
guard :: XGUser -> Int -> XGApp XGEmoji
guard User{..} id = queryOne q (userId, id) >>= throwNil
    where q = [sql| select
                    "表情".id, "表情"."名字", "表情"."链接", "表情"."分组id", "表情"."创建日期"
                    from "表情" join "分组"
                    on "分组"."用户id" = ? and "表情".id = ? and "表情"."分组id" = "分组".id
                    limit 1 |]
