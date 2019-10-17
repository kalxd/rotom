-- | rotom启动服务
{-# LANGUAGE DataKinds #-}
module Server ( runServer
              , api
              ) where

import Rotom.App
import Rotom.Api (API, api, apiRoute)
import Rotom.Middleware (appMiddleware)

import Servant
import Network.Wai.Handler.Warp (run)

buildRoute :: Server API
buildRoute = hoistServer api (appToHandler 10) apiRoute

buildApp :: Application
buildApp = serve api buildRoute

runServer :: IO ()
runServer = run 8000 $ appMiddleware buildApp
