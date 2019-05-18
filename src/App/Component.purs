module App.Component
  ( component
  , Query
  ) where

import Prelude
import Halogen as H
import App.Monad (M)
import Halogen.HTML as HH
import App.Components.MintNFT.Component as MintNFT
import App.Components.TransferNFT.Component as TransferNFT
import App.Components.YourNFT.Component as YourNFT
import App.Components.InternetNFT.Component as InternetNFT
import Data.Maybe (Maybe(..))
import Data.Either.Nested (Either4)
import Halogen.Component.ChildPath as CP
import Data.Functor.Coproduct.Nested (Coproduct4)

type State = Unit

data Query a
  = Initialize a
  -- | RouteChange Route a

type ChildQuery = Coproduct4
  MintNFT.Query
  TransferNFT.Query
  YourNFT.Query
  InternetNFT.Query

type ChildSlot = Either4
  Unit
  Unit
  Unit
  Unit


type DSL = H.ParentDSL State Query ChildQuery ChildSlot Void M
type HTML = H.ParentHTML Query ChildQuery ChildSlot M

render :: State -> HTML
render _ = HH.div_
    [ HH.slot' CP.cp1 unit MintNFT.component unit (const Nothing)
    , HH.slot' CP.cp2 unit TransferNFT.component unit (const Nothing)
    , HH.slot' CP.cp3 unit YourNFT.component unit (const Nothing)
    , HH.slot' CP.cp4 unit InternetNFT.component unit (const Nothing)
    ]

component :: H.Component HH.HTML Query Unit Void M
component =
  H.lifecycleParentComponent
    { initialState: const unit
    , render: render
    , eval
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    , receiver: const Nothing
    }


eval :: Query ~> DSL
eval = case _ of
  Initialize next -> do
    pure next
  -- RouteChange route next -> do
  --   H.modify_ $ map _{ route = route }
  --   pure next
