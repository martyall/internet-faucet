module InternetFaucet.Queries
  ( allTokens
  , AllErc721TokensResponse
  , AllErc721TokensResponseNode
  ) where


import Data.Maybe (Maybe)
import Foreign (Foreign)
import InternetFaucet.Types (SignedOrder)
import Simple.Graphql.Types (GraphQlQuery(..))
import Type.Proxy (Proxy(..))


-------------------------------------------------------------------------------
-- | allTokens
-------------------------------------------------------------------------------
allTokens
  :: { address :: String }
  -> GraphQlQuery { address :: String } AllErc721TokensResponse
allTokens variables =
  GraphQlQuery
    { query
    , variables
    }
    (Proxy :: Proxy AllErc721TokensResponse)
  where
    query = """
    query AllTokens($address: String) {
      allErc721Tokens(condition: { contractAddress: $address }) {
        nodes {
          tokenId
          owner: erc721OwnerByTokenIdAndContractAddress {
            address: ownerAddress
          }
          details: erc721MetadatumByTokenIdAndContractAddress {
            metadata
          }
          openSellOrders: erc721AssetDatumByTokenIdAndContractAddress {
            assetData: signedOrderErc721MakerAssetDataByAssetData {
              nodes {
                signedOrder: signedOrderByHash {
                  hash
                  senderAddress
                  makerAddress
                  takerAddress
                  makerAssetData
                  takerAssetData
                  exchangeAddress
                  feeRecipientAddress
                  expirationTimeSeconds
                  makerFee
                  takerFee
                  makerAssetAmount
                  takerAssetAmount
                  salt
                  signature
                }
              }
            }
          }
        }
      }
    }
    """

type AllErc721TokensResponse = {
  allErc721Tokens :: {
    nodes :: Array AllErc721TokensResponseNode
  }
}

type AllErc721TokensResponseNode =
  { tokenId :: Number
  , owner :: { address :: String }
  , details :: { metadata :: Foreign }
  , openSellOrders ::
      Maybe { assetData ::
              { nodes :: Array
                  { signedOrder :: SignedOrder
                  }
              }
            }

  }
