# from ?[
# when talking about lists

# > Indexing by ‘[’ is similar to atomic vectors and selects a list of the
# > specified element(s).
# > Both ‘[[’ and ‘$’ select a single element of the list.
# > The main difference is that ‘$’ does not allow computed indices,
# > whereas ‘[[’ does.

# to add elements of a list or vector we should therefore access them with [[ ]]
# this matters little for vectors, but for lists it's the difference between
# summing up eleents of list(1, 2, 3) and summing up list slices of list(1, 2, 3)
# (the latter does not work since... non-numeric argument to binary operator 

# example usage
# fold(function(a, b) { return (a + b) }, c(1, 2, 3, 4))    # => 10
# fold(function(a, b) { return (a + b) }, list(1, 2, 3, 4)) # => 10
fold <- function(compose, seq) {
    if (length(seq) == 0) return(0)
    if (length(seq) == 1) return(seq[[1]]) # R indexing is 1 based
    acc <- seq[[1]]
    for (i in 2:length(seq))
        acc <- compose(acc, seq[[i]])
    return(acc)
}

# add is a surprise tool that will come in handy later
# the other ones are there just for consistency tbh
add <- function(a, b) { return(a+b) }
sub <- function(a, b) { return(a-b) }
mul <- function(a, b) { return(a*b) }
div <- function(a, b) { return(a/b) }
