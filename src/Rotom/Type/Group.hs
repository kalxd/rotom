{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
-- | 分组类型

module Rotom.Type.Group where

import qualified Data.Text as T
import GHC.Generics
import Data.Aeson (ToJSON(..), (.=), object)
import Data.Time.LocalTime (ZonedTime)
import Database.PostgreSQL.Simple (FromRow(..))

data XGGroup = Group { groupId :: Int
                     , groupName :: T.Text
                     , groupUserId :: Int
                     , groupCreateAt :: ZonedTime
                     } deriving (FromRow, Generic)

instance ToJSON XGGroup where
    toJSON Group{..} = object [ "id" .= groupId
                              , "名字" .= groupName
                              , "用户id" .= groupUserId
                              , "创建日期" .= groupCreateAt
                              ]
