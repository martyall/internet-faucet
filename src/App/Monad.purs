module App.Monad where

import Prelude

import Control.Monad.Reader (ReaderT)
import Effect.Aff (Aff)
import App.Wiring (Wiring)

type M = ReaderT Wiring Aff

