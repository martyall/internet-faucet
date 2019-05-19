module App.Api.Forwarder where


import Prelude

import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Network.Ethereum.Core.HexString (HexString)


foreign import data Order :: Type
foreign import buyItem_ :: Order -> EffectFnAff HexString

buyItem :: Order -> Aff HexString
buyItem = buyItem_ >>> fromEffectFnAff
