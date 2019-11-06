-- | 全局应用，大部分操作都应用于此。
-- | 写业务离不它。
module Rotom.Type ( module Rotom.Type
                  , Rotom.Type.App.XGApp
                  ) where

import Rotom.Type.App
import Rotom.Type.Error (XGError, transToServantError)

import Control.Monad ((>=>))
import Control.Monad.IO.Class (liftIO)
import Data.Maybe (listToMaybe, isNothing)

import qualified Database.PostgreSQL.Simple as PG

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
        Nothing -> throw e
        Just r' -> pure r'

-- | 强制获取一个值，为空值就抛出错误。
queryJust' :: PG.FromRow r => XGError -> PG.Query -> XGApp r
queryJust' e sql = do
    r <- queryOne' sql
    case r of
        Nothing -> throw e
        Just r' -> pure r'
