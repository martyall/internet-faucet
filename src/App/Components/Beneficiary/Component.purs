module App.Components.Beneficiary.Component where

import Prelude

import App.Monad (M)
import Control.Monad.Reader (ask)
import Data.Array (filter)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), fst)
import Effect.Aff (Milliseconds(..), delay)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import InternetFaucet.GetData (getAllTokensForAddress)
import InternetFaucet.Types (Token)

type State =
  { tokens :: Array (Tuple Token RedeemState)
  }

data Query a
  = Initialize a
  | Redeem Token a


data RedeemState
  = Idle (Maybe (Either String String))
  | Redeeming

data Message = FOOClicked

type DSL = H.ComponentDSL State Query Message M
type HTML = H.ComponentHTML Query
type Input = Unit

component :: H.Component HH.HTML Query Input Message M
component =
  H.lifecycleComponent
    { initialState: const {tokens: []}
    , render
    , eval
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    , receiver: const Nothing
    }

render :: State -> HTML
render {tokens} = HH.div [HP.class_ $ H.ClassName "Beneficiary"]
  [ HH.div_ [ HH.text "Your services:" ]
  , HH.ul_ $ tokens <#> renderTokens
  ]
  where
    renderTokens (Tuple token redeemState) = HH.li_
      [ HH.text token.awesomeLevel
      , HH.span_ case redeemState of
          Idle result ->
            [ HH.button [HP.class_ $ H.ClassName "Beneficiary-action"
                , HE.onClick $ HE.input_ $ Redeem token] [HH.text "Redeem"]
            , case result of
                Nothing -> HH.text ""
                Just (Left err) -> HH.text $ " - err: " <> err
                Just (Right txHash) -> HH.text $ " - txHash: " <> txHash
            ]
          Redeeming ->
            [ HH.text " Redeeming NFT"
            ]
      ]

eval :: Query ~> DSL
eval = case _ of
  Initialize next -> do
    {userAddress} <- ask
    void $ H.fork do
      tokens <- H.liftAff (getAllTokensForAddress "0x404bca21ccafdab4b91bf028fa9fbc1fbaf7a2a9")
        <#> filter (\t -> t.owner == show userAddress)
        <#> map (flip Tuple (Idle Nothing))
      H.modify_ _{tokens = tokens}
    pure next
  Redeem token next -> do
    let
      setRedeemState redeemSt =
        H.modify_ \s -> s{tokens = s.tokens <#> \token' ->
          if fst token' /= token then token' else Tuple token redeemSt}
    -- TODO start transactions for buying and donating the service here
    setRedeemState Redeeming
    H.liftAff $ delay $ Milliseconds 2000.0
    setRedeemState $ Idle $ Just $ Right "0xaaaaaasdasd1231qweads"

    pure next
