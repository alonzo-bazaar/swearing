#!/usr/bin/env perl

# create a whole bunch of data that matches nothing in our wordlist

use strict;
use warnings;

foreach (1..1000000) {
    foreach ('a'..'z') { print; }
    foreach ('A'..'Z') { print; }
}
