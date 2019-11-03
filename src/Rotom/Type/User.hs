-- | 用户
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}
module Rotom.Type.User where

import qualified Data.Text as T
import Data.Aeson ( ToJSON(..)
                  , (.=)
                  , object
                  )
import Database.PostgreSQL.Simple.FromRow (FromRow(..), field)

data XGUser = User { userId :: Int
                   , userName :: T.Text
                   } deriving (Show)

instance FromRow XGUser where
    fromRow = User <$> field <*> field

instance ToJSON XGUser where
    toJSON User{..} = object [ "id" .= userId
                             , "name" .= userName
                             ]
