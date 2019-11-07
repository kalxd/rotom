-- | Servant整个服务类型定义
{-# LANGUAGE RecordWildCards #-}
module Rotom.Type.App ( module Control.Monad.Trans.Reader
                      , module Rotom.Type.App
                      ) where

import Servant
import Control.Monad.Trans.Reader
import Database.PostgreSQL.Simple (Connection)

import Rotom.Type.Error (XGError, transToServantError)

-- | 整个Handler包含的环境
type XGApp = ReaderT Connection Handler

-- | XGApp a ~ Handler a
appToHandler :: Connection -> XGApp a -> Handler a
appToHandler = flip runReaderT

-- | 抛出一个我们的错误
throw :: XGError -> XGApp a
throw = throwError . transToServantError
