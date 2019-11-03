-- | 用户

module Rotom.Type.User where

import qualified Data.Text as T
import Database.PostgreSQL.Simple.FromRow ( FromRow(..)
                                          , field
                                          )

data XGUser = User { userId :: Int
                   , userName :: T.Text
                   } deriving (Show)

instance FromRow XGUser where
    fromRow = User <$> field <*> field
