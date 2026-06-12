-- |
-- Module      : Test.QuickCheck.GenT.Prelude
-- Description : Internal prelude re-export for QuickCheckT.
-- Copyright   : (c) 2013 Nikita Volkov; (c) 2024 IOHK
-- License     : MIT
module Test.QuickCheck.GenT.Prelude (
  module Prelude,
  module Control.Monad,
  module Control.Monad.IO.Class,
  split,
) where

import Control.Monad
import Control.Monad.IO.Class
import Prelude
import System.Random (split)
