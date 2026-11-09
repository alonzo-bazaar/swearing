#!/usr/bin/env bqn
# the long awaited sequel to ohboi.bqn
# see ohgirl.org for docs 'cause I ain't explaining this shit in comments

# utility casing functions &Co.
LCP  ← 'a'⊸≤ ∧ 'z'⊸≥ # lowercase? (p is for predicate)
NLCP ← 'a'⊸> ∨ 'z'⊸< # not lowercase?

UCP  ← 'A'⊸≤ ∧ 'Z'⊸≥ # uppercase?
NUCP ← 'A'⊸> ∨ 'Z'⊸< # not uppercase?

DC   ← (⊢+32×UCP)    # downcase
UC   ← (⊢-32×LCP)    # upcase

lca  ← (⊣+↕∘¬˜)´"az" # lca: lower case alphabet

# init step: bake the wordlist once
# (we'll use this same list data for all files we count through)
ls   ← •Flines "wordlist"   # ls: lines
llps ← ⍷ ∾ (⊢⋈¨↕∘≠)¨ ls     # llps: letter:letter positions set
llis ← ⊐⌾∾ (⊢⋈¨↕∘≠)¨ ls     # llis: lines as llps indices
uls  ← ∧⍷∾ls                # uls: unique letters (in wordlist)
                            # sorted because why not

# sanity check
! ls ≡ ⊑⚇1 ⊏⟜llps¨ llis

# word counts (for file)
WCS ← {
    # fc: file contents
    fc   ← DC •FBytes 𝕩
    # fcl: file contents length
    fcl  ← ≠fc
    # fcms: file char masks 
    fcms ← {𝕊c: ⊑c∊uls ? fc = c ; 𝕊c: @}¨ lca
    # flms: file llps masks 
    flms ← {𝕊c‿i: ci←c-'a' ⋄ (i⥊0)«ci⊑fcms }¨ llps

    {w𝕊wlis:                # word 𝕊 word llps indices
        wl   ← ≠w           # wl: word length
        wfis ← /∧´wlis⊏flms # wfis: word file occurence indices
        
        # iwc: intenal word count
        # ie: word count, but disregarding the two cases where the
        # word appears at the very start or at the very end of fc
        iwc ← +´ (NLCP(0⌈wfis-1)⊏fc) ∧ (NLCP(fcl⌊wfis+wl)⊏fc)
        
        # return iwc + (appears at start?) + (appears at end?)
        iwc + (w≡wl↑fc) + (w≡(-wl)↑fc)
    }´¨ ls⋈¨llis
}

{𝕊l‿c: •Out l∾": "∾•Repr c}¨ ls⋈¨ WCS "data/kjv.txt"
