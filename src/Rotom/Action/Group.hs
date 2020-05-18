-- | 常用逻辑都写在这里。

module Rotom.Action.Group where

import Rotom.Type
import Rotom.Type.Group

-- | 强制取出分组。
throwNil :: Maybe XGGroup -> XGApp XGGroup
throwNil = liftMaybe NoGroupE

-- | 从数据查询得到一个分组，若不存在，直接抛出对应错误。
guardGroup :: Int -> XGApp XGGroup
guardGroup = undefined
