{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
-- | rotom配置文件。
--
-- 动态读取配置。
module Rotom.Config ( XGAppConfig
                    , readConfig
                    ) where

import Data.Yaml

import Data.Default (Default(..))
import System.Directory (doesFileExist)

-- | 全局配置
data XGAppConfig = AppConfig { appHost :: String
                             , appPort :: Int
                             } deriving (Show)

instance Default XGAppConfig where
    def = AppConfig {..}
        where appHost = "http://localhost"
              appPort = 3000

instance FromJSON XGAppConfig where
    parseJSON (Object o) = AppConfig
                           <$> o .:? "host" .!= appHost def
                           <*> o .:? "port" .!= appPort def

readConfig :: IO XGAppConfig
readConfig = do
    let configPath = "config/config.yaml"
    isExist <- doesFileExist configPath
    case isExist of
        True -> decodeFileThrow configPath
        False -> def
