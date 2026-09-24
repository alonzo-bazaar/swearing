#!/usr/bin/env bqn
# note: there are far faster ways to implement this
# the following was done 'cause fast to implement
full‿delenda ← •FLines¨ 2↑•args
•Out¨ ¬∘∊⟜delenda⊸/ full
