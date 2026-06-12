# QuickCheckT

[![CI](https://github.com/input-output-hk/QuickCheckT/actions/workflows/ci.yml/badge.svg)](https://github.com/input-output-hk/QuickCheckT/actions/workflows/ci.yml)
[![Hackage](https://img.shields.io/hackage/v/QuickCheckT.svg)](https://hackage.haskell.org/package/QuickCheckT)
[![Stackage Nightly](https://www.stackage.org/package/QuickCheckT/badge/nightly)](https://www.stackage.org/nightly/package/QuickCheckT)
[![Stackage LTS](https://www.stackage.org/package/QuickCheckT/badge/lts)](https://www.stackage.org/lts/package/QuickCheckT)

A `GenT` monad transformer for the [QuickCheck](https://hackage.haskell.org/package/QuickCheck)
library, maintained by [IOHK](https://iohk.io).

## Overview

`QuickCheckT` provides `Test.QuickCheck.GenT`, a monad transformer that wraps
QuickCheck's `Gen` type and allows any monad to be lifted into the generator
context. This makes it straightforward to write generators that have access to
`IO`, `State`, `Reader`, or any other effect stack.

## Origins

This package is a fork of
[`QuickCheck-GenT`](https://github.com/nikita-volkov/QuickCheck-GenT) by
**Nikita Volkov**, published under the MIT licence. The fork was created to:

- Re-home the package under the `input-output-hk` GitHub organisation.
- Rename the module hierarchy to `Test.QuickCheck.*` to avoid conflicts when
  both packages coexist as dependencies.
- Adopt IOG project conventions (CI, formatting, warning set).

All credit for the original implementation belongs to Nikita Volkov.

## Usage

```haskell
import Test.QuickCheck.GenT

-- | Derive a list of unique elements using a stateful generator.
uniqueList :: (Ord a) => GenT (State (Set a)) a -> Gen [a]
uniqueList gen = execState (runGenT (listOf gen)) mempty
```

## Building

```bash
cabal build
cabal test
```

## Contributing

Pull requests and issues are welcome at
<https://github.com/input-output-hk/QuickCheckT>.

## Licence

MIT — see [LICENSE](LICENSE).  
Original work © 2013 Nikita Volkov; fork © 2026 IOHK.
