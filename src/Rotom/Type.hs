-- | 全局应用，大部分操作都应用于此。
-- | 写业务离不它。
module Rotom.Type ( module Rotom.Type
                  , module Rotom.Type.App
                  , Rotom.Type.User.XGUser(..)
                  , module Rotom.Type.Error
                  , sql
                  ) where

import Rotom.Type.App
import Rotom.Type.Error
import Rotom.Type.Config (XGAppConfig, readConfig)
import Rotom.Type.User (XGUser(..))

import Control.Monad ((>=>))
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (catchE)
import Data.Maybe (listToMaybe, isNothing)
import Data.Int (Int64)

import qualified Database.PostgreSQL.Simple as PG
import Database.PostgreSQL.Simple.SqlQQ (sql)

-- | 数据库查询。
query :: (PG.ToRow q, PG.FromRow r) => PG.Query -> q -> XGApp [r]
query sql q = do
    conn <- askConnect
    liftIO $ PG.query conn sql q

-- | 数据库查询。
query' :: PG.FromRow r => PG.Query -> XGApp [r]
query' sql = do
    conn <- askConnect
    liftIO $ PG.query_ conn sql

-- | 数据库查询，只找一个元素。
queryOne :: (PG.ToRow q, PG.FromRow r) => PG.Query -> q -> XGApp (Maybe r)
queryOne sql q = query sql q >>= pure . listToMaybe

-- | 数据库查询，只找一个元素。
queryOne' :: PG.FromRow r => PG.Query -> XGApp (Maybe r)
queryOne' = query' >=> pure . listToMaybe

-- | 执行sql，返回执行状态。
execute :: PG.ToRow q => PG.Query -> q -> XGApp Int64
execute sql q = do
    conn <- askConnect
    liftIO $ PG.execute conn sql q

-- | 执行sql，返回执行状态。
execute' :: PG.Query -> XGApp Int64
execute' sql = do
    conn <- askConnect
    liftIO $ PG.execute_ conn sql

-- | 执行sql，更新或插入多条记录，返回执行状态。
executeMany :: PG.ToRow q => PG.Query -> [q] -> XGApp Int64
executeMany sql q = do
    conn <- askConnect
    liftIO $ PG.executeMany conn sql q

-- | 开启事务，`PG.withTransaction`再封装。
-- | 低层次封装，毕竟要直接操作IO。
transaction :: (PG.Connection -> IO a) -> XGApp a
transaction action = do
    conn <- askConnect
    liftIO $ PG.withTransaction conn $ action conn
