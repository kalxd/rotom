-- | rotom启动服务
{-# LANGUAGE RecordWildCards #-}
module Server ( runServer
              , api
              ) where

import Rotom.Type
import Rotom.Type.Config (XGAppConfig(..), readConfig)

import Rotom.Api (API, api, apiRoute)
import Rotom.Middleware (appMiddleware)

import Servant
import Network.Wai.Handler.Warp (run)
import qualified Database.PostgreSQL.Simple as PG

buildRoute :: PG.Connection -> Server API
buildRoute conn = hoistServer api (appToHandler conn) apiRoute

buildApp :: PG.Connection -> Application
buildApp = serve api . buildRoute

runServer :: IO ()
runServer = do
    AppConfig{..} <- readConfig
    conn <- PG.connect appDB
    run 8000 $ appMiddleware $ buildApp conn
