module Main where

import Prelude
import Effect (Effect)
import App.Wiring as Wiring
import App.Component as App
import Halogen as H
import Halogen.Aff as HA
import Web.DOM.ParentNode (QuerySelector(..))
import Data.Maybe (Maybe(..))
import Partial.Unsafe (unsafeCrashWith)
import Halogen.VDom.Driver (runUI)
import Control.Monad.Reader (runReaderT)

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  el <- HA.selectElement $ QuerySelector "#app"
  case el of
    Nothing ->
      unsafeCrashWith "div#app has to be defined"
    Just el' -> do
      wiring <- Wiring.make
      driver <- runUI (H.hoist (flip runReaderT wiring) App.component) unit el'
      pure unit
