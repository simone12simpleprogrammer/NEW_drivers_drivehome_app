import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const FittedBox(
          child:Text(
            "Informativa sulla privacy",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: const [


              SizedBox(height:20,),
              Text(
                "Soggetti Interessati: utenti registrati all'applicazione\n",
                style : TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Drivehome, nello specifico la persona di Simone Demichele, in qualità di Titolare del trattamento dei Suoi dati personali, ai sensi e per gli effetti del Reg.to UE 2016/679 di seguito 'GDPR', con la presente La informa che la citata normativa prevede la tutela degli interessati rispetto al trattamento dei dati personali e che tale trattamento sarà improntato ai principi di correttezza, liceità, trasparenza e di tutela della Sua riservatezza e dei Suoi diritti.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "I Suoi dati personali verranno trattati in accordo alle disposizioni legislative della normativa sopra richiamata e degli obblighi di riservatezza ivi previsti.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Finalità e base giuridica del trattamento: in particolare i Suoi dati verranno trattati per le seguenti finalità connesse all'attuazione di adempimenti relativi ad obblighi legislativi o contrattuali:\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "• accesso tecnico e Funzionale all' Applicazione nessun dato viene tenuto dopo la chiusura del Browser;\n"
                    "• finalità di navigazione Evoluta o gestione dei contenuti personalizzata;\n"
                    "• finalità Statistica e di Analisi della navigazione e degli utenti.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Ai fini dell'indicato trattamento, il Titolare potrà venire a conoscenza di categorie particolari di dati personali ed in dettaglio: Log File di Navigazione Internet, origini razziali o etniche. I trattamenti di dati personali per queste categorie particolari sono effettuati in osservanza dell'art 9 del GDPR.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "I Suoi dati personali potranno inoltre, previo suo consenso, essere utilizzati per le seguenti finalità:\n\n• finalità di Marketing e Pubblicità.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Il conferimento dei dati è per Lei facoltativo riguardo alle sopraindicate finalità, ed un suo eventuale rifiuto al trattamento non compromette la prosecuzione del rapporto o la congruità del trattamento stesso.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Modalità del trattamento. I suoi dati personali potranno essere trattati nei seguenti modi:\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "• a mezzo calcolatori elettronici con utilizzo di sistemi software gestiti da Terzi;\n"
                    "• a mezzo calcolatori elettronici con utilizzo di sistemi software gestiti o programmati direttamente;\n"
                    "• trattamento temporaneo in Forma Anonima.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Ogni trattamento avviene nel rispetto delle modalità di cui agli artt. 6, 32 del GDPR e mediante l'adozione delle adeguate misure di sicurezza previste.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Comunicazione : i suoi dati saranno comunicati esclusivamente a soggetti competenti e debitamente nominati per l'espletamento dei servizi necessari ad una corretta gestione del rapporto, con garanzia di tutela dei diritti dell'interessato.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "I suoi dati saranno trattati unicamente da personale espressamente autorizzato dal Titolare ed, in particolare, dalle seguenti categorie di addetti:\n\n• programmatori e Analisti;\n• ufficio Marketing;\n• banche e istituti di credito;\n• clienti ed utenti;\n• subfornitori.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Diffusione: I suoi dati personali non verranno diffusi in alcun modo.\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "I suoi dati personali potranno inoltre essere trasferiti, limitatamente alle finalità sopra riportate, nei seguenti stati:\n\n• paesi UE;\n• Stati Uniti.\n\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Periodo di Conservazione\n",
                style : TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Le segnaliamo che, nel rispetto dei principi di liceità, limitazione delle finalità e minimizzazione dei dati, ai sensi dell’art. 5 del GDPR, il periodo di conservazione dei Suoi dati personali è:\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "• stabilito per un arco di tempo non superiore al conseguimento delle finalità per le quali sono raccolti e trattati per l'esecuzione e l'espletamento delle finalità contrattuali;\n"
                    "• stabilito per un arco di tempo non superiore all'espletamento dei servizi erogati;\n"
                    "• stabilito per un arco di tempo non superiore al conseguimento delle finalità per le quali sono raccolti e trattati e nel rispetto dei tempi obbligatori prescritti dalla legge.\n\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Le società pubblicitarie consentono inoltre di rinunciare alla ricezione di annunci mirati, se lo si desidera. Ciò non impedisce l'impostazione dei cookie, ma interrompe l'utilizzo e la raccolta di alcuni dati da parte di tali società.\n\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Per maggiori informazioni e possibilità di rinuncia, visitare l'indirizzo www.youronlinechoices.eu/. \n\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Titolare: il Titolare del trattamento dei dati, ai sensi della Legge, è Simone Demichele, CF:DMCSMN97T09L328T, e-mail: info@drivehome.it .\n\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height:3,),
              Text(
                "Lei ha diritto di ottenere dal titolare la cancellazione (diritto all'oblio), la limitazione, l'aggiornamento, la rettificazione, la portabilità, l'opposizione al trattamento dei dati personali che La riguardano, nonché in generale può esercitare tutti i diritti previsti dagli artt. 15, 16, 17, 18, 19, 20, 21, 22 del GDPR.\n\n"
                    "Potrà inoltre visionare in ogni momento la versione aggiornata della presente informativa collegandosi all'indirizzo internet https://www.privacylab.it/informativa.php?11446352289.\n\n",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height:10,),

              Text(
                "Reg.to UE 2016/679: Artt. 15, 16, 17, 18, 19, 20, 21, 22 - Diritti dell'Interessato\n",
                style : TextStyle(
                  fontSize: 27,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "1. L'interessato ha diritto di ottenere la conferma dell'esistenza o meno di dati personali che lo riguardano, anche se non ancora registrati, e la loro comunicazione in forma intelligibile.\n\n"
                    "2. L'interessato ha diritto di ottenere l'indicazione:\n\n"
                    "• dell'origine dei dati personali;\n"
                    "• delle finalità e modalità del trattamento;\n"
                    "• della logica applicata in caso di trattamento effettuato con l'ausilio di strumenti elettronici;\n"
                    "• degli estremi identificativi del titolare, dei responsabili e del rappresentante designato ai sensi dell'articolo 5, comma 2;\n"
                    "• dei soggetti o delle categorie di soggetti ai quali i dati personali possono essere comunicati o che possono venirne a conoscenza in qualità di rappresentante designato nel territorio dello Stato, di responsabili o incaricati.\n\n"
                    "3. L'interessato ha diritto di ottenere: \n\n"
                    "• l'aggiornamento, la rettificazione ovvero, quando vi ha interesse, l'integrazione dei dati;\n"
                    "• la cancellazione, la trasformazione in forma anonima o il blocco dei dati trattati in violazione di legge, compresi quelli di cui non è necessaria la conservazione in relazione agli scopi per i quali i dati sono stati raccolti o successivamente trattati;\n"
                    "• l'attestazione che le operazioni di cui alle lettere a) e b) sono state portate a conoscenza, anche per quanto riguarda il loro contenuto, di coloro ai quali i dati sono stati comunicati o diffusi, eccettuato il caso in cui tale adempimento si rivela impossibile o comporta un impiego di mezzi manifestamente sproporzionato rispetto al diritto tutelato;\n"
                    "• la portabilità dei dati.\n\n"
                    "4. L'interessato ha diritto di opporsi, in tutto o in parte:\n\n"
                    "• per motivi legittimi al trattamento dei dati personali che lo riguardano, ancorché pertinenti allo scopo della raccolta;\n"
                    "• al trattamento di dati personali che lo riguardano a fini di invio di materiale pubblicitario o di vendita diretta o per il compimento di ricerche di mercato o di comunicazione commerciale.\n\n\n"
                    "Questa applicazione non utilizza i cookie.",
                style : TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
