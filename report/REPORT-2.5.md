# Baseline
Le avevo detto l'altra volta che ci volevano 10 second a clonare e greppare httpd per quelle 10 circa parole, no?

Sulla mia macchina (decente) e col mio wifi (di merda), clonare httpd richiede un wall clock time di 10 secondi, e testata con una lista di 300 parole, usare la command line di ripgrep per fare 300 grep su httpd impiega 15 secondi.

Questo ci da un totale di 10 + 15 = 25 secondi per cercare 300 parole in una repo.

300 parole in 25 secondi sarebbe comunque uno speedup di ordini di grandezza rispetto all'api di github, che per fare tutto quello in query richiederebbe 300 query, 10 query al minuto, 30 minuti, na mezz'oretta.

# Possibili speedup
Le ho detto a santa marta che stavo facendo una versione in BQN
con questa versione abbiamo ottenuto uno speedup della madonna%
```
$ time find data/httpd/ -type f -name '*.[ch]' -print0 | ./ohdzaima.bqn wordlist > /dev/null

________________________________________________________
Executed in  580.42 millis    fish           external
   usr time  561.80 millis    0.00 millis  561.80 millis
   sys time   35.45 millis    2.74 millis   32.70 millis
```
fare il globbing da bqn era parecchio lento lentissimo quindi qui ci sarebbe una dependency extra, `find`, ma è una coreutil standard
vi è un'ulteriore dependency visto che lo script bqn chiama una funzione di `libicuuc.so` (libreria sviluppata dallo unicode consortium) ma pure quella è abbastanza standard.

Dopo aver raggiunto un sufficiente grado di compatibilità con ripgrep per la versione in BQN, ho pensato di fare una versione in rust per completezza, la versione rust spacca culi.

Per intenderci, pure quella BQN, per essere stata fatta in 2 giorni senza librerie, ma rust ha un'engine regex della madonna e una fracca di librerie per multithreading che so' na cazzata da utilizzare.

misurando sempre a wall clock time, per cercare le stesse 300 parole sul branch master (abe, trunk) di httpd
- la versione BQN  (single threaded) ci mette 0.5  secondi
- la versione rust (single threaded) ci mette 0.3  secondi
- la versione rust (multithreaded)   ci mette 0.15 secondi (probabile configurata male qualche parte del map reduce)

Quindi possiamo abbastanza arrtondare il tempo per cercare 300 parole in una repo a quei 10 secondi richiesti per fare il clone, *ma*,
avevo scritto sopra che a _wall clock time_ ci volevano 10 secondi a clonare httpd, ma se vediamo le tempistiche più nel dettagio.
```
$ time git clone --quiet --depth=1 --branch=trunk https://github.com/apache/httpd

________________________________________________________
Executed in    9.26 secs    fish           external
   usr time    1.73 secs    1.13 millis    1.73 secs
   sys time    0.72 secs    2.12 millis    0.72 secs
```
da usr time e sys time si può vedere che buona parte di quei 10 secondi di wall clock time è stato passato in idle ad aspettare dati da github.
magari a fare più clone in parallelo non avremo un tempo medio di 2 secondi e mezzo di usr time + sys time, ma mettiamo 5 secondi, per essere pessimisti.

# Stima di tempo
Ricordando dal report precedente che httpd è 10 volte più grosso (per righe di codice) della repo media presente nel nostro database, teniamo un attimo quei 5 secondi come stima (pessimista) di quanto tempo ci vorrà a processare *una* repo delle nostre 149060

questo ci porta a un tempo stimato in giorni di (le lascio la shell python sotto per ridere)
```
$ python
>>> seconds = 149060 * 5
>>> minutes = seconds / 60
>>> hours = minutes / 60
>>> days = hours / 25
>>> print(f'{seconds} secondi -> {minutes} minuti -> {hours} ore -> {days} giorni')
745300 secondi -> 12421.666666666666 minuti -> 207.02777777777777 ore -> 8.28111111111111 giorni
```
diciamo una settimana e mezzo, probabile meno, ma diciamo una settimana e mezzo.

# Future work
L'obbiettivo adesso sarà prendere quella bestia fatta in rust e inserirla all'interno di una qualche pipeline che ci dia effettivamente in output dei dati aggregati per un *listone* di repo (al momento tutti questi programmi hanno un output abbastanza di debug)

Anche se per sapere quali dati vogliamo andare ad aggregare ci s'avrebbe da vederci per capire quali RQ vogliamo andare ad investigare, per capire quali dati andare effetivamente a prendere.
