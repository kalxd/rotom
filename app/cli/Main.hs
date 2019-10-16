-- | 导出rotom的layout。
module Main (main) where

import Prelude hiding (putStrLn)

import Data.Text.IO (putStrLn)
import Servant (layout)

import Server (api)

main :: IO ()
main = putStrLn $ layout api
