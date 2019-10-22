-- | 全局应用，大部分操作都应用于此。

module Rotom.App where

import Control.Monad.Trans.Reader
import Control.Monad.IO.Class (liftIO)

import Servant (Handler)
import qualified Database.PostgreSQL.Simple as PG

type XGApp = ReaderT PG.Connection Handler

appToHandler :: PG.Connection -> XGApp a -> Handler a
appToHandler = flip runReaderT

query :: (PG.ToRow q, PG.FromRow r) => PG.Query -> q -> XGApp [r]
query sql q = do
    conn <- ask
    liftIO $ PG.query conn sql q

query_ :: PG.FromRow r => PG.Query -> XGApp [r]
query_ sql = do
    conn <- ask
    liftIO $ PG.query_ conn sql
