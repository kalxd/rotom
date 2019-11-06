-- | Servant整个服务类型定义
module Rotom.Type.App ( module Control.Monad.Trans.Reader
                      , module Rotom.Type.App
                      ) where

import Servant
import Control.Monad.Trans.Reader
import Control.Monad.Trans.Except
import Control.Monad.Trans.Class (lift)
import Database.PostgreSQL.Simple (Connection)

import Rotom.Type.Error (XGError, transToServantError)

-- | 整个Handler包含的环境
type XGApp = ReaderT Connection (ExceptT XGError IO)

-- | XGApp a ~ Handler a
appToHandler :: Connection -> XGApp a -> Handler a
appToHandler conn = Handler . withExceptT transToServantError . flip runReaderT conn

-- | 抛出一个我们的错误
throw :: XGError -> XGApp a
throw = lift . throwE
