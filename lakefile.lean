import Lake
open Lake DSL

/-!
# Lemma build configuration

`Lemma` is the kernel, the metaprogramming layer (compiler checks), the
construct library, the theory modules and any accepted machine-generated
modules under `Lemma/Generated/`.

`LemmaTests` holds `#guard_msgs` tests which pin the exact warnings and
errors the compiler checks emit.

No external dependencies: the project builds against core Lean only.
-/

package lemma where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

@[default_target]
lean_lib Lemma where
  globs := #[.andSubmodules `Lemma]

lean_lib LemmaTests where
  globs := #[.andSubmodules `LemmaTests]
