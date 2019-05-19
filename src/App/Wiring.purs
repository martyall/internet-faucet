module App.Wiring
  ( Wiring
  , make
  )
  where

import Prelude

import Data.Array (index)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import Fortmatic.Provider (fortmaticProvider)
import Network.Ethereum.Web3 (Address, Provider, runWeb3)
import Network.Ethereum.Web3.Api (eth_getAccounts)
import Unsafe.Coerce (unsafeCoerce)

type Wiring =
  { provider :: Provider
  , userAddress :: Address
  }


make :: Aff Wiring
make = do
  provider <- liftEffect $ fortmaticProvider
  userAddress <- getUserAddress $ unsafeCoerce provider
  pure { provider, userAddress }
  where
    getUserAddress provider = do
      eUser <- runWeb3 provider $ eth_getAccounts
      case eUser of
        Left err -> liftEffect $ throw $ show $ err
        Right accounts -> case accounts `index` 0 of
          Nothing -> liftEffect $ throw "No primary account found from Metamask provider."
          Just userAddress -> pure userAddress
