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

The code search (docs [here](https://docs.github.com/en/search-github/github-code-search)) [does support regex and wildcards](https://docs.github.com/en/search-github/github-code-search/understanding-github-code-search-syntax?apiVersion=2026-03-10#using-regular-expressions)  
but the github code search is part of their webui and not available as part of their rest api, it doesn't provide us with the tools to programmatically search all of github for words of interest, this is particularly evident looking at the page for [using the code search](https://docs.github.com/en/search-github/github-code-search/using-github-code-search) (it's all searchbars and no curl)

we have furthermore found that
- the 2022 version of the rest api does not have boolean operators: [source](https://github.com/orgs/community/discussions/125409)
- the 2022 version of the rest api does not have regex support:     [source](https://github.com/orgs/community/discussions/112338)
it is unclear wether the 2026 vrsion of the rest api does support boolean operators,
but from the author trying to use said boolean operators it appears that the api does *not* support explicit `AND` and `OR` operators
although juxtapposition does work as an implicit "and" there is no trace of an implicit or explicit "or", which is what the author was looking for

The page for [the search api (2026 version)](https://docs.github.com/en/rest/search/search?apiVersion=2026-03-10) does mention `AND`, `OR`, and `NOT` operators, but it does not by itself go further on those operators, instead redirecting the user to the page for the search syntax.
The page for [the search syntax](https://docs.github.com/en/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax) only talks about the `NOT` operator and does not mention neither `AND` nor `OR`.

to illustrate the lack of `AND` and `OR` operators the reader may inspect the `try_operators.bash` script, after providing the appropriate `GITHUB_TOKEN` variable to the aphorementioned script, the output should look like (at the time of writing)
```
count of ["fuck"]: 107776
count of ["shit"]: 396288
count of ["fuck" "shit"]: 12768
count of ["fuck" AND "shit"]: 12288
count of ["fuck" "and" "shit"]: 12288
```
so... yeah the `AND` in there is taken as a searched key and not as an operator

The lack of a supported `OR` operator means we can't look for more words in one api call and will have to make separate calls for every word we're looking for, this is particularly unfortunate for our use case. To illustrate the reason as to why let us consider looking or different forms in which the word `fuck` may be present in a source code file, say we're interested in:
- `fuck`
- `fuck `
- ` fuck`
- ` fuck `
- `fuck_`
- `_fuck`
- `_fuck_`
this will have to be 7 different api calls
which means, with github search rest api rate limit of 10 requests per minute,
roughly one swear word every 45 seconds,
or ~3 swear words every 2 minutes.

At least the search results are case insensitive so we won't need to do the same thing for `Fuck` and `FUCK`, meaning 7 calls instead of 21 calls per swear word, which would have been quite the load of fuck.

as an additional aside:
Min commits, min contributors, and a lot of other shit we'd like to check
do not seem to be supported by the github repository search rest api.
As of writing at least, none of them are listed in the [documentation](https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories)

min contributors would be enforceable, by adding even more api calls, (one per repo)
see [repo search api docs](https://docs.github.com/en/rest/repos/repos?apiVersion=2026-03-10#list-repository-contributors) for further info
there does not seem to be a rate limit for the /repos endpoint and its sub-endpoints
(it is not listed [in the docs for rate limits](https://docs.github.com/en/rest/rate-limit/rate-limit?apiVersion=2026-03-10))
but getting the contributor amount for all repos would require having the links for all reposm,
which would require paginating through all the repos returned by our /search api call

I'm afraid for commits it's the same thing, though I have yet to check
so I am currently only using min stars as a filter

## plan of attack
[to be formulated]

> another plan which we may save for later/for when I have a better clue on how to move in here, would be
> - get the results for `fuck`, just good ol' `fuck`, and a pagination of 1k results, with annexed text matches (which we know github can do)
>   go through all the matches you got and for *those* matches, regex to get a finer estimate
>   infer/extrapolate whatever info from the results of the various matches
