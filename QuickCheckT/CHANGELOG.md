# Changelog for `QuickCheckT`

## 1.0.0.0

- Forked from [`QuickCheck-GenT`](https://github.com/nikita-volkov/QuickCheck-GenT)
  (originally authored by Nikita Volkov, MIT licence).
- Re-homed under the `input-output-hk` GitHub organisation.
- Renamed Cabal package from `QuickCheck-GenT` to `QuickCheckT`.
- Renamed Haskell module hierarchy from `QuickCheck.GenT` /
  `QuickCheck.GenT.Prelude` to `Test.QuickCheck.GenT` /
  `Test.QuickCheck.GenT.Prelude` to avoid conflicts when both packages
  are present as dependencies.
- Adopted IOG project conventions: `cabal-version: 2.4`, `Setup.hs`,
  `fourmolu.yaml`, GHC warning set, and GitHub Actions CI workflow.
