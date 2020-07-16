-- | 常用逻辑都写在这里。
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
module Rotom.Action.Group where

import Rotom.Type
import Rotom.Type.Group

-- | 强制取出分组。
throwNil :: Maybe XGGroup -> XGApp XGGroup
throwNil = liftMaybe NoGroupE

-- | 从数据查询得到一个分组，若不存在，直接抛出对应错误。
guardGroup :: Int -> XGApp XGGroup
guardGroup id = queryOne q [id] >>= throwNil
    where q = [sql| select
                    "id", "名字", "用户id", "创建日期", (select count(*) from "表情" where "表情"."分组id" = "分组".id) as "数量"
                    from "分组"
                    where id = ? |]

-- | 确保用户只能操作自己分组内的表情。
guardOwner :: XGUser -> XGGroup -> XGApp XGGroup
guardOwner User{..} group@Group{..} = if userId == groupUserId
                                      then pure group
                                      else throw AuthOwnE

-- | 合并所有检查要素。
guard :: XGUser -> Int -> XGApp XGGroup
guard user id  = guardGroup id >>= guardOwner user
