{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UndecidableInstances #-}

-- |
-- Module      : Test.QuickCheck.GenT
-- Description : A GenT monad transformer for QuickCheck.
-- Copyright   : (c) 2013 Nikita Volkov; (c) 2026 IOHK
-- License     : MIT
--
-- Provides 'GenT', a monad transformer that wraps QuickCheck's 'Gen' and
-- allows any monad to be lifted into generator computations via the standard
-- @transformers@ / @mmorph@ machinery.
module Test.QuickCheck.GenT (
  -- * GenT transformer
  GenT (..),
  MonadGen (..),

  -- * Running
  runGenT,

  -- * QuickCheck combinators lifted to GenT
  oneof,
  choose,
  frequency,
  elements,
  suchThat,
  suchThatMaybe,
  listOf,
  listOf1,
  vectorOf,
) where

import Control.Monad.IO.Class (MonadIO (..))
import Control.Monad.Morph (MFunctor (..), MMonad (..))
import Control.Monad.Trans.Class (MonadTrans (..))
import qualified System.Random as R
import Test.QuickCheck (Gen)
import qualified Test.QuickCheck as QC
import qualified Test.QuickCheck.Gen as QCGen
import qualified Test.QuickCheck.Random as QCGen

-- ---------------------------------------------------------------------------
-- GenT

-- | A monad transformer version of QuickCheck's 'Gen'.
newtype GenT m a = GenT {unGenT :: QCGen.QCGen -> Int -> m a}
  deriving (Functor)

instance Applicative m => Applicative (GenT m) where
  pure a = GenT $ \_ _ -> pure a
  GenT f <*> GenT x = GenT $ \r n ->
    let (r1, r2) = R.split r
     in f r1 n <*> x r2 n

instance Monad m => Monad (GenT m) where
  return = pure
  GenT x >>= f = GenT $ \r n ->
    let (r1, r2) = R.split r
     in x r1 n >>= \a -> unGenT (f a) r2 n

instance MonadFail m => MonadFail (GenT m) where
  fail msg = GenT $ \_ _ -> fail msg

instance MonadTrans GenT where
  lift m = GenT $ \_ _ -> m

instance MonadIO m => MonadIO (GenT m) where
  liftIO = lift . liftIO

instance MFunctor GenT where
  hoist f (GenT g) = GenT $ \r n -> f (g r n)

instance MMonad GenT where
  embed f (GenT g) = GenT $ \r n ->
    let (r1, r2) = R.split r
     in unGenT (f (g r1 n)) r2 n

-- | Run a 'GenT' inside a 'Gen', producing an @m a@.
runGenT :: GenT m a -> Gen (m a)
runGenT (GenT g) = QCGen.MkGen g

-- ---------------------------------------------------------------------------
-- MonadGen class

class Monad m => MonadGen m where
  liftGen :: Gen a -> m a

instance MonadGen Gen where
  liftGen = id

instance Monad m => MonadGen (GenT m) where
  liftGen (QCGen.MkGen g) = GenT $ \r n -> pure (g r n)

-- ---------------------------------------------------------------------------
-- Lifted combinators

-- | 'QC.listOf' lifted to 'MonadGen'.
listOf :: MonadGen m => m a -> m [a]
listOf gen = liftGen (QC.sized $ \n -> QC.choose (0, n)) >>= \k -> vectorOf k gen

-- | 'QC.listOf1' lifted to 'MonadGen'.
listOf1 :: MonadGen m => m a -> m [a]
listOf1 gen = liftGen (QC.sized $ \n -> QC.choose (1, max 1 n)) >>= \k -> vectorOf k gen

-- | 'QC.vectorOf' lifted to 'MonadGen'.
vectorOf :: MonadGen m => Int -> m a -> m [a]
vectorOf k gen = sequence (replicate k gen)

-- | 'QC.oneof' lifted to 'MonadGen'.
oneof :: MonadGen m => [m a] -> m a
oneof [] = error "Test.QuickCheck.GenT.oneof: empty list"
oneof gs = do
  i <- liftGen (QC.choose (0, length gs - 1))
  gs !! i

-- | 'QC.frequency' lifted to 'MonadGen'.
frequency :: MonadGen m => [(Int, m a)] -> m a
frequency [] = error "Test.QuickCheck.GenT.frequency: empty list"
frequency xs = do
  let total = sum (map fst xs)
  i <- liftGen (QC.choose (1, total))
  pick i xs
  where
    pick _ [] = error "Test.QuickCheck.GenT.frequency: exhausted list"
    pick n ((k, g) : rest)
      | n <= k = g
      | otherwise = pick (n - k) rest

-- | 'QC.elements' lifted to 'MonadGen'.
elements :: MonadGen m => [a] -> m a
elements [] = error "Test.QuickCheck.GenT.elements: empty list"
elements xs = do
  i <- liftGen (QC.choose (0, length xs - 1))
  return (xs !! i)

-- | 'QC.sized' lifted to 'MonadGen'.
sized :: MonadGen m => (Int -> m a) -> m a
sized f = liftGen (QC.sized pure) >>= f

-- | 'QC.resize' lifted to 'MonadGen'.
resize :: MonadGen m => Int -> m a -> m a
resize n g = liftGen (QC.resize n (QC.sized pure)) >>= \_ -> g

-- | 'QC.choose' lifted to 'MonadGen'.
choose :: (MonadGen m, R.Random a) => (a, a) -> m a
choose = liftGen . QC.choose

-- | 'QC.suchThat' lifted to 'MonadGen'.
suchThat :: MonadGen m => m a -> (a -> Bool) -> m a
suchThat gen p = do
  x <- gen
  if p x then return x else suchThat gen p

-- | 'QC.suchThatMaybe' lifted to 'MonadGen'.
suchThatMaybe :: MonadGen m => m a -> (a -> Bool) -> m (Maybe a)
suchThatMaybe gen p = sized $ \n -> go n
  where
    go 0 = return Nothing
    go k = do
      x <- resize (2 * k + n0) gen
      if p x then return (Just x) else go (k - 1)
    n0 = 0 -- placeholder; resize semantics are advisory here
