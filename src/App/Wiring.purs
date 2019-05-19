module App.Wiring
  ( Wiring
  , make
  )
  where

import Prelude

-- import Effect.Aff.Bus as Bus
import Effect.Class (class MonadEffect, liftEffect)
import Fortmatic.Provider (fortmaticProvider)
import Network.Ethereum.Web3 (Provider)

type Wiring =
  { web3Provider :: Provider
  }


make
  :: forall m
   . MonadEffect m
  => m Wiring
make = liftEffect do
  web3Provider <- fortmaticProvider
  pure { web3Provider }
