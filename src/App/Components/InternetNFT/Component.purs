module App.Components.InternetNFT.Component where

import Prelude

import CSS as CSS
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Data.Maybe (Maybe(..))

type State =
  { foo :: Unit
  }

data Query a
  = Initialize a
  | NewInput Input a
  | FOO a

data Message = FOOClicked

type DSL m = H.ComponentDSL State Query Message m
type HTML = H.ComponentHTML Query
type Input = Unit

component
  :: forall m
   . MonadAff m
  => H.Component HH.HTML Query Input Message m
component =
  H.lifecycleComponent
    { initialState: const {foo: unit}
    , render
    , eval
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    , receiver: Just <<< H.action <<< NewInput
    }

render :: State -> HTML
render {foo} =
  HH.div_ [ HH.text $ show foo]

eval
  :: forall m
   . MonadAff m
   => Query ~> DSL m
eval = case _ of
  Initialize next -> do
    pure next
  FOO next -> do
    H.raise FOOClicked
    pure next
  NewInput unit next -> do
    pure next
