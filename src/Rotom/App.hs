-- | 全局应用，大部分操作都应用于此。

module Rotom.App where

import Control.Monad.Trans.Reader
import Control.Monad.Trans.Except
import Control.Monad.IO.Class (liftIO)

import Servant (Handler(..))
import qualified Database.PostgreSQL.Simple as PG

import Rotom.Type.Error (XGError, transToServantError)

type XGApp = ReaderT PG.Connection (ExceptT XGError IO)

appToHandler :: PG.Connection -> XGApp a -> Handler a
appToHandler conn = Handler . withExceptT transToServantError . flip runReaderT conn

query :: (PG.ToRow q, PG.FromRow r) => PG.Query -> q -> XGApp [r]
query sql q = do
    conn <- ask
    liftIO $ PG.query conn sql q

query_ :: PG.FromRow r => PG.Query -> XGApp [r]
query_ sql = do
    conn <- ask
    liftIO $ PG.query_ conn sql
