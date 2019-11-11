-- | 全局应用，大部分操作都应用于此。
-- | 写业务离不它。
module Rotom.Type ( module Rotom.Type
                  , Rotom.Type.App.XGApp
                  , Rotom.Type.User.XGUser(..)
                  , module Rotom.Type.Error
                  ) where

import Rotom.Type.App
import Rotom.Type.Config (XGAppConfig(appDB), readConfig)
import Rotom.Type.Error (XGError, transToServantError)
import Rotom.Type.User (XGUser(..))

import Control.Monad ((>=>))
import Control.Monad.IO.Class (liftIO)
import Data.Maybe (listToMaybe, isNothing)

import qualified Database.PostgreSQL.Simple as PG

-- | 直接生成数据连接
-- | 仅仅因为mkAuthHandler无法带有XGApp信息，无法调用已封装的接口。
createConn :: IO PG.Connection
createConn = PG.connect =<< appDB <$> readConfig

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
