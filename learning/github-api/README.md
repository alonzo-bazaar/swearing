> this file is called `README.md` just so it shows up the moment you open this directory up
> it's more of a report/readme hybrid for the time being
> pardon the confusion

# github api
we're gonna use github's search api to look for repositories containing all the various thingamajingies (profanities)

> **heads up:**
> the author is big a fan of programming in the dumbest ways known to man whenever he gets the freedom to do
> so and he has been given the freedom to do so for this repository
> good luck bruv


# api limitations considerations
- the github api does not allow for wildcards in searching repos, and regexen are not even remotely mentioned
  - ([source](https://docs.github.com/en/rest/search/search?apiVersion=2026-03-10#limitations-on-query-length))  
    plus the [query syntax page](https://docs.github.com/en/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax) does not mention wildcards  
    so... yeah I'm quite sure the code search does not support wildcards (it's probably some whatever n-grans indexing bullshit underneath so supporting regex sounds differently feasible for github's scale, only plain substring mathcing seems to be allowed)
  - as an ([additional source (legacy)](https://docs.github.com/en/search-github/searching-on-github/searching-code#considerations-for-code-search)) the legacy documentation for the api explicitly states the github rest api does *not* support wildcards (let alone regex)

ok nevermind [appearently it's supported](https://docs.github.com/en/search-github/github-code-search/understanding-github-code-search-syntax?apiVersion=2026-03-10#using-regular-expressions)
it's just that the *code search* api and the *search* api are two wildly different things
that's not confusing at all
fuck you github

ok nevermind the nevermind, the github code search is not part of their rest api, it's just part of their web interface (you visit the page for a repo in your browser and there's a search bar there that support the code search API
the github code search docs are [here](https://docs.github.com/en/search-github/github-code-search)
and if you see the part about [using the code search](https://docs.github.com/en/search-github/github-code-search/using-github-code-search) then surprise surprise, no api
just search bar

so... given that the github api does not allow for wildcards&Co. it seems we're gonna have to find someway else to match swear words
most of the available literature uses offline tools for finer control over swear words (and general toxicity) detection,
We want to checkout as little as possible for the initial phases of this study so if we wanna do this initial search on a github api level we'll have to do this initial search within the limits of the github api

## plan of attack
The Github api has two features we're gonna use for this filtering
- you can put and/or clauses in text queries
- you can get the text that matched your query as part of the query result

so here's the plan
we wanna look for a swear word, say fuck
instead of matching for the following regexen (as the paper did)
- `/[A-Z\b_]fuck[A-Z\b_]/`
- `/[A-Z\b_]Fuck[A-Z\b_]/`
- `/[A-Z\b_]FUCK[A-Z\b_]/`
- ...
which would take entirely too many queries to emulate, we can instead match for the following substrings
(lowercase)
- ` fuck`
- `fuck `
- `fuck_`
- `_fuck`
(capitalized)
- ` Fuck`
- `Fuck `
- `Fuck_`
- `_Fuck`
(uppercase)
- ` FUCK`
- `FUCK `
- `FUCK_`
- `_FUCK`
although that would ignore a lot of variables such as `FuckThisShit` `godFuckingDaminit`,
I believe as a first check we can compare the counts for
- (` fuck` or `fuck ` or `fuck_` or `_fuck`) with plain ol' `fuck`
- same with capitalized and uppercase
- same with other swear words ((`shit_` or ...)  to `shit`)
this might give us an intial idea of how to move forwards in this fuckery

another plan which we may save for later/for when I have a better clue on how to move in here, would be
- get the results for `fuck`, just good ol' `fuck`, and a pagination of 1k results, with annexed text matches (which we know github can do)
  go through all the matches you got and for *those* matches, regex to get a finer estimate
  infer/extrapolate whatever info from the results of the various matches
