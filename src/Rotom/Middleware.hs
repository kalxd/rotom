-- | 中间件
module Rotom.Middleware (appMiddleware) where

import Network.Wai (Middleware)
import Network.Wai.Middleware.RequestLogger (logStdout)

appMiddleware :: Middleware
appMiddleware = logStdout
