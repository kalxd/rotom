-- | 全局应用，大部分操作都应用于此。
-- | 写业务离不它。
module Rotom.Type ( module Rotom.Type
                  , Rotom.Type.App.XGApp
                  , Rotom.Type.User.XGUser(..)
                  , module Rotom.Type.Error
                  ) where

import Rotom.Type.App
import Rotom.Type.Config (XGAppConfig, readConfig)
import Rotom.Type.Error (ToXGError)
import Rotom.Type.User (XGUser(..))

import Control.Monad ((>=>))
import Control.Monad.IO.Class (liftIO)
import Data.Maybe (listToMaybe, isNothing)

import qualified Database.PostgreSQL.Simple as PG

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
