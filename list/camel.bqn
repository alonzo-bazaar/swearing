#!/usr/bin/env bqn
ws‿r‿uc‿dc‿sb‿jw‿sd‿sci ← •Import "utils.bqn"

# process single word (not phrase)
Word  ← {⍷𝕩⊸{𝕏𝕨}¨ ⊢‿UC‿DC‿(UC⌾⊏ DC)}

# process a phrase (several words)
Words ← { 𝕊p:   # takes a phrase (as character vector) as input
    w ← p SB ws # words
    w ↩ ⍷ w⊸{𝕏𝕨}¨ ⟨⊢, UC¨, DC¨, (UC⌾⊏ DC)¨, UC⌾⊏⌾⊑ DC¨⟩
    ⥊ w JW⌜ ""‿"_"‿" "
}

•Out¨ SCI SD ∾´ {∨´𝕩∊ws ? Words 𝕩 ; Word 𝕩 }¨ •FLines ⊑ •args
