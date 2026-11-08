#!/usr/bin/env bqn

# see https://mlochbaum.github.io/BQN/spec/system.html#file-metadata
# dir files (all files)
# ignore symlinks and shit for now
# we only care about
# 'd' ≡ •file.Type 𝕩 (directories)
# 'f' ≡ •file.Type 𝕩 (files)
⟨ex⇐exists, ty⇐type, ls⇐list, at⇐at⟩ ← •file
# idk if tree recursion is a good plan here tbh
Abs ← ·At⊢

# filter by ending
Fe ← { es𝕊l:         # es: endings, l:list
    (∨´{𝕩⊸≡¨(-≠𝕩)↑¨l}¨es)⊸/l
}

Df ← {es𝕊d:          # es: endings, d:dir
    l←d⊸At¨Ls d      # list
    lt ← Ty¨ l       # list types
    lf ← ('f'=lt)⊸/l # list files
    ld ← ('d'=lt)⊸/l # list dirs

    lfe←es Fe lf     # list of file filtered by endings (glob on extension)

    lfe∾∾es⊸Df¨ld
    ;
    𝕊f: ⟨⟩
}

# •Out¨ ".c"‿".h" Df Abs (0≠≠)◶"."‿⊑ •args
".c"‿".h" Df Abs (0≠≠)◶"."‿⊑ •args
