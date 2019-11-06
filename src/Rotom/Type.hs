-- | 全局应用，大部分操作都应用于此。
-- | 写业务离不它。

module Rotom.Type where

import Control.Monad.Trans.Reader
import Control.Monad.Trans.Except
import Control.Monad.Trans.Class (lift)
import Control.Monad ((>=>))
import Control.Monad.IO.Class (liftIO)
import Data.Maybe (listToMaybe, isNothing)

import Servant (Handler(..))
import qualified Database.PostgreSQL.Simple as PG

import Rotom.Type.Error (XGError, transToServantError)

type XGApp = ReaderT PG.Connection (ExceptT XGError IO)

appToHandler :: PG.Connection -> XGApp a -> Handler a
appToHandler conn = Handler . withExceptT transToServantError . flip runReaderT conn

-- | 数据库查询。
query :: (PG.ToRow q, PG.FromRow r) => PG.Query -> q -> XGApp [r]
query sql q = do
    conn <- ask
    liftIO $ PG.query conn sql q

-- | 数据库查询。
query' :: PG.FromRow r => PG.Query -> XGApp [r]
query' sql = do
    conn <- ask
    liftIO $ PG.query_ conn sql

-- | 数据库查询，只找一个元素。
queryOne :: (PG.ToRow q, PG.FromRow r) => PG.Query -> q -> XGApp (Maybe r)
queryOne sql q = query sql q >>= pure . listToMaybe

-- | 数据库查询，只找一个元素。
queryOne' :: PG.FromRow r => PG.Query -> XGApp (Maybe r)
queryOne' = query' >=> pure . listToMaybe

-- | 强制获取一个值，为空值就抛出错误。
queryJust :: (PG.ToRow q, PG.FromRow r) => XGError -> PG.Query -> q -> XGApp r
queryJust e sql q = do
    r <- queryOne sql q
    case r of
        Nothing -> lift $ throwE e
        Just r' -> pure r'

-- | 强制获取一个值，为空值就抛出错误。
queryJust' :: PG.FromRow r => XGError -> PG.Query -> XGApp r
queryJust' e sql = do
    r <- queryOne' sql
    case r of
        Nothing -> lift $ throwE e
        Just r' -> pure r'
