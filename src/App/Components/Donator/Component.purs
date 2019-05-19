module App.Components.Donator.Component where

import Prelude

import App.Api.Forwarder (buyItem)
import App.Monad (M)
import Chanterelle.Internal.Utils (pollTransactionReceipt)
import Control.Monad.Reader (ask)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple(..), fst)
import Effect.Aff (delay)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (logShow)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Unsafe.Coerce (unsafeCoerce)

type Service =
  { provider :: String
  , service :: String
  , price :: Int
  }

data BuyState
  = Idle (Maybe (Either String String))
  | Obtaining
  | Donating

type State =
  { services :: Array (Tuple Service BuyState)
  }

data Query a
  = Initialize a
  | NewInput Input a
  | DonateService Service a

type Message = Unit

type DSL = H.ComponentDSL State Query Message M
type HTML = H.ComponentHTML Query
type Input = Unit

component
  :: H.Component HH.HTML Query Input Message M
component =
  H.lifecycleComponent
    { initialState: const {services: []}
    , render
    , eval
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    , receiver: Just <<< H.action <<< NewInput
    }

render :: State -> HTML
render {services} = HH.div [HP.class_ $ H.ClassName "Donator"]
  [ HH.div_ [ HH.text "services:" ]
  , HH.ul_ $ services <#> renderService
  ]
  where
  renderService (Tuple s buyState) = HH.li_
    [ HH.text $ s.service <> " by " <> s.provider <> " for " <> show s.price <> "TOK"
    , HH.span_ case buyState of
        Idle result ->
          [ HH.button [HP.class_ $ H.ClassName "Donator-action", HE.onClick $ HE.input_ $ DonateService s] [HH.text "donate"]
          , case result of
              Nothing -> HH.text ""
              Just (Left err) -> HH.text $ " - err: " <> err
              Just (Right txHash) -> HH.text $ " - txHash: " <> txHash
          ]
        Obtaining ->
          [ HH.text " Enquiring NFT"
          ]
        Donating ->
          [ HH.text " Donating NFT"
          ]
    ]

eval
  :: Query ~> DSL
eval = case _ of
  Initialize next -> do
    -- TODO start loading all available services
    H.liftAff $ delay $ Milliseconds 2000.0
    H.modify_ _{services =
      [ Tuple { provider: "ISP1", service: "1GB/Week", price: 1} (Idle Nothing)
      , Tuple { provider: "ISP2", service: "1GB/Week", price: 1} (Idle Nothing)
      , Tuple { provider: "ISP1", service: "10GB/Week", price: 10} (Idle Nothing)
      , Tuple { provider: "ISP2", service: "10GB/Week", price: 10} (Idle Nothing)
      ]}
    pure next
  DonateService service next -> do
    {web3Provider} <- ask
    let
      setBuyState buySt =
        H.modify_ \s -> s{services = s.services <#> \service' ->
          if fst service' /= service then service' else Tuple service buySt}
    -- TODO start transactions for buying and donating the service here
    setBuyState Obtaining
    let
      order = unsafeCoerce unit
    orderTxHash <- H.liftAff $ buyItem order
    orderTxHashRes <- pollTransactionReceipt orderTxHash web3Provider
    logShow orderTxHashRes
    setBuyState Donating
    H.liftAff $ delay $ Milliseconds 2000.0
    setBuyState $ Idle $ Just $ Right "0xaaaaaasdasd1231qweads"
    pure next
  NewInput unit next -> do
    pure next
