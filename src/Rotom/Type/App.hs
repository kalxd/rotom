-- | Servant整个服务类型定义
module Rotom.Type.App ( module Control.Monad.Trans.Reader
                      , module Rotom.Type.App
                      ) where

import Servant
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class (liftIO)

import Rotom.Type.Error (XGError, ToXGError(..))
import Rotom.Type.Config (XGAppConfig(..))

import qualified Database.PostgreSQL.Simple as PG

-- | 整个Handler包含的环境。
type XGApp = ReaderT XGAppConfig Handler

-- | XGApp a ~ Handler a
appToHandler :: XGAppConfig -> XGApp a -> Handler a
appToHandler = flip runReaderT

-- | 新建数据库连接。
askConnect :: XGApp PG.Connection
askConnect = do
    info <- asks appDB
    liftIO $ PG.connect info

-- | 抛出一个我们的错误
throw :: XGError -> XGApp a
throw = throwError . toServantError
