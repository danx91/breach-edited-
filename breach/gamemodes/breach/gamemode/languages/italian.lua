italian = {}

italian.roundtype = "Tipo di round: {type}"
italian.preparing = "Preparati, il round inizierà in {num} secondi"
italian.round = "La partita è iniziata, buona fortuna!"
italian.specialround = "Questo è un round speciale"

italian.lang_pldied = "{num} giocatori morti"
italian.lang_descaped = "{num} Classe D scappati"
italian.lang_sescaped = "{num} SCP scappati"
italian.lang_rescaped = "{num} Ricercatori scappati"
italian.lang_dcaptured = "I Chaos Insurgency hanno catturato {num} Classe D"
italian.lang_rescorted = "Gli MTF hanno scortato {num} Ricercatori"
italian.lang_teleported = "L' SCP-106 ha catturato {num} vittime nella Dimensione Portatile"
italian.lang_snapped = "{num} colli sono stati spezzati dall' SCP-173"
italian.lang_zombies = 'SCP-049 "ha curato la malattia" {num} volte'
italian.lang_secret_found = "Il segreto è stato trovato"
italian.lang_secret_nfound = "Il segreto non è stato trovato"

italian.class_unknown = "Sconosciuto"

italian.votefail = "Hai già votato o non puoi votare!"
italian.votepunish = "Vota per punire o perdonare %s"
italian.voterules = [[
	Scrivi !punish per punire il player o !forgive per perdonarlo
	Il voto della vittima = 5 votes
	Il voto del player normale = 1 vote
	Altri 3 voti sono calcolati dalla media dei voti degli spettatori
	Ricorda che puoi votare una sola volta!
]]
italian.punish = "PUNISCI"
italian.forgive = "PERDONA"
italian.voteresult = "Il risultato del voto contro %s è... %s"
italian.votes = "Da %s players %s hanno votato per punire e %s per perdonare"
italian.votecancel = "L'ultimo è stato cancellato dall'admin"

italian.eq_tip = "LMB - Seleziona | RMB - Lascia"
italian.eq_open = "Premi 'Q' per aprire il nuovo inventario!"

