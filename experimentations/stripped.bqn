#!/usr/bin/env bqn
LCP ← 'a'⊸≤∧'z'⊸≥ 
UCP ← 'A'⊸≤∧'Z'⊸≥ 
DC  ← (⊢+32×UCP)  
UC  ← (⊢-32×LCP)  
kjv ← DC •Fbytes "data/kjv.txt"
lca ← (⊣+↕∘¬˜)´"az" 
aleq ← <˘ lca =⌜ kjv   

# SM: Shift Mask
# takes:
# - letter index (li)
# - shift by     (sb)
# shifts aleq at li by sb, but if it has the result already then it returns a
# cached result instead
# so this is basically the expression 'sb ↓ li⊑aleq', but cached
smc ← ⟨⟩ # smc: shifted mask cache
SM ← {
     # check for cache hit (ch)
     # does any element in smc already start with li‿sb?
     # if so, that's our hit, return it (smc is an alist lol)
     li𝕊sb : 0≠≠ch←(li‿sb≡⊑)¨⊸/smc  ? 1⊑⊑ch ;
     
     # if cache hit not found then compute result and shove it at the end of
     # smc for future lookup
     li𝕊sb : smc ∾⟜⟨li‿sb, res←sb↓li⊑aleq⟩↩ ⋄ res
}

WordFreq ← { 𝕊w:
    #arrs ← aleq ⊏˜ w-'a'
    l  ← kjv -○≠ w 
    wi ← / ∧´ l⊸↑¨ (w-'a') SM¨ ↕≠w
    wc ← +´ ¬ (LCP kjv⊏˜ 0⌈wi-1) ∨ (LCP kjv⊏˜ (1-˜≠kjv) ⌊ wi+≠w)
    wc + (w≡kjv ↑˜ ≠w) + (w≡kjv ↑˜-≠w)
}
O ← {𝕊𝕩: •Out 𝕩 ∾ ": " ∾ •Repr WordFreq 𝕩}
O¨ •Flines ⊑ •args
