# "mission statement"
> NOTE: I'm aware "mission statement" is not the most proper of terms
> for "what the fuck are we tryna do again?"
> but I find it funny to use, so I shall use it.
The aim of this exam project is to provide an empirical analysis of swearing in open source software by looking at various metrics related to swearing in code, and seeing how they may be ralted to other metrics of the code containing swearing or of the users doing the swearing.

The study is to be divided into several phases, in the first prelimiary phase that this report is about we seek to gather a very broad image of the swearing-in-code landscape, mainly by querying the github rest api for quantities related to various swear words and programming languages.

# things found so far
The initial aim for this initial phase was to, broadly speaking
> forulate some initial "sanity constraints", relating to:
> - number of stars
> - number of contributors
> - et al.
> these constraints will help avoid polluting our searches with toy projects, school projects, and the like;
> given these constraints, see how many repositories contain swearing in source code, poke around, and get a vague idea of what we could analyze about it.

In this initial week of digging through documentation we have found the following (not particularly happy information)

## limits of the github search APIs
There are two api endpoints of interest for our mission statement
- `https://api.github.com/search/code`
- `https://api.github.com/search/repositories`

And they're both great and... not so great for our usecase:
### code search
Starting with the `/search/code` endpoint, this allows us to search for [code in files](https://docs.github.com/en/rest/search/search?apiVersion=2026-03-10#search-code), and it does provide us with a `total_count` number in the search result to say, for instance, how many `fuck`s did it find, which sounds great, but...  

Looking at the [documentation](https://docs.github.com/en/search-github/searching-on-github/searching-code) for code search it quite appearent that this search does not allow for the search to depend on repositrory metadata such as number of stars, or contributors.

Although we may use this as a starting point, and perhaps analyze its results later;
as we shall later see in the results section, filter as we may the numbers returned by this endpoint are gigantic and unlikely to be very traversable.
  
## repository search
The `/search/repositories` endpoint does allow us to filter by, for instance [number of stars](https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories#search-by-number-of-stars), but it is sorely lacking in any capibilitis for searching by file contents, quoting from [the endpoint's documentation](https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories#search-based-on-the-contents-of-a-repository)
> You can find a repository by searching for content in the repository's README file using the in:readme qualifier. [...]
> Besides using in:readme, it's not possible to find repositories by searching for specific content within the repository. To search for a specific file or content within a repository, you can use the file finder or code-specific search qualifiers.
  
The endpoint does, furthremore, not have any way to filter based on number of contributors.

Also the rest api for [repository statistics](https://docs.github.com/en/rest/metrics/statistics?apiVersion=2026-03-10) does not seem of much use either.

### closing notes about the github search APIs
They're also case insensitive for some reason

## difficulties in implementing our mission statement
Our initial mission statement very much tied
- number of stars
- number of contributors
- contents of the repository

In a way that is not queriable by the github api.
At least not without needing to save a lot of intermediate query results, but that will make working at the broad scale we initially envisioned not quite as easy as we wanted it to be.

# some preliminary (demo) results
Given these limits on the github api it is currently not quite immediate how to implement our "mission statement" task,
but we can provide the following (not very useful) statistics as an initial taste of what it can actually do.
## swear words and languages used for demo results
### swear words
As a premise to the following results, we have chosen these 10 swear words as a testing ground in the hopes they'd cover a wide range of profanity levels without needing many search needles, sorted by profanity level we have:
- motherfucker
- asshole
- cunt (not offensive in british and australian english, very offensive in american english, hard to rank)
- fuck
- shit
- bitch
- dick
- damn
- darn
- gosh

### languages
As our programming languages under test we have chosen the following amoung 
- javascript
- python
- typescript
- java
- c++
- c
- php
- c#
- kotlin
- ruby
- swift
- go

Some numbers in the language ranking were skipped, these are listed below together with the reason why they were skipped

- shell:  
  the author finds the distinction of `shell` as a language to be ovely vague, there is a wide variety of programming languages that may be called "shell", including, but not limited to
  - posix shell
  - bash
  - korne shell
  - c shell
  - ash
  - dash
  - powershell
  these languages all have very different properties (and reasons why someone may curse the heavens whilst using them) making them not ideal to consider as a single set.
- dockerfile:  
  it's more of a configuration language than anything
- makefile:  
  although the author does not dispute the lovecraftian potential of makefile as a general purpose programming language, it is far too domain specific in its intended case to work for this study.
- batchfile:  
  they're probably all single line anyhow
- powershell:  
  wouldn't be fair to skip shell and include powershell
- cmake:  
  same as makefile

Having fixed the swear words and languages under test we may now provide the following results
## demo results
the code to produce all these results can be found in `demo.perl`

(to be one later 'cause my laptop is about to die)

### frequency of swear word usage (across all analyzed programming languages)

### frequency of swear word usage by language (cartesian product)

### frequency of swear word usage in repository metadata (title, readme, and the like)

### frequency of swear word usage in repository metadata for repositorories with more than 5 stars

# closing notes
Sorry for all the code being in perl, I have looked at the documentation for pydriller but it appears pydriller is quite useful at analyzing repos for which you have a handle (saved locally or have the github link), but not as useful when looking for the repositories in question.

So... for the rest part imma use perl I'm afraid, for this initial phase at least, I'm sorry.
