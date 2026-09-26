# the following is a note for the reader
library(tidyverse)
library(ggthemes)
library(ggrepel)
library(palmerpenguins)

# so... this works
a <- ggplot(data = penguins,
            mapping = aes(x=flipper_length_mm, y=body_mass_g))
b <- geom_point(mapping=aes(color=species, shape=species))
a + b

layers <- list(a, b)

# this doesn't works
layers[1] + layers[2]

# this works
layers[[1]] + layers[[2]]
