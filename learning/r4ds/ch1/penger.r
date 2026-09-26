library(tidyverse)
library(ggthemes)
library(ggrepel)
library(palmerpenguins)

fold <- function(compose, seq) {
    if (length(seq) == 0) return(0)
    if (length(seq) == 1) return(seq[[1]])
    acc <- seq[[1]]
    for (i in 2:length(seq))
        acc <- compose(acc, seq[[i]])
    return(acc)
}

add <- function(a, b) { return(a+b) }

layers = list(ggplot(penguins, aes(x=flipper_length_mm, y=body_mass_g)),
              geom_point(mapping = aes(color=species, shape=species)),
              geom_smooth(method = "lm"),
              labs(title    = "body mass and flipper length",
                   subtitle = "mannaggia kitemmuort",
                   x        =  "flipper length (in millmetres)",
                   y        = "chonkyness (grams)",
                   color    = "Species",
                   shape    = "Species"),
              scale_color_colorblind())
fold(add, layers)
