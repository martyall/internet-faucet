module App.Component where

import Prelude

import App.Components.Beneficiary.Component as Beneficiary
import App.Components.Donator.Component as Donator
import App.Monad (M)
import App.Route (Route(..))
import App.Route as Route
import Data.Either.Nested (Either2)
import Data.Functor.Coproduct.Nested (Coproduct2)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.Component.ChildPath as CP
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

type State = {route :: Route}

type Input = Route
data Query a
  = Initialize a
  | NewInput Input a

type ChildQuery = Coproduct2
  Donator.Query
  Beneficiary.Query

type ChildSlot = Either2
  Unit
  Unit


type DSL = H.ParentDSL State Query ChildQuery ChildSlot Void M
type HTML = H.ParentHTML Query ChildQuery ChildSlot M

render :: State -> HTML
render st = HH.div [HP.class_ $ H.ClassName "App"]

  [ navigation st.route
  , case st.route of
      Donator -> HH.slot' CP.cp1 unit Donator.component unit (const Nothing)
      Beneficiary -> HH.slot' CP.cp2 unit Beneficiary.component unit (const Nothing)
  ]
  where
  navigation currentRoute = HH.div [HP.class_ $ H.ClassName "Navigation"] $
    [ Donator
    , Beneficiary
    ] <#> \route -> [HH.text $ show route] # if route == currentRoute
            then HH.span_
            else HH.a [Route.goTo route ]

component :: H.Component HH.HTML Query Input Void M
component =
  H.lifecycleParentComponent
    { initialState: {route:_}
    , render: render
    , eval
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    , receiver: Just <<< H.action <<< NewInput
    }


eval :: Query ~> DSL
eval = case _ of
  Initialize next -> do
    pure next
  NewInput route next -> do
    H.modify_ $ _{ route = route }
    pure next
