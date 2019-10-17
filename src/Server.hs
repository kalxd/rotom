-- | rotom启动服务
{-# LANGUAGE DataKinds #-}
module Server ( runServer
              , api
              ) where

import Servant
import Network.Wai.Handler.Warp (run)

import Rotom.Middleware (appMiddleware)

type RootAPI = Get '[PlainText] String

rootAPI :: Server RootAPI
rootAPI = return "hello rotom"

type API = RootAPI

api :: Proxy API
api = Proxy

buildApp :: Application
buildApp = serve api rootAPI

runServer :: IO ()
runServer = run 8000 $ appMiddleware buildApp
