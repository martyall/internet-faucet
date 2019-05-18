module Main where

import Prelude

import App.Component as App
import App.Route as Route
import App.Wiring as Wiring
import Control.Monad.Reader (runReaderT)
import Data.Maybe (Maybe(..), isJust)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Halogen (liftEffect)
import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Partial.Unsafe (unsafeCrashWith)
import Routing.Hash (matchesWith)
import Web.DOM.ParentNode (QuerySelector(..))

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  el <- HA.selectElement $ QuerySelector "#app"
  case el of
    Nothing ->
      unsafeCrashWith "div#app has to be defined"
    Just el' -> do
      wiring <- Wiring.make
      initialRoute <- Route.currentRoute
      io <- runUI (H.hoist (flip runReaderT wiring) App.component) initialRoute el'
      liftEffect $ matchesWith Route.parse \old new -> do
        -- NOTE: old is Nothing on initial call, so by using this guard we
        -- make sure newRoute is dispatched only on actual route change
        when (isJust old) do
          launchAff_ $ io.query $ App.NewInput new unit
