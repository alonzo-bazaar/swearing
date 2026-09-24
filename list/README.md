# sources
Following sources were used to create our swear word list
- `wikipedia-list.txt` was obtained from [wikitionary](https://en.wiktionary.org/wiki/Category:English_swear_words)
- image from [englishtake](https://englishintake.com/bad-words-in-english/)
  englishtake took it from [lingoapt](https://lingoapt.com)
  neither website had any machine readable text accompanying the image so the text was extracted with an ocr engine (tring tessaract rn) 
- `en.txt` was taken from [github](https://raw.githubusercontent.com/dsojevic/profanity-list/refs/heads/main/en.txt)
- `fulldict.xml` from [noswearing.com](https://noswearing.com/fulldict.xml)  
  `fulldict.txt` was obtained by
  ```sh
  perl -e 'while(<>){chomp;print"$1\n" if $_ =~ qr\'^\s*<title>([a-zA-z- ]+)</title>\s*$\';}' fulldict.xml > fulldict.txt
  ```
> note: [noswearing.com](https://noswearing.com) technically holds copyright over the list present at fulldict.xml, the list may be excluded from any of the processing pipelines listed below were that copyright to become an issue

`en.txt` in particular, though our largest list, contained a lot of "stray" entries, it contains for instance about 6 entries pertaining to "2 girls 1 cup", a notorious internet shock video, quite useful to know about in the context of filtering swear words out of a forum message, perhaps, but of questionable use for our study, the "stray" entries were kept because the author saw little point in taking the time to remove them.

Reader discretion is advised when viewing the aphorementioned sources, as they contain some rather foul vocabulary, for exposition's sake some of the following foul vocabulary has been replicated in writing in the remainder of this report, so reader discretion is advised for the viewing of this report as well.

# final list obtained by
Our final list was obtained by mergin the information from all the above sources into something workable
this was done by
- concatenating everything
- doing some preliminary filtering
- normalizing every element in the concatenation, to ensure that any difference in convention from the various lists was dealt with for our list
- removing any duplicates from the normalized concatenation
- some postprocessing to handle multi word swear phrases (such as `cum shot` or `tea bagged`)

## handling of numbers
The only file containing digits amoung our sources was `en.txt`, a simple `grep -e '[[:digit:]]' en.txt` revealed that only the following list entries results contained digits.
```
1 man 1 jar
1m1j
1man1jar
2 girls 1 cup
2g1c
2girls1cup
masterb8
masturb8
```
the author decided to discard these entries for the final list, as their inclusion was of little use for the study at hand.

## handling of spaces/dashes
Phrases in separate bits of the list were separated either by spaces or by dashes, so all dases were turned into spaces (imagine `tr '-' ' '`).
Spaces were later normalized (consecutive spaces turned into a single space, leading and trailing spaces were removed from all entries)

## other normalization steps
Everything was downcased, and we ensured that the final list contained only lowercase ascii letters.

Plurals were moved to a separate list, to find plurals the list was matched against the `s\b` regex, and the result was manually reviewed by the author to ensure no false positives (for instance, `ass` or `cunnilingus` are both in the list, match `s\b`, but are singular).
Items present in the plurals list were later removed from the singulars list.

## handling of phrases and case
Many swear words in the list were phrases of two or more words, for instance `cum shot` or `tea bagged`, in the spirit of the original paper these were handled by, for each phrase, adding the following items to our normalized list
(most likely matching comments)

- the unaltered phrase `cum shot`
- the phrase with the first word capitalized `Cum shot`
- the fully capitalized phrase `Cum Shot`
- the fully upcased phrase `CUM SHOT`

(most likely matching variable names)
- the phrase joined by lower snake case `cum_shot`
- the phrase joined by upper snake case `Cum_Shot`
- the phrase joined by capitalized snake case `CUM_SHOT`
- the phrase joined by camel case `cumShot`
- the phrase joined by pascal case `CumShot`

# final process
- to obtain full list (singulars and plurals) -> `merge.bqn`
- to create plurals list -> regex described above and author manual creation of `plurals.txt`
- to separate plurals list -> `split.bqn`
- to turn phrases of singulars into camel case et al. -> `camelify.bqn`

the full pipeline may be found at `pipeline.sh`
