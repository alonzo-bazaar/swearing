#!/usr/bin/env bqn
# utils
ws‿r‿dc‿sd ← •Import "utils.bqn"

# normalize spaces
NS ← { 𝕊w: # takes a single word
    ws ← @+↕33            # whitespaces
    w(¬×`∨×`⌾⌽)∘(∊⟜ws)⊸/↩ # remove leading and trailing whitespace
    w(¬⊢∧1⊸⌽)∘(∊⟜ws)⊸/↩   # remove double whitespaces
    w
}

# normalize word list
NWL ← { 𝕊wl: # takes a word list
    wl {¬∨´"0123456789"∊𝕩}¨⊸/↩ # remove all words containing numbers, spaces, or hyphens
    wl '-'_r_' '¨↩               # replace all dashes with spaces
    wl DC¨↩                      # downcase everything
    wl NS¨↩                      # normalize spaces
    wl SD↩                       # sort and dedup
    wl
}

# print NWL if any arg was provided, otherwise do nothing
{ 0≠≠•args ? •Out¨ NWL ∾´ •Flines¨ •args ; 0 }
