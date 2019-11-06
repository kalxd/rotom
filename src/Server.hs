-- | rotom启动服务
{-# LANGUAGE RecordWildCards #-}
module Server ( runServer
              , api
              ) where

import Servant

import Rotom.Type.Config (XGAppConfig(..), readConfig)
import Rotom.Type.App (appToHandler)
import Rotom.Type.Auth (XGContextType, authContext)
import Rotom.Api (API, api, apiRoute)
import Rotom.Middleware (appMiddleware)

import Network.Wai.Handler.Warp (run)
import qualified Database.PostgreSQL.Simple as PG

buildApp :: PG.Connection -> Application
buildApp conn = serveWithContext api authContext serverApi
    where serverApi = hoistServerWithContext api (Proxy :: Proxy XGContextType) trans apiRoute
          trans = appToHandler conn

runServer :: IO ()
runServer = do
    AppConfig{..} <- readConfig
    conn <- PG.connect appDB
    run 8000 $ appMiddleware $ buildApp conn
