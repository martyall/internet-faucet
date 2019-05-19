module Test.Main where

import Prelude

import Debug.Trace (traceM)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (logShow)
import InternetFaucet.GetData (getAllTokensForAddress)
-- import Test.Spec.Reporter.Console (consoleReporter)
-- import Test.Spec.Runner (runSpec)

main :: Effect Unit
main = launchAff_ $ do
-- runSpec [consoleReporter] do
  res <- getAllTokensForAddress "0x404bca21ccafdab4b91bf028fa9fbc1fbaf7a2a9"
  traceM res
  -- it "test getAllTokensForAddress" do

  pure unit
