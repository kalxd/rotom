-- | Servant整个服务类型定义
module Rotom.Type.App ( module Control.Monad.Trans.Reader
                      , module Rotom.Type.App
                      ) where

import Servant
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class (liftIO)
import Data.Maybe (maybe)

import Rotom.Type.Error (ToXGError(..))
import Rotom.Type.Config (XGAppConfig(..))

import qualified Database.PostgreSQL.Simple as PG

-- | 整个Handler包含的环境。
type XGApp = ReaderT XGAppConfig Handler

-- | XGApp a ~ Handler a
appToHandler :: XGAppConfig -> XGApp a -> Handler a
appToHandler = flip runReaderT

-- | 强制从Maybe a取得值，
-- 若不存在，抛出错误。
liftMaybe :: ToXGError e => e -> Maybe a -> XGApp a
liftMaybe e = maybe (throw e) pure

-- | 新建数据库连接。
askConnect :: XGApp PG.Connection
askConnect = do
    info <- asks appDB
    liftIO $ PG.connect info

-- | 抛出一个我们的错误
throw :: ToXGError e => e -> XGApp a
throw = throwError . toServantError
