-- | rotom启动服务
{-# LANGUAGE DataKinds #-}
module Server ( runServer
              , api
              ) where

import Rotom.App
import Rotom.Middleware (appMiddleware)

import Servant
import Network.Wai.Handler.Warp (run)

type RootAPI = Get '[PlainText] String

rootAPI :: ServerT RootAPI XGApp
rootAPI = return "hello rotom"

type API = RootAPI

api :: Proxy API
api = Proxy

buildRoute :: Server API
buildRoute = hoistServer api (appToHandler 10) rootAPI

buildApp :: Application
buildApp = serve api buildRoute

runServer :: IO ()
runServer = run 8000 $ appMiddleware buildApp