italian.starttexts = {
	ROLE_SCPSantaJ = {
		"Sei l' SCP-SANTA-J",
		{"Il tuo obbiettivo è scappare dalla struttura",
		"Sei l' Babbo Natale! Dai regali a tutti!",
		"Buon Natale e buon anno nuovo!",
		"Questo è un SCP speciale disponibile solo nell'evento natalizio!"}
	},
	ROLE_SCP173 = {
		"Sei l' SCP-173",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Non ti puoi muovere mentre qualcuno ti guarda",
		"Ricorda, gli umani sbattono le palpebre",
		"Hai una abilità speciale con RMB: accieca tutti quelli intorno"}
	},
	ROLE_SCP096 = {
		"Sei l' SCP-096",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Ti muovi estremamente veloce quando qualcuno ti guarda",
		"Puoi urlare usando RMB"}
	},
	ROLE_SCP066 = {
		"Sei l' SCP-066",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Puoi emettere suoni MOLTO forti",
		"LMB - attacchi, RMB - distruggi le finestre"}
	},
	ROLE_SCP106 = {
		"Sei l' SCP-106",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Quando tocchi qualcuno, si teletrasporterà",
		"alla tua dimensione portatile"}
	},
	ROLE_SCP966 = {
		"Sei l' SCP-966",
		{"Il tuo obbiettivo è scappare dalla struttura",
		"Sei invisibile, gli umani ti possono vedere solo usando un nvg",
		"Fai male agli umani quando gli sei vicino",
		"oltre a disorientarli "}
	},
	ROLE_SCP682 = {
		"Sei l' SCP-682",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Sei un rettile difficle da distruggere",
		"Uccidi le persone velocemente, anche se sei molto lento",
		"Hai una abilità speciale su RMB"}
	},
	ROLE_SCP457 = {
		"Sei l' SCP-457",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Sei continuamente in fiamme",
		"Se sei abbastanza vicino ad un umano lo brucerai"}
	},
	ROLE_SCP049 = {
		"Sei l' SCP-049",
		{"Il tuo obbiettivo è scappare dalla struttura",
		"Se usi la tua abilità speciale su qualcuno, egli diventerà SCP-049-2"}
	},
	ROLE_SCP689 = {
		"Sei l' SCP-689",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Sei estremamente lento, ma anche letale",
		"Puoi uccidere tutti quelli che ti guardano",
		"Dopo aver ucciso qualcuno gli comparirai sul cadavere",
		"LMB - attacchi, RMB - distruggi le finestre"}
	},
	ROLE_SCP939 = {
		"Sei l' SCP-939",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Sei veloce e forte",
		"Puoi attirare le tue prede parlando nella loro chat vocale",
		"LMB - attacchi, RMB - cambi chat vocale"}
	},
	ROLE_SCP999 = {
		"Sei l' SCP-999",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Puoi curare chiunque tu voglia",
		"Devi coperare con il personale o con gli Altri SCP"}
	},
	ROLE_SCP082 = {
		"Sei l' SCP-082",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Sei un cannibale con un macete",
		"I tuoi attacchi riducono la stamina del bersaglio",
		"Quando uccidi qualcuno guadagni vita"}
	},
	ROLE_SCP023 = {
		"Sei l' SCP-023",
		{"Il tuo obbiettivo è scappare dalla struttura",
		"Sei un lupo che incendia chiunque ti attraversi",
		"Incendiando gli altri ti rigeneri",
		"LMB - attacchi, RMB - guadagni velocità ma perdi vita"}
	},
	ROLE_SCP1471 = {
		"Sei l' SCP-1471-A",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Ti puoi teletrasportare al tuo bersaglio",
		"LMB - attacchi, RMB - ti teletrasporti dal tuo bersaglio"}
	},
	ROLE_SCP1048A = {
		"Sei l' SCP-1048-A",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Sembri l' SCP-1048, ma sei fatto interamente di orecchie umane",
		"Emetti uno stridio MOLTO forte"}
	},
	ROLE_SCP1048B = {
		"Sei l' SCP-1048-B",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Uccidili tutti!"}
	},
	ROLE_SCP8602 = {
		"Sei l' SCP-860-2",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Sei il mostro della foresta",
		"Quando attacchi qualcuno vicino a un muro, lo carichi"}
	},
	ROLE_SCP0492 = {
		"Sei l' SCP-049-2",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Coopera con l' SCP-049 per eliminare più persone"}
	},
	ROLE_SCP076 = {
		"Sei l' SCP-076-2",
		{"Il tuo obbiettivo è scappare dalla struttura",
		"Sei veloce e hai poca vita",
		"Rinascerai fin quando qualcuno distrugge SCP-076-1"}
	},
	ROLE_SCP957 = {
		"Sei l' SCP-957",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Ricevi poco danno, ma alla morte di SCP-957-1 perderai vita",
		"Usa LMB per provocare danno ad area",
		"Dopo aver attaccato tu e SCP-957-1 riceverete della vita"}
	},
	ROLE_SCP9571 = {
		"Sei l' SCP-957-1",
		{"Il tuo obbiettivo è di portare i tuoi amici da SCP-957",
		"La tua vista è limitata e puoi parlare con SCP-957",
		"Nessuno sà che sei un SCP, non farti scoprire",
		"Se morirai, SCP-957 riceverà danno"}
	},
	ROLE_SCP0082 = {
		"Sei l' SCP-008-2",
		{"Il tuo obiettivo è di infettare ogni MTF e Classe D",
		"Se ucciderai qualcuno, questi diventerà SCP-008-2"}
	},
	ROLE_RES = {
		"Sei un Ricercatore",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Devi trovare una guardia MTF che ti aiuterà",
		"Attento ai Classe D, potrebbero ucciderti"}
	},
	ROLE_MEDIC = {
		"Sei un Medico",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Devi trovare una guardia MTF che ti aiuterà",
		"Attento ai Classe D, potrebbero ucciderti",
		"Se qualcuno viene ferito, curalo"}
	},
	ROLE_NO3 = {
		"Sei un Ricercatore livello 3",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Conosci questo posto come nessun altro",
		"Attento ai Classe D, potrebbero ucciderti",
		"Puoi comunicare con le guardie usando la radio"}
	},
	ROLE_CLASSD = {
		"Sei un Classe D",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Devi coperare con gli altri Classe D",
		"Cerca delle keycard e evita MTF e SCP"}
	},
	ROLE_VETERAN = {
		"Sei un Classe D veterano",
		{"Il tuo obiettivo è scappare dalla struttura",
		"Devi cooperare con gli altri Classe D",
		"Cerca delle keycard e evita MTF e SCP"}
	},
	ROLE_CIC = {
		"Sei un agente Chaos Insurgency",
		{"Il tuo obiettivo è di aiutare i Classe D",
		"Li organizzi",
		"Evita MTF e SCP, e aspetta supporto"}
	},
	ROLE_SECURITY = {
		"Sei un Ufficiale della Sicurezza",
		{"Il tuo obiettivo è di trovare e mettere in salvo",
		"i ricercatori ancora nella struttura",
		"Devi uccidere ogni Classe D e SCP che troverai",
		"Ascolta gli ordini del tuo capo e stà vicino alla squadra"}
	},
	ROLE_CSECURITY = {
		"Sei un Capo della sicurezza",
		{"Il tuo obiettivo è di trovare e mettere in salvo",
		"i ricercatori ancora nella struttura",
		"Devi uccidere ogni Classe D e SCP che troverai",
		"Dai ordini agli ufficiali della sicurezza e ascolta il tuo capo"}
	},
	ROLE_MTFGUARD = {
		"Sei una guardia MTF",
		{"Il tuo obiettivo è di trovare e mettere in salvo",
		"i ricercatori ancora nella struttura",
		"Devi uccidere ogni Classe D e SCP che troverai",
		"Ascolta agli ordini del comandante MTF e stà vicino alla squadra"}
	},
	ROLE_MTFMEDIC = {
		"Sei un Medico MTF",
		{"Il tuo obiettivo è di aiutare i tuoi compagni",
		"Se qualcuno si ferisce, curalo",
		"Ascolta agli ordini del comandante MTF e stà vicino alla squadra"}
	},
	ROLE_HAZMAT = {
		"Sei una Unità Speciale MTF",
		{"Il tuo obiettivo è di trovare e mettere in salvo",
		"i ricercatori ancora nella struttura",
		"Devi uccidere ogni Classe D e SCP che troverai",
		"Ascolta al comandante MTF e al direttore della struttura"}
	},
	ROLE_MTFL = {
		"Sei un Tenente MTF",
		{"Il tuo obiettivo è di trovare e mettere in salvo",
		"i ricercatori ancora nella struttura",
		"Devi uccidere ogni Classe D e SCP che troverai",
		" Dai ordini alle guardie per semplificare l'obiettivo",
		"Ascolta il comandante MTF e il direttore della struttura"}
	},
	ROLE_SD = {
		"Sei un Direttore della struttura",
		{"Il tuo obiettivo è dare ordini",
		"Devi dare ordini agli ufficiali della sicurezza",
		"Devi mantenere la struttura sicura, non far scappare nessun Classe D o SCP"}
	},
	ROLE_O5 = {
		"Sei un membro del Consiglio O5",
		{"Hai accesso illimitato a tutto",
		"Sei la persona più importante quì, dai ordini",
		"Fai tutto quel che puoi per salvare la reputazione della fondazione e il mondo"}
	},
	ROLE_MTFNTF = {
		"Sei una Unità MTF Nine-Tailed Fox",
		{"Il tuo obiettivo è di trovare e mettere in salvo",
		"i ricercatori ancora nella struttura",
		"Devi uccidere ogni Classe D e SCP che troverai",
		"Vai nella struttura e aiuta le guardie a contenere il caos"}
	},
	ROLE_MTFCOM = {
		"Sei un Comandante MTF",
		{"Il tuo obiettivo è di trovare e mettere in salvo",
		"i ricercatori ancora nella struttura",
		"Devi uccidere ogni Classe D e SCP che troverai",
		"Dai ordini alle guardie per semplificare l'obiettivo"}
	},
	ROLE_CHAOS = {
		"Sei un Soldato Chaos Insurgency",
		{"Il tuo obbiettivo è di catturare più Classe D possibili",
		"Scortali fuori dalla struttura",
		"Uccidi tutti quelli che provano a fermarti"}
	},
	ROLE_CHAOSSPY = {
		"Sei la Spia Chaos Insurgency",
		{"Il tuo obiettivo è di uccidere tutte le guarde MTF e di catturare i Classe D",
		"Loro non sono a conoscenza del tuo travestimento",
		"Non farti scoprire",
		"Se trovi dei Classe D, prova a scortarli fuori dalla struttura"}
	},
	ROLE_CHAOSCOM = {
		"Sei il Comandante Chaos Insurgency",
		{"Il tuo obiettivo è di dare ordini alla tua squadra",
		"Uccidi tutti quelli che provano a fermarti"}
	},
	ROLE_SPEC = {
		"Sei uno spettatore",
		{'Usa il comando "br_spectate" per ritornare'}
	},
	ADMIN = {
		"Sei nella modalità admin",
		{'Usa il comando "br_admin_mode" per tornare in vita il prossimo round'}
	},
	ROLE_INFECTD = {
		"Sei un Classe D",
		{'Questo è il round speciale "infezione"',
		"Devi coperare con gli MTF per fermare l'infezione",
		"Quando verrai ucciso da uno zombie diventerai uno di loro"}
	},
	ROLE_INFECTMTF = {
		"Sei un MTF",
		{'Questo è il round speciale "infezione"',
		"Devi coperare con i Classe D per fermare l'infezione",
		"Quando verrai ucciso da uno zombie diventerai uno di loro"}
	},
}

