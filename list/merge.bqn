#!/usr/bin/env bqn
# utils
# downcase
DC ← (32⊸×)∘('A'⊸≤∧'Z'⊸≥)⊸+
# returns function that replaces all 𝕗's with 𝕘's
_r_ ← {(⊢+(𝕘-𝕗)×𝕗⊸=)}

# normalize spaces
NS ← { 𝕊w: # takes a single word
    ws ← @+↕33            # whitespaces
    w(¬×`∨×`⌾⌽)∘(∊⟜ws)⊸/↩ # remove leading and trailing whitespace
    w(¬⊢∧1⊸⌽)∘(∊⟜ws)⊸/↩   # remove double whitespaces
    w
}

# normalize word list
NWL ← { 𝕊wl: # takes a word list
    wl {¬∨´"- 0123456789"∊𝕩}¨⊸/↩ # remove all words containing numbers, spaces, or hyphens
    #wl '-'_r_' '¨↩               # replace all dashes with spaces
    wl DC¨↩                      # downcase everything
    #wl NS¨↩                      # normalize spaces
    wl ¬∘(0∾˜⊢)∘(¯1⊸↓≡¨1⊸↓)⊸/∘∧↩ # sort and dedup
    wl
}

•Out¨ NWL ∾○•Flines´ "wikipedia-list.txt"‿"en.txt"
