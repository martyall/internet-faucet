module App.Wiring
  ( Wiring
  , make
  )
  where

import Prelude
import Effect.Aff.Bus as Bus
import Effect.Class (class MonadEffect, liftEffect)

type Wiring =
  { provider :: Unit
  }


make
  :: forall m
   . MonadEffect m
  => m Wiring
make = liftEffect do
  provider <- pure unit
  pure { provider }
