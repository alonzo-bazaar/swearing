due cose
è stato constatato che cercare parole prima e filtrare dopo sarebbe risultato diversamente fattibile
infatti molte parole compaiono centinaia di migliaia di volte, e iterare tutti i risultati sarebbe risultato infattibile, infatti dati i rate limit dell'api di github (10 query al minuto per code search), iterare tutte quelle migliaia di risultati avrebbe portato a ore, se non giorni o settimane, di query

abbiamo quindi deciso di filtrare prima e cercare parole nelle repo filtrate, dove con filtrare intendiamo filtrare per
- minimo 10 star
- minimo 3 contributor (per non escludere sqlite)
- ultimo commit negli ulitimi 3 mesi
- fork escluse
- minimo 500 righe non blank
- minimo 500 righe di codice

fare questo ha portato ad avere poche centinaia di migliaia di risultati, invece che milioni, questo sarebbe però stato comunque qualche bella ora di mining, per circumnavigare questo limite dell'api di github (senza metterci a fare un botnet) ci siamo avvalsi del tool [seart ghs](https://seart-ghs.si.usi.ch/#), tool per ricerca su github, c'è il paper su [arxiv](https://arxiv.org/abs/2103.04682)

Vi è una nota da fare su questo tool, vedendo il loro arxiv, ghs è descritto come:
> a dataset containing 25 characteristics (e.g., number of commits, license, etc.) of 735,669 repositories written in 10 programming languages
e i 10 linguaggi di programmazione presenti nel database di ghs sono:
- Python
- Jupyter Notebook
- JavaScript
- TypeScript
- C
- C++
- C#
- GO
- Java
- PHP

Postum Scriptum alla nota sopra
dopo aver scaricato na marea de roba ho deciso di dividerla in più file tramite il seguente scriptino python
```python
import csv
import sys

INPUT_FILE  = sys.argv[1] if len(sys.argv) > 1 else 'data.csv'
LANG_ROWS   = {}
FIELD_NAMES = None

with open(INPUT_FILE, 'r') as file:
    dr = csv.DictReader(file)
    FIELD_NAMES = dr.fieldnames
    for row in dr:
        ml = row['mainLanguage']
        if ml not in LANG_ROWS:
            LANG_ROWS[ml] = []
        LANG_ROWS[ml].append(row)

for lang in LANG_ROWS.keys():
    file_name = f'{lang}.csv'
    with open(file_name, 'w') as file:
        cw = csv.DictWriter(file, fieldnames=FIELD_NAMES)
        cw.writeheader()
        for row in LANG_ROWS[lang]:
            cw.writerow(row)
```
piccolo problema, dall'abstract paper pareva che mainLanguage avrebbe avuto 10 opzioni, sputando quindi fuori 10 file
ma sto script me ne ha sputate fuori ben 44
nel paper dicevano di voler aggiungere linguaggi, come sviluppi futuri, quindi ho visto nella repo dove/se avessero una lista di linguaggi, e
[ce ne hanno una](https://github.com/seart-group/ghs/blob/master/src/main/resources/application.properties), ed è effettivamente di 44 linguaggi

quindi il problema di sopra che non c'erano abbastanza linguaggi non è presente, tutti i linguaggi che volevamo considerare sono effettivamente nel dataset di ghs

ah, e pure loro filtrano per 10 stelle, ma nella costruzione del database proprio, quindi 5 stelle noi non ci si faceva comunque, da ghs minimo 10 per costruzione loro

# quindi quante repo c'abbiamo da fare?
l'originale (con tutti i linguaggi) era
```bash
wc -l results.csv
# 183177 results.csv
```
183176 repository (+ 1 riga di header), mentre i linguaggi separati sono
```
wc -l JavaScript.csv Python.csv  TypeScript.csv  Java.csv C++.csv C.csv C#.csv PHP.csv Kotlin.csv Ruby.csv Swift.csv Go.csv
#  14978 JavaScript.csv
#  39514 Python.csv
#  28697 TypeScript.csv
#  10278 Java.csv
#  10033 C++.csv
#   7324 C.csv
#   7265 C#.csv
#   6547 PHP.csv
#   3894 Kotlin.csv
#   3101 Ruby.csv
#   2596 Swift.csv
#  14833 Go.csv
# 149060 total
```
scremando per linguaggi ci siamo levati un dignitoso 30k

## tempo stimato?
mettiamo abbiamo 20 parolaccie  
dalla rest api di github abbiamo 10 query al minuto, quindi una query ogni 6 secondi ammortizzati  
e, dopo i filtri del caso, abbiamo 149060 repo  
in totale ci vorrebbero
- ` (* 20 6 149060) ` 17887200 secondi, che sono
- ` (/ 17887200 60) ` 298120 minuti
- ` (/ 17887200 (* 60 60)) ` 4968 ore
- ` (/ 17887200 (* 24 60 60)) ` 207 giorni
sta cosa potrebbe essere un problema

> la sintassi strana per i calcoli è visto che sto scrivendo sto report in emacs e quindi posso eseguire codice lisp inline e usarlo come calcolatrice

### ma se clonassimo?
l'autore ha provato a effettuare la seguente prova per vedere se la pazza opzione di clonare direttamente fosse meglio o peggio di passare per l'api
```bash
#!/usr/bin/env bash

REPO='torvalds/linux'
URL="https://github.com/${REPO}"
METH_DIR="${PWD}/meth"
WORDS=( fuck shit cunt bitch dick )

git clone -q --depth 1 "${URL}" "$METH_DIR"

echo "${SECONDS},word,count"
for word in "${WORDS[@]}"; do
    echo -n "${SECONDS},${word},"
    grep "\\b${word}\\b" -ri "${METH_DIR}" | wc -l
done

rm -rf "${METH_DIR}"
```

La variabile `SECONDS` di bash tiene conto di quanto tempo è passato da quando la shell è stata invocata, in questo caso terrebbe quinti conto di quanto tempo è passato dal lancio dello script.

è stata scelta una repo volutamente gigantesca, il kernel linux, per testare questo approccio nelle condizioni più pesanti possibile, l'output di questo script è sotto riportato

```
$ ./fuck.bash
126,word,count
126,fuck,4
131,shit,22
136,cunt,0
140,bitch,6
144,dick,20
```
per repo sufficientemente grosse quindi direi che questa cosa non funziona, oltre ai 2 minuti di upfront, lo script impiega sui 5 secondi per ricerca di parola (il tempo di una chiamata rest per il nostro caso d'uso sarebbe 6 secondi)

ma se come `REPO` ne mettiamo una più "piccola" quale, per esempio, apache httpd
```
$ ./fuck.bash
8,word,count
8,fuck,0
8,shit,0
8,cunt,0
9,bitch,1
9,dick,0
```
possiamo vedere che clonare è molto più veloce che passare per l'api rest di github, e offre maggiore flessibilità nella ricerca
> **NOTA:**
> lo script di sopra non limita ancora la ricerca a file di codice
> per fare quello in bash ci sarebbe da fare degli azzigogoli
> altrimenti si può fare tutto in perl, ma quello vediamo meglio poi
> qui stiamo esplorando il nostro dataset

per vedere se ha senzo quest'approccio rispetto a passare per l'api vediamo com'è distribuita la dimensione delle repo sul nostro dataset,
utilizzando abbastanza brutalmente il numero di righe come proxy per la dimensione della repo (ignorando quindi la dimensione che una riga possa avere rispetto a un'altra) possiamo buttare giù il seguente scriptino python

```python
#!/usr/bin/env python
import csv
import sys
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

INPUT_FILE  = sys.argv[1] if len(sys.argv) > 1 else 'data.csv'

with open('results.csv', 'r') as file:
    dr = csv.DictReader(file)
    lines = [row['codeLines'] for row in dr]

lines = np.asarray(lines, dtype=np.uint64)
hist, edges = np.histogram(lines, bins=100)
plt.bar(np.arange(len(hist)), hist)
plt.show()
```

abbiamo ottenuto i file
- `./files-for-report/code_lines_distrubution.png`
- `./files-for-report/code_lines_distrubution_logy.png`  
  (mettendo `plt.yscale('log')`)
  
l'array `lines` ha le seguenti staistiche
possiamo vedere che la media è 10 volte sotto la mediana, e che la mediana è migliaia di volte sotto il max, questo ci suggerisce una distrubuzione con poche repo giganti e molte repo decisamente più piccole
```
min:    | 500
max:    | 146881452
mean:   | 207236.00316089444
median: | 25798.5
std:    | 1364912.6120845396
```

dai plot possiamo vedere che la distribuzione è tremendamente front heavy, quindi l'approccio clona e greppa potrebbe non essere troppo male.

se adesso vediamo `apache/httpd` quante righe era rispetto alla media, ricordando che per `apache/httpd` ci sono voluti 10 secondi a fare quello che con l'api rest ne avrebbe richiesti 30
```python
with open('results.csv', 'r') as file:
    dr = csv.DictReader(file)
    for row in dr:
        if row['name'] == 'apache/httpd':
            print(f'httpd codeLines: {row['codeLines']}')
```
ci da `httpd codeLines: 571311`, `apache/httpd` ha dimensione circa il doppio della mediana, o 20 volte la media.

Quindi circumnavigare l'api di github e clonare tutto potrebbe effettivamente essere la giocata per questo studio.
(per quanto ci servirebbe comunque una macchina per farlo)

se invece dei 2 minuti per repo stimati sopra usiamo i 10 secondi stimati col test httpd, il tempo richiesto per la fase dimining diventa

- ` (* 10 149060) ` 1490600 secondi, che sono
- ` (/ 1490600 60) ` 24843 minuti
- ` (/ 1490600 (* 60 60)) ` 414 ore
- ` (/ 1490600 (* 24 60 60)) ` 17 giorni

che, direi, sembra un po' più fattibile
questo meglio vederlo con calma a un ricevimento

# threats to validity
Per quanto il nostro studio miri a studiare l'uso di parolacce in generico ambito software, le seguenti limitazioni sono state fatte a fini di feasibility
durante il nostro studio, con l'assunzione che le restrizioni in questione non andassero a inferire con la validità dei risultati ottenuti.  
Le restrizioni in questione sono le seguenti:
- ci siamo limitati al dataset di seart ghs invece di tutto github:  
  github a oggi (Q2 2026) contiene 453,514,308 [repository](https://innovationgraph.github.com/global-metrics/repositories), mentre (almeno dalla pubblicazione) ghs ne contiene 735,669, ci stiamo quindi limitando *parecchio* nelle repo che andiamo a osservare, oltre a questa (pesante) scrematura iniziale, vale evidenziare che ci stiamo limitando anche a
  - le repo che hanno scelto di indicizzare loro
  - i linguaggi che hanno scelto di indicizzare
  che sono entrambe decisioni fatte da terzi che, direi, un po' di validity la potrebbero threat-are

- ci siamo inoltre limitati, nei limiti del dataset di seart ghs, a repository con le caratteristiche riportate in cima a questo documento (minimo di star, righe, contributor)
  caratteristiche che sono state scelte dagli autori per evitare di andare a leggere un fottio di
  - repo giocattolo
  - repo buttate li giusto per
  - repo usate come google drive per i dotfile dell'autore
  - e via dicendo