italian.lang_end1 = "La partita finisce quì"
italian.lang_end2 = "Il limite di tempo è stato raggiunto"
italian.lang_end3 = "La partita finisce per la incapacità di continuare"

italian.escapemessages = {
	{
		main = "Sei scappato",
		txt = "Sei scappato dalla struttura in {t} minuti, buon lavoro!",
		txt2 = "Prova ad essere scortato da un MTF la prossima volta per ottenere punti bonus.",
		clr = Color(237, 28, 63),
	},
	{
		main = "Sei scappato",
		txt = "Sei scappato dalla struttura in {t} minuti, buon lavoro!",
		txt2 = "Prova ad essere scortato da un soldato Chaos Insurgency la prossima volta per ottenere punti bonus.",
		clr = Color(237, 28, 63),
	},
	{
		main = "Sei stato scortato",
		txt = "Sei stato scortato in {t} minuti, buon lavoro!!",
		txt2 = "",
		clr = Color(237, 28, 63),
	},
	{
		main = "Sei scappato",
		txt = "Sei scappato in {t} minutes, good job!",
		txt2 = "",
		clr = Color(237, 28, 63),
	}
}



italian.ROLES = {}

italian.ROLES.ADMIN = "MODALITA' ADMIN"
italian.ROLES.ROLE_INFECTD = "Classe D"
italian.ROLES.ROLE_INFECTMTF = "MTF"

