{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}

-- | 分组
module Rotom.Hand.FFZU ( API
                       , api
                       ) where

import Servant
import Rotom.Type
import Rotom.Type.FFZU

import qualified Data.Text as T
import Data.Aeson (FromJSON(..))
import GHC.Generics

-- | 分组API
type API = "ffzu" :> (CreateAPI :<|> UpdateAPI)

api :: XGUser -> ServerT API XGApp
api user = createAPI user :<|> updateAPI user

--
-- 创建分组
--
newtype XGFormBody = FormBody { ffzuName :: T.Text
                              } deriving (Generic)
instance FromJSON XGFormBody

type CreateAPI = ReqBody '[JSON] XGFormBody
                 :> Post '[JSON] XGFFZU

ccsql = [sql| insert into "ffzu"
              ("mkzi", "yshu_id")
              values (?, ?)
              returning * |]

createAPI :: XGUser -> XGFormBody -> XGApp XGFFZU
createAPI User{..} FormBody{..} = do
    queryOne ccsql (ffzuName, userId) >>= liftMaybe NotFoundFFZU

--
-- 重命名分组，即更新
--
type UpdateAPI = Capture "id" Int :> ReqBody '[JSON] XGFormBody :> Put '[JSON] XGFFZU

uusql = [sql| update "ffzu"
              set "mkzi" = ? where id = ?
              returning * |]

updateAPI :: XGUser -> Int -> XGFormBody -> XGApp XGFFZU
updateAPI _ id FormBody{..} = queryOne uusql (ffzuName, id) >>= liftMaybe NotFoundFFZU
