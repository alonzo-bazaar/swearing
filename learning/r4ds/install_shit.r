# to be run interactively
# $ R
# > source('install_shit.r')
# > install.packages(all_deps)
#
# the unfurling of this last call is likely to require root access
# 
# recommended options for the choices you will be asked to take by the script
# mirror?
#   whatever's closest to ya
# prefer later packages from source?
#   NO, FUCK NO, IT TAKES GODDAMN FOREVER, FUCK
source('utils.r')
intro_deps <- c("tidyverse",
                "arrow", "babynames", "curl", "duckdb", "gapminder", 
                "ggrepel", "ggridges", "ggthemes", "hexbin", "janitor", "Lahman", 
                "leaflet", "maps", "nycflights13", "openxlsx", "palmerpenguins", 
                "repurrrsive", "tidymodels", "writexl")
ch1_deps <- c()
# ch2_deps <- c() 
# ch3_deps <- c()
# ...

all_deps <- c(intro_deps, ch1_deps)
all_deps <- fold(append, all_deps)

# install.packages(all_deps)
