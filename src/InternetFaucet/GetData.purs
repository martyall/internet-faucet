module InternetFaucet.GetData
  ( getAllTokensForAddress
  ) where


import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Maybe (Maybe(..), maybe)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import Foreign (readString)
import Foreign.Index (index)
import InternetFaucet.Queries (allTokens)
import InternetFaucet.Types (Token)
import Simple.Graphql.Query (runQuery)
import Simple.Graphql.Types (runQueryT)

apiKey :: Maybe String
apiKey = Just "3dd139684cdbac5770ae58474524f9e8966886114dae590cba24d71230b16ed6QFCBa6XyRUWi3Np4Jb29lAROFkKL/A4fYGSUpq142IFlBeAOrvy2oqWx70yt7bpdG89o+HugbDHg4zHc73ljbwt/L2QkOl7N09E+Ky/6NTN89zuEikewTzVrhyBsJrOV1ssLINamDpgnDUg6Sx1b0p+DL2qiERRZvv92POGVweuHqKMEuorJWvVpKLI++OQ4ZxpaWwjoLhCNg4xSTPQsxg=="

getAllTokensForAddress :: String -> Aff (Array Token)
getAllTokensForAddress address = do
  { data:mdata, errors } <-
    runQueryT $ runQuery "http://68.183.31.54:5000/graphql"
                         apiKey
                         (allTokens {address})
  case mdata of
    Nothing -> (liftEffect $ throw $ show errors)
    Just {
      allErc721Tokens: {
        nodes
      }
    } -> pure $ nodes <#> \n ->
        let
          orders = maybe [] (_.assetData.nodes >>> map _.signedOrder) n.openSellOrders
          (awesomeLevel :: String) = either (const "") identity $ runExcept (index n.details.metadata "awesomeLevel" >>= readString)
        in
          { tokenId: n.tokenId
          , owner: n.owner.address
          , awesomeLevel
          , openOrders: orders
          }


