-- | 导出rotom的layout。
module Main (main) where

import Prelude hiding (putStrLn)

import Data.Text.IO (putStrLn)
import Servant (layoutWithContext)

import Rotom.Api (api)
import Rotom.Auth (emptyContext)

main :: IO ()
main = putStrLn $ layoutWithContext api emptyContext
