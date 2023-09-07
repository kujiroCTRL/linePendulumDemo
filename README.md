# `linePendulumDemo.pde`: una simulazione realistica di un pendolo a lenza
di Lorenzo Casavecchia < `lnzcsv@gmail.com` >

## Descrizione
`linePendulumDemo.pde` consiste in una semplice simulazione scritta in `Processing 4.3` di un sistema a pendolo costituito da una massa soggetta alla forza di gravità e vincolata da una lenza collegata ad essa e ad un punto fermo (detto pivot) 

L'obbiettivo della simulazione è realizzare e analizzare un modello base che possa rappresentare il comportamento di un sistema a pendolo reale che non assuma l'idealità del mezzo di collegamento al vincolo (in questo caso una lenza) e che non la ponga necessariamente in tensione 

Il modello è stato realizzato in modo da essere compreso da studenti di fisica del liceo, quindi usando idee e concetti visti a scuola

Ad esecuzione verrà aperta una finestra con il disegno del sistema in questione

La simulazione è stata implementata considerando il bilancio delle forze al
centro di massa, quindi le componenti radiale e tangenziale delle forze
applicate su di essa

Dal valore della forza è possibile ricavare. usando il secondo principio di Newton, l'accelerazione radiale $a_r$ ed angolare $a_\tau$

$$
\begin{align*}
	\displaystyle a_r&=\frac{F_r}m \\
	\displaystyle a_\theta&=\frac{F_\theta}{mr^2}
\end{align*}
$$

Dalle accelerazioni possiamo calcolare le velocità radiale e angolare, ricordando che l'accelerazione è la variazione della velocità nel tempo

$$
\begin{align*}
    \displaystyle a(t+\delta_t) &= \frac{v(t+\delta_t) - v(t)}{\delta_t} \\
    \displaystyle v(t+\delta_t) &= v(t) + \delta_t a(t+\delta_t)
\end{align*}
$$

per ambe $a=a_r$ ed $a=a_\theta$, rispettivamente $v=v_r$ e $v=v_\theta$

Similmente possiamo calcolare i valori del raggio e l'angolo della lenza rispetto la verticale, ricordando che la velocità è la variazione della posizione o dell'angolo nel tempo

$$
\begin{align*}
	\displaystyle v(t+\delta_t) &= \frac{x(t+\delta_t) - x(t)}{\delta_t} \\
 	\displaystyle x(t+\delta_t) &= x(t) + \delta_t v(t+\delta_t)
\end{align*}
$$

per ambe $v=v_r$ e $v=v_\theta$, rispettivamente $x=r$ e $x=\theta$

Le forze agenti sulla massa sono:
- la forza di gravità rivolta verso il basso
- la tensione della lenza rivolta radialmente verso il pivot
- delle forze di attrito radiale e tangenziale

La gravità è sempre agente mentre la tensione $T$ è nulla se la lunghezza $r$ della lenza non dovesse superare la lunghezza a riposo (la lenza non è in tiro) e cresce linearmente con la lunghezza se questa dovesse superare la lunghezza a riposo (segue quindi la legge di Hooke per la forza elastica)

$$
T(r)=
\begin{cases}
	0 & r\lt R \\
	kr & r\geq R
\end{cases}
$$

Le forze di attrito radiale e tangenziale sono tra loro indipendenti, rendono la simulazione più realistica e sono di tipo viscoso quindi proporzionali rispettivamente alla velocità radiale e tangenziale, ma sempre in opposizione al moto 

$$
\mu(v)=-bv
$$

La dinamica complessiva della massa è descritta dalle seguenti equazioni espresse in coordinate polari (con un sistema di riferimento centrato nel pivot e assi di riferimento $r$ e $\theta$ radiale e tangenziale al pivot)

$$
\begin{cases}
	 a_r(t+1)
 		&= g \cos\theta(t)
   		+ k v_\theta(t) ^ 2
        - b_r v_r(t) 
 		+ \begin{cases}
   			0 &  r(t) \lt R \\
   			- \frac k m (r(t) - R) & r(t) \geq R
      		\end{cases} \\
	a_\theta(t+1)
  		&= -\frac{g}{r(t)} \sin\theta(t)
    		- \frac 2{r(t)} v_r(t) v_\theta(t)
      		- b_\theta v_\theta(t) \\
	v_r(t+1)
 		&= v_r(t) + a_r(t) \delta_t \\
   	v_\theta(t+1)
    		&= v_\theta(t) + a_\theta(t) \delta_t \\
      	r(t+1)
       		&= r(t) + v_r(t) \delta t \\
	\theta(t+1)
 		&= \theta(t) + v_\theta(t)\delta_t
\end{cases}
$$

## Funzionalità implementate
La funzione `setup` viene eseguita una sola volta all'inizio dell'esecuzione ed è responsabile di impostare i valori base dei parametri

È importante notare che tutte le variabili assumono come unità di misura base:
- centimetri per distanza
- radianti per angoli

La funzione `draw` viene eseguita `frameRate` volte in un secondo ed è responsabile dei calcoli e della grafica

E' importante osservare che la grafica (la visualizzazione del sistema) viene gestita prima del calcolo dei parametri

La funzione `mousePressed` gestisce tutte le interazioni con l'utente attualmente previste

Premendo i seguenti tasti è possibile modificare la simulazione:
- `q` e `Q` chiudono la simulazione
- `m` ed `M` spostano la massa alla posizione del cursore
- `e` ed `E` spostano la massa alla posizione d'equilibrio
- `p` e `P` mettono in pausa la simulazione
- `+` e `-` aumentano e diminuiscono il fattore di ingrandimento
- `s` ed `S` effettuano la cattura della scena
- `r` ed `R` generano ed applicano uno schema di colori casuale (`r` per un tema scuro, `R` per uno chiaro)
- `b` e `B` applicano uno schema di colori bianco e nero di base (`b` per il tema scuro, `B` per il tema chiaro)
- `h` ed `H` per nascondere o mostrare le linee delle forze agenti sulla massa

Inoltre premendo `m` o `M` il sistema scriverà sul file `pendulumData.csv` i parametri variabili del sistema su un file `.csv` (acronimo di comma-seperated-values, quindi valori separati da virgole)

Le colonne in `pendulumData.csv` comprendono il numero di millisecondi passati dall'avvio della simulazione, le misure dell'angolo della lenza rispetto la verticale (comprese velocità e accelerazione angolare) e le misure della distanza della massa dal pivot (comprese velocità e accelerazione)

Premendo invece `q`, `Q`, `e` oppure `E` la scrittura su file dei dati verrà interrotta

Similmente premendo `p` o `P` la scrittura verrà momentaneamente sospesa, fino a quando l'esecuzione verrà riavviata premendo nuovamente `p` o `P`
