#!/usr/bin/env bqn
# the long awaited sequel to ohboi.bqn
# see ohgirl.org for docs 'cause I ain't explaining this shit in comments

LCP ← 'a'⊸≤∧'z'⊸≥ # lowercase? (p is for predicate)
UCP ← 'A'⊸≤∧'Z'⊸≥ # uppercase?
DC  ← (⊢+32×UCP)  # downcase
UC  ← (⊢-32×LCP)  # upcase

lca  ← (⊣+↕∘¬˜)´"az" # lca: lower case alphabet

ls←•Flines "wordlist"   # ls: lines
llps ← ⍷ ∾ (⊢⋈¨↕∘≠)¨ ls # llps: letter:letter positions set
llis ← ⊐⌾∾ (⊢⋈¨↕∘≠)¨ ls # llis: lines as llps indices
uls ← ∧⍷∾ls             # uls: unique letters (that appear in the wordlist)
                        # sorted because why not

# sanity check
# ! ls ≡ ⊑⚇1 ⊏⟜llps¨ llis

fc   ← DC •FBytes "data/kjv.txt"           # fc: file contents
fcl  ← ≠fc                                     # fcl: file contents length
fcms ← {𝕊c: ⊑c∊uls ? fc = c ; 𝕊c: @}¨ lca      # fcms: file char masks 
flms ← {𝕊c‿i: ci←c-'a' ⋄ (i⥊0)«ci⊑fcms }¨ llps # flms: file llps masks 

# test data (to debug: comment canonical definitions and rerun with these)
#ls←"bird"‿"bride"‿"horse"‿"horsey"‿"fly"
#fc← "won't you fly yyyyyyy free bird"
#w←"fly"
#wlis←11‿12‿13
#wlis←11‿12‿13

 wcs ← {                # wcs: word counts
    w𝕊wlis:             # word 𝕊 word llps indices
    wl   ← ≠w           # wl: word length
    wfis ← /∧´wlis⊏flms # wfis: word file occurence indices

    # iwc: intenal word count
    # (disregarding wether word appears at the start or end of fc) 
    iwc ← +´ ¬ (LCP(0⌈wfis-1)⊏fc) ∨ (LCP(fcl⌊wfis+wl)⊏fc)

    # return iwc + (appears at start?) + (appears at end?)
    #iwc + (w≡wl↑fc) + (w≡(-wl)↑fc)
    iwc
}´¨ ls⋈¨llis

{𝕊l‿c: •Out l∾": "∾•Repr c}¨ ls⋈¨wcs 

