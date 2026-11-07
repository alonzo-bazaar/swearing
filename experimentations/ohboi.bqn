#!/usr/bin/env bqn

LCP ← 'a'⊸≤∧'z'⊸≥ # lowercase? (p is for predicate)
UCP ← 'A'⊸≤∧'Z'⊸≥ # uppercase?
DC  ← (⊢+32×UCP)  # downcase
UC  ← (⊢-32×LCP)  # upcase
kjv ← DC •Fbytes "data/kjv.txt"

# we're gonna have a lot of words we wanna check against
# for this reason I thought it might be fun to precompute masks for
# kjv=i for i in range(a..z)
# and then we shift and ∧ those together when looking for matches

# not the best bibliography but for the "Ai8" thing see dzaima's message here
# https://discord.com/channels/821509511977762827/821511464090992640/1568393257971617904

lca ← (⊣+↕∘¬˜)´"az" # lower case alphabet
#aleq ← "Ai8"⊸•internal.Variation lca =⌜ kjv   # alphabet equals (kjv)
aleq ← <˘ lca =⌜ kjv   # alphabet equals (kjv)

# say we wanna do a match like kjv =~ /\bbird\b/gi 
# we wanna know how often 'bird' appears in the kjv, ignoring case, surrounded
# by some 'word boundary' (string start, string end, or non-alphabetic chars)
WordFreq ← { 𝕊w:
    # w←'bird', arrs ←[b←kjv='b', i←kjv='i', r←kjv='r', r←kjv='d']
    # (due to how we defined aleq)
    arrs ← aleq ⊏˜ w-'a'

    # to get the indices at which 'bird' appears we want to and together
    # b, 1↓i, 2↓r, 3↓d
    # (I don't feel comfortable nudging an array that big) 
    # when all these 4 masks are 1 in a given index i, then we'll have
    # "bird"≡(i+↕4)⊏kjv 

    # but given that all of these are different sizes, we must first
    l ← kjv -○≠ w # which is gonna be the length of (3↓d) 

    # and now we can do l⊸↑¨ b‿(1↓i)‿(2↓r)‿(3↓d) and it's all homogeneous
    # so to compute all indices at which bird appears in the kjv we do
    # wi: word indices
    wi ← / ∧´ l⊸↑¨ ↓´¨ arrs ⋈˜¨ ↕≠w

    # now, to see which of those indices correspond to a word boundary, we
    # check that whatever came before and after the word was non alphabetical
    # and since we already downcased the whole input word, so we can just check
    # (kjv ⊏˜ wi-1 is not alphabetical) ∧ (kjv ⊏˜ wi+≠w is not alphabetical)
    # but we must first clamp wi-1 and wi+≠w will into valid string indices
    #
    # since they may go below 0 or beyond the length of the string
    # this will happen if 'bird' is at the start or at the end of the kjv
    # and, since we're gonna clamp into something that's still alphabetical
    # (ie: 'bird') then using these altered indices will result in a negative
    # (we're searching for non alphabetic characters before or after 'bird')

    # wc: word count
    wc ← +´ ¬ (LCP kjv⊏˜ 0⌈wi-1) ∨ (LCP kjv⊏˜ (1-˜≠kjv) ⌊ wi+≠w)

    # as we said before, our border clamping will make 'bird' appearing at the
    # start or the end of tje kjv be negative
    # but start and end of string are still word boundaries, so we check those
    # two cases as well before returning wc
    # (wc will contain the count for all non-border kjv occurences of 'bird')
    wc + (w≡kjv ↑˜ ≠w) + (w≡kjv ↑˜-≠w)
}

# O "bird"
# should give the same data as
# rg -i --count-matches '\bbird\b' data/kjv.txt 
O ← {𝕊𝕩: •Out 𝕩 ∾ ": " ∾ •Repr WordFreq 𝕩}

O¨ •Flines ⊑ •args
