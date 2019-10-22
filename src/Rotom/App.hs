-- | 全局应用，大部分操作都应用于此。

module Rotom.App where

import Control.Monad.Trans.Reader
import Servant (Handler)
import qualified Database.PostgreSQL.Simple as PG

type XGApp = ReaderT PG.Connection Handler

appToHandler :: PG.Connection -> XGApp a -> Handler a
appToHandler = flip runReaderT
