-- | 导出rotom的layout。
module Main (main) where

import Prelude hiding (putStrLn)

import Data.Text.IO (putStrLn)
import Servant (layoutWithContext)

import Rotom.Api (api)
import Rotom.Type.Auth (authContext)

main :: IO ()
main = putStrLn $ layoutWithContext api authContext