italian.ROLES.ROLE_SCPSantaJ = "SCP-SANTA-J"
italian.ROLES.ROLE_SCP173 = "SCP-173"
italian.ROLES.ROLE_SCP106 = "SCP-106"
italian.ROLES.ROLE_SCP049 = "SCP-049"
italian.ROLES.ROLE_SCP457 = "SCP-457"
italian.ROLES.ROLE_SCP966 = "SCP-966"
italian.ROLES.ROLE_SCP096 = "SCP-096"
italian.ROLES.ROLE_SCP066 = "SCP-066"
italian.ROLES.ROLE_SCP689 = "SCP-689"
italian.ROLES.ROLE_SCP682 = "SCP-682"
italian.ROLES.ROLE_SCP082 = "SCP-082"
italian.ROLES.ROLE_SCP939 = "SCP-939"
italian.ROLES.ROLE_SCP999 = "SCP-999"
italian.ROLES.ROLE_SCP023 = "SCP-023"
italian.ROLES.ROLE_SCP076 = "SCP-076-2"
italian.ROLES.ROLE_SCP1471 = "SCP-1471-A"
italian.ROLES.ROLE_SCP8602 = "SCP-860-2"
italian.ROLES.ROLE_SCP1048A = "SCP-1048-A"
italian.ROLES.ROLE_SCP1048B = "SCP-1048-B"
italian.ROLES.ROLE_SCP0492 = "SCP-049-2"
italian.ROLES.ROLE_SCP0082 = "SCP-008-2"
italian.ROLES.ROLE_SCP957 = "SCP-957"
italian.ROLES.ROLE_SCP9571 = "SCP-957-1"

italian.ROLES.ROLE_RES = "Ricercatore"
italian.ROLES.ROLE_MEDIC = "Medico"
italian.ROLES.ROLE_NO3 = "Ricercatore Livello 3"

italian.ROLES.ROLE_CLASSD = "Classe D"
italian.ROLES.ROLE_VETERAN = "Classe D Veterano"
italian.ROLES.ROLE_CIC = "Agente CI"

italian.ROLES.ROLE_SECURITY = "Ufficiale della sicurezza"
italian.ROLES.ROLE_MTFGUARD = "Guardia MTF"
italian.ROLES.ROLE_MTFMEDIC = "Medico MTF"
italian.ROLES.ROLE_MTFL = "Tenente MTF"
italian.ROLES.ROLE_HAZMAT = "MTF SCU"
italian.ROLES.ROLE_MTFNTF = "MTF NTF"
italian.ROLES.ROLE_CSECURITY = "Capo della Sicurezza"
italian.ROLES.ROLE_MTFCOM = "Comandante MTF"
italian.ROLES.ROLE_SD = "Direttore del Site"
italian.ROLES.ROLE_O5 = "Consiglio O5"

italian.ROLES.ROLE_CHAOSSPY = "Spia CI"
italian.ROLES.ROLE_CHAOS = "Soldato CI"
italian.ROLES.ROLE_CHAOSCOM = "Comandante CI"
italian.ROLES.ROLE_SPEC = "spettatore"

italian.credits_orig = "Creato da:"
italian.credits_edit = "Modificato e riparato da:"
italian.settings = "Impostazioni"
italian.updateinfo = "Mostra le modifiche dopo l'aggiornamento"
italian.done = "Pronto"
italian.repe = "Scrivi br_reset_intro per mostrare l'intro di nuovo"

italian.author = "Autore"
italian.helper = "Assistente"
italian.originator = "Collaboratore"

italian.updates = {
	"italian",
	"Informazioni sull'aggiornamento",
	"Le informazioni sull'aggiornamento della versione %s non sono disponibili",
	"Versione del server",
}

ALLLANGUAGES.italian = italian
