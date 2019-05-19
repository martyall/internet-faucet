module App.Components.Donator.Component where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple(..), fst)
import Effect.Aff (delay)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

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
  | DonateService Service a

type Message = Unit

type DSL m = H.ComponentDSL State Query Message m
type HTML = H.ComponentHTML Query
type Input = Unit

component
  :: forall m
   . MonadAff m
  => H.Component HH.HTML Query Input Message m
component =
  H.lifecycleComponent
    { initialState: const {services: []}
    , render
    , eval
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    , receiver: const Nothing
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
  :: forall m
   . MonadAff m
   => Query ~> DSL m
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
    let
      setBuyState buySt =
        H.modify_ \s -> s{services = s.services <#> \service' ->
          if fst service' /= service then service' else Tuple service buySt}
    -- TODO start transactions for buying and donating the service here
    setBuyState Obtaining
    H.liftAff $ delay $ Milliseconds 2000.0
    setBuyState Donating
    H.liftAff $ delay $ Milliseconds 2000.0
    setBuyState $ Idle $ Just $ Right "0xaaaaaasdasd1231qweads"
    pure next
