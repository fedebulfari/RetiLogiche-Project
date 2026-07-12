La seguente è una relazione tecnica sulla creazione di un componente, descritto in linguag- gio VHDL ed implementato su una FPGA Artix-7 FPGA xc7a200tfbg484-1, in grado di leggere da una memoria RAM una sequenza di dati, interpretarli, applicare a scelta due tipi di filtri differenziali e salvare i risultati sulla memoria RAM.

## Richiesta

Dato un flusso di dati in ingresso, creare un componente in grado di:

- A start '1' iniziare la lettura. Leggere i primi due Byte (K1, K2) dichiaranti la lunghezza della sequenza di valori.

- Leggere il bit meno significativo del terzo Byte, dichiarante il filtro da usare('0' per il filtro 3, '1' per il filtro 5).

- Leggere altri 14 Byte contenenti i coefficienti da utilizzare (7 per ogni filtro).

- Leggere i valori in ingresso per la lunghezza specificata.

- Applicare la funzione f'(i) C; f[j +i] ai dati letti.

- filtro 3: 1 2. filtro 5: 1= 3.

- filtro 3: n= 12. filtro 5: n = 60.

- Scrivere in memoria, alla prima posizione libera dopo la sequenza di valori, i risultati delle operazioni.

- Porre il segnale done a '1' a processo concluso. Quando il segnale start va a '0' porre done a '0'
