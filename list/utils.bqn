# variables:
ws ⇐ @+↕33 # whitespaces

# functions:
UC   ⇐ (32⊸×)∘('a'⊸≤∧'z'⊸≥)⊸(-˜)  # UC   = upcase
DC   ⇐ (32⊸×)∘('A'⊸≤∧'Z'⊸≥)⊸+     # DC   = downcase
SB   ⇐ (0≠≠¨)⊸/((1-˜¬×1++`)∘∊⊔⊣)  # SB   = split by
JW   ⇐ {(⊣∾⟜𝕩⊸∾⊢)´ 𝕨}             # JW   = join with
SD   ⇐ ¬∘(0∾˜⊢)∘(¯1⊸↓≡¨1⊸↓)⊸/∘∧   # SD   = sort and deduplicate
SCI  ⇐ ⍋∘(DC¨)⊸⊏                  # SCI  = sort case insensitive
# note: sci doesn't handle equating underscores and spaces,
# should probably add that, not now tho

# modifiers:
# returns function that replaces all 𝕗's with 𝕘's
_r_ ⇐ {(⊢+(𝕘-𝕗)×𝕗⊸=)}
