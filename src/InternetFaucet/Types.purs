module InternetFaucet.Types
  ( SignedOrder
  , Token
  ) where

import Foreign (Foreign)

type Token =
  { tokenId :: Number
  , owner :: String
  , metadata :: Foreign
  , openOrders :: Array SignedOrder
  }

type SignedOrder =
  { hash :: String
  , senderAddress :: String
  , makerAddress :: String
  , takerAddress :: String
  , makerAssetData :: String
  , takerAssetData :: String
  , exchangeAddress :: String
  , feeRecipientAddress :: String
  , expirationTimeSeconds :: Number
  , makerFee :: Number
  , takerFee :: Number
  , makerAssetAmount :: Number
  , takerAssetAmount :: Number
  , salt :: String
  , signature :: String
  }
