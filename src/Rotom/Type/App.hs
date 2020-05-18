-- | Servant整个服务类型定义
{-# LANGUAGE RecordWildCards #-}
module Rotom.Type.App ( module Control.Monad.Trans.Reader
                      , module Rotom.Type.App
                      ) where

import Servant
import Control.Monad.Trans.Reader
import Control.Monad.IO.Class (liftIO)
import Data.Maybe (maybe)

import Rotom.Type.Error (ToXGError(..))
import Rotom.Type.Config (XGAppConfig(..), XGDB(..))

import qualified Database.PostgreSQL.Simple as PG
import qualified Data.Text as Text

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
    DBConfig{..} <- asks appDB
    let info = PG.defaultConnectInfo { PG.connectHost = Text.unpack dbAddr
                                     , PG.connectPort = fromIntegral dbPort
                                     , PG.connectUser = Text.unpack dbUser
                                     , PG.connectPassword = Text.unpack dbPassword
                                     , PG.connectDatabase = Text.unpack dbName
                                     }
    liftIO $ PG.connect info

-- | 抛出一个我们的错误
throw :: ToXGError e => e -> XGApp a
throw = throwError . toServantError
