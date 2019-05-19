module InternetFaucet.Types
  ( SignedOrder
  , Token
  ) where

type Token =
  { tokenId :: Number
  , owner :: String
  , awesomeLevel :: String
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
