module App.Route where

import Prelude

import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Eq (genericEq)
import Data.Generic.Rep.Show (genericShow)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log)
import Halogen.HTML.Properties as HP
import Routing.Duplex (RouteDuplex')
import Routing.Duplex as D
import Routing.Duplex.Generic as G
import Routing.Duplex.Parser (RouteError)
import Routing.Hash (getHash, setHash)

data Route
  = Donator
  | Beneficiary

derive instance genericRoute :: Generic Route _
instance showRoute :: Show Route where show = genericShow
instance eqRoute :: Eq Route where eq = genericEq

route :: RouteDuplex' Route
route = D.root $ G.sum
  { "Donator": D.path "donator" G.noArgs
  , "Beneficiary": D.path "beneficiary" G.noArgs
  }

print :: Route -> String
print = D.print route

goTo :: forall r q. Route -> HP.IProp ( href :: String | r ) q
goTo r = HP.href $ "#" <> print r

parse :: String -> Either RouteError Route
parse = D.parse route

setRoute :: forall m. MonadEffect m => Route -> m Unit
setRoute route' = liftEffect do
  let routeHash = print route'
  log $ "Setting new location: " <> routeHash
  setHash routeHash

currentRoute :: forall m. MonadEffect m => m Route
currentRoute = do
  hash <- liftEffect getHash
  case parse hash of
    Left err -> do
      log $ "Got error parsing currentRoute" <> show err
      setRoute Donator
      pure Donator
    Right route' -> do
      pure route'
