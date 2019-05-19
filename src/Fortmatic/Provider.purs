module Fortmatic.Provider where

import Effect (Effect)
import Network.Ethereum.Web3.Types.Provider (Provider)

foreign import fortmaticProvider :: Effect Provider
