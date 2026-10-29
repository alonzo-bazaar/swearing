#!/usr/bin/env bqn
lf ← @ + 10
cr ← @ + 13

# see https://www.rfc-editor.org/info/rfc4180/#section-2

# quoted indices
# get indices with a 'structural' quote (ignore "", which is escaped ")
# we'll call those q
# if we +`q that we'll flip flop between in quote and out quote
# so we can discriminate that with 2|+`q
# *except* that closing quotes will be considered part of the unquoted
# space that they open
# so we add closing quotes as the indices where q ∧ 0=2|+`q
QDI ← { q←(⊢>«∨») '"'=𝕩 ⋄ ((q∧0=2|⊢) ∨ (1=2|⊢)) +`q }

# split by mask
SBM ← { mask𝕊data : ((1-˜¬∧1++`) mask) ⊔ data }

# maybe unquote
# if 𝕩 is in the form "<data>" extract just the <data>, without quotes
# if 𝕩 is *not* in the form "<data>" then leave it alone
MUQ ← ((2⥊'"')≡⊑⋈⊑∘⌽)◶⊢‿{1↓¯1↓𝕩}
SF  ←      (¬∘QDI∧∊⟜cr‿lf)⊸SBM  # split csv file in lines
SL  ← MUQ¨ (¬∘QDI∧=⟜',')  ⊸SBM  # split csv line in fields
