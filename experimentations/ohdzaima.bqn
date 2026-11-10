#!/usr/bin/env bqn

# getdelim with null delimiter, to receive files by doing (for instance)
# find -print0 '*.[ch] directory/of/interest | ./count.bqn
# delimiting by null bytes is safer than delimiting by newlines
# (file names may contain newlines)
# 
# function written by dzaima, I just changed the indentation
#⟨wbm⇐mask⟩←•Import "bigfucking.bqn" # wbm: word boundary mask

libiuc_version ← 77
ia ← "/usr/lib64/libicuuc.so" •FFI "u8"‿("u_isUAlphabetic" ∾ "_" ∾ •Repr libiuc_version)‿">u32"
getdelim ← {
    stdin ← @ •foreign.Value "*"‿"stdin"
    gd0 ← @ •FFI "isize"‿"getdelim"‿"&*i8:c8"‿"&usize"‿"i32"‿"*"
    ptr ← ⋈•foreign.null
    len ← ⋈0
    {𝕊:
        n ← @
        n‿ptr‿len ↩ GD0 ⟨ptr, len, 𝕩-@, stdin⟩
        n≢¯1 ? (⊑ptr).ReadList n ; @
    }
}
# you could visually test this by doing (pseudocode)
# find -print0 | bqn -e '{𝕊: @≢l←GetDelim@? •Out l⋄1 ; 0}•_while_⊢ 1'
# it will take the null separated output of find -print0
# and print it separated by newlines instead (overengineered tr)

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

wlf ← (0≠≠)◶"wordlist"‿⊑ •args # wlf: word list file
                               # ⊑•args if 0≠ ≠•args else "wordlist"

ls   ← •Flines wlf          # ls: lines
llps ← ⍷ ∾ (⊢⋈¨↕∘≠)¨ ls     # llps: letter:letter positions set
llis ← ⊐⌾∾ (⊢⋈¨↕∘≠)¨ ls     # llis: lines as llps indices
uls  ← ∧⍷∾ls                # uls: unique letters (in wordlist)
                            # sorted because why not

# sanity check
! ls ≡ ⊑⚇1 ⊏⟜llps¨ llis

# word counts (for file)
WCS ← {𝕊fc:
    # fc: file contents
    # fcl: file contents length
    fcl  ← ≠fc
    # fcms: file char masks 
    fcms ← fc⊸=¨ lca
    # flms: file llps masks 
    flms ← {𝕊c‿i: (i⥊0)«(c-'a')⊑fcms }¨ llps

    {w𝕊wlis:                # word 𝕊 word llps indices
        wl   ← ≠w               # wl: word length
        # wfom ← ∧´wlis⊏flms      # wfom: word file occurence mask
        # ws   ← («wfom)/fc       # word starts
        # we   ← ((wl⥊0)»wfom)/fc # word ends
        # iwc  ← +´ (wbm⊏˜@-ws) ∧ (wbm⊏˜@-ws)

        wfis ← /∧´wlis⊏flms       # wfis: word file occurence indices
        iwc  ← +´ ¬ (IA¨@-˜(0⌈wfis-1)⊏fc) ∨ (IA¨@-˜(fcl⌊wfis+wl)⊏fc)
        #iwc ← +´ ¬ (wbm⊏˜@-˜(0⌈wfis-1)⊏fc) ∨ (wbm⊏˜@-˜(fcl⌊wfis+wl)⊏fc)
        
        # return iwc + (appears at start?) + (appears at end?)
        iwc + (w≡wl↑fc) + (w≡(-wl)↑fc)
    }´¨ ls⋈¨llis
}

{𝕊 0: 𝕊 1
 ;
 𝕊 1:
    wc ← 0⥊˜≠ls
    # this loop reads from the `find -print0` upstream from this script
    {𝕊: @≢l←GetDelim@ ? wc ↩ wc + (WCS DC •FChars l) ⋄ 1 ;
     𝕊: 0
    }•_while_⊢ 1
    # print out accumulated value (this one's for testing)
    {𝕊l‿c: •Out l∾": "∾•Repr c}¨ ls⋈¨wc
 ;
 𝕊 2: {𝕊l‿c: •Out l∾": "∾•Repr c}¨ ls⋈¨WCS DC •FChars 1⊑•args 
 ;
 𝕊: •Out "incorrect number of arguments! go fuck yourself"
}≠•args
