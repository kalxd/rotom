-- | 全局应用，大部分操作都应用于此。

module Rotom.App where

import Control.Monad.Trans.Reader
import Servant (Handler)

type XGApp = ReaderT Int Handler

appToHandler :: Int -> XGApp a -> Handler a
appToHandler n = flip runReaderT n
