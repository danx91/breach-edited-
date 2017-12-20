polski = {}

polski.roundtype = "Typ rundy: {type}"
polski.preparing = "Przygotuj się, runda zacznie się za {num} sekund"
polski.round = "Gra się rozpoczeła, powodzenia"
polski.specialround = "To jest runda specialna"

polski.lang_pldied = "{num} graczy zginęło"
polski.lang_descaped = "{num} personel(u) Klasy D uciekło"
polski.lang_sescaped = "{num} obiektów SCP uciekło"
polski.lang_rescaped = "{num} Naukowców uciekło"
polski.lang_dcaptured = "{num} personel(u) Klasy D zostało pojmanych przez Chaos Insurgency"
polski.lang_rescorted = "{num} Naukowców zostało eskortowanych przez MTF"
polski.lang_teleported = "{num} graczy zostało porwane do wymiaru łuzowego"
polski.lang_snapped = "{num} graczy zostało zabitych przez SCP - 173"
polski.lang_zombies = '{num} graczy zostało "wyleczonych" przez SCP - 049'
polski.lang_secret_found = "Sekret został odnaleziony"
polski.lang_secret_nfound = "Sekret nie został odnaleziony"

polski.class_unknown = "Niezidentyfikowany"

polski.votefail = "Już głosowałeś albo nie możesz głosować"
polski.votepunish = "Zagłosuj czy gracz %s ma zostać ukarany"
polski.voterules = [[
	Wpisz !punish aby ukarać lub !forgive aby przebaczyć
	Głos ofiary = 5 głosów
	Głos normalnego gracza = 1 głos
	Dodatkowe 3 głosy zostaną wyliczone ze średniej głosów obserwatorów
	Pamiętaj możesz głosować tylko raz!
]]
polski.punish = "KARA"
polski.forgive = "PRZEBACZENIE"
polski.voteresult = "Wynik głosowania przeciwko %s... %s"
polski.votes = "Z %s graczy %s zagłosowało nad karą, a %s nad przebaczeniem"
polski.votecancel = "Ostatnie głosowanie zostało przerwane przez administratora"

polski.starttexts = {
	ROLE_SCPSantaJ = {
		"Jesteś SCP-SANTA-J",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś Świętym Mikołajem! Rozdawaj wszystkim prezenty!",
		"Wesołych Świąt i Szczęśliwego Nowego Roku!",
		"To jest specialny SCP dostępny tylko przez ograniczony czas!"}
	},
	ROLE_SCP173 = {
		"Jesteś SCP - 173",
		{"Twoim celem jest ucieczka z placówki",
		"Nie możesz sie ruszać jeśli ktoś się na ciebie patrzy",
		"Pamiętaj, ludzie mrugają",
		"PPM aktywuje specjalną moc: możesz oślepić wszystkich w około"}
	},
	ROLE_SCP096 = {
		"Jesteś SCP - 096",
		{"Twoim celem jest ucieczka z placówki",
		"Ruszasz się niezwykle szybko gdy ktoś patrzy",
		"Możesz krzyczeć klikając PPM"}
	},
	ROLE_SCP066 = {
		"Jesteś SCP - 066",
		{"Twoim celem jest ucieczka z placówki",
		"Potrafisz wytworzyć naprawdę głośną muzykę",
		"LPM - atak, PPM - możesz rozbijać szyby"}
	},
	ROLE_SCP106 = {
		"Jesteś SCP - 106",
		{"Twoim celem jest ucieczka z placówki",
		"Jeśli klikniesz na kogoś, przeteleportujesz go do wymiaru łuzowego"}
	},
	ROLE_SCP966 = {
		"Jesteś SCP-966",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś widzialny tylko przez noktowizor",
		"Zadajesz obszarowe obrażenia gdy stoisz blisko ludzi",
		"A także dezorientujesz ich"}
	},
	ROLE_SCP939 = {
		"Jesteś SCP-939",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś szybki i silny",
		"Możesz oszukać swoje ofiary używając czatu głosowego",
		"LPM - atakujesz, PPM - zmieniasz czat głosowy"}
	},
	ROLE_SCP682 = {
		"Jesteś SCP-682",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś Gadem Trudnym-Do-Zniszczenia",
		"Zabijasz natychmiast, ale jesteś bardzo wolny",
		"Pod PPM masz specjalną umiejętność"}
	},
	ROLE_SCP457 = {
		"Jesteś SCP-457",
		{"Twoim celem jest ucieczka z placówki",
		"Zawsze się palisz",
		"Jeśli będziesz blisko kogoś, zaczniesz go podpalać"}
	},
	ROLE_SCP999 = {
		"Jesteś SCP-999",
		{"Twoim celem jest ucieczka z placówki",
		"Możesz uzdrowić kogo chcesz",
		"Musisz współpracować z innym personelem lub SCP"}
	},
	ROLE_SCP689 = {
		"Jesteś SCP-689",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś ekstremalnie wolny, ale również zabójczy",
		"Możesz zabić każdego kto cię zobaczył",
		"Po zabiciu pojawiasz się na zwłokach ofiary, aby zobaczyło ciebie więcej ludzi",
		"LPM - atak, PPM - możesz rozbijać szyby"}
	},
	ROLE_SCP082 = {
		"Jesteś SCP-082",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś kanibalem z maczetą",
		"Jeżeli kogoś zranisz spowolnisz go",
		"Jak kogoś zabijesz to zyskasz trochę zdrowia"}
	},
	ROLE_SCP023 = {
		"Jesteś SCP-023",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś wilkiem podpalającym każdego obok kogo przejdziesz",
		"Podpalając kogoś troche się leczysz",
		"LPM - atak, PPM - kosztem zycia zyskujesz prędkość"}
	},
	ROLE_SCP1471 = {
		"Jesteś SCP-1471-A",
		{"Twoim celem jest ucieczka z placówki",
		"Możesz przeteleportować się do swojej ofiary",
		"LPM - atak, PPM - aby się teleportować"}
	},
	ROLE_SCP1048A = {
		"Jesteś SCP-1048-A",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś podobny do niegroźnego SCP 1048",
		"Ale wykonany jesteś z ludzkich uszu",
		"LPM - aby wytworzyć głośny krzyk"}
	},
	ROLE_SCP1048B = {
		"Jesteś SCP-1048-B",
		{"Twoim celem jest ucieczka z placówki",
		"Zabij wszystkich"}
	},
	ROLE_SCP8602 = {
		"Jesteś SCP-860-2",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś leśnym potworem",
		"Jeżeli zaatakujesz kogoś blisko sciany to szarżujesz na niego"}
	},
	ROLE_SCP049 = {
		"Jesteś SCP - 049",
		{"Twoim celem jest ucieczka z placówki",
		"Jak dotkniesz kogoś, to stanie się SCP-049-2"}
	},
	ROLE_SCP0492 = {
		"Jesteś SCP-049-2",
		{"Twoim celem jest ucieczka z placówki",
		"Pomagaj SCP-049"}
	},
	ROLE_SCP076 = {
		"Jesteś SCP-076-2",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś szybki i masz mało zdrowia",
		"Będziesz się odradzać dopóki ktoś nie zniszczy SCP-076-1"}
	},
	ROLE_SCP0082 = {
		"Jesteś SCP-008-2",
		{"Twoim celem jest zarażenie wszystkich MTF i D",
		"Jeśli zabijesz kogoś to stanie się 008-2"}
	},
	ROLE_RES = {
		"Jesteś naukowcem",
		{"Twoim celem jest ucieczka z placówki",
		"Szukaj pomocy i spróbuj wydostać się z placówki",
		"Uważaj na klasę D, mogą próbować cię zabić"}
	},
	ROLE_MEDIC = {
		"Jesteś medykiem",
		{"Twoim celem jest ucieczka z placówki",
		"Szukaj pomocy i spróbuj wydostać się z placówki",
		"Uważaj na klasę D, mogą próbować cię zabić",
		"Jeśli ktoś będzie potrzebował leczenia to go ulecz"}
	},
	ROLE_NO3 = {
		"Jesteś naukowcem poziomu 3",
		{"Twoim celem jest ucieczka z placówki",
		"Jesteś tu od dawna i znasz placówke jak nikt inny",
		"Uważaj na klasę D, mogą próbować cię zabić",
		"Dzięki radiu możesz się komunikować z ochroną"}
	},
	ROLE_CLASSD = {
		"Jesteś personelem Klasy D",
		{"Twoim celem jest ucieczka z placówki",
		"Pomagaj swoim kolegom, samemu masz nikłe szanse na przeżycie",
		"Szukaj kart dostępu i uważaj na MTF i obiekty SCP"}
	},
	ROLE_VETERAN = {
		"Jesteś weteranem Klasy D",
		{"Twoim celem jest ucieczka z placówki",
		"Pomagaj swoim kolegom, samemu masz nikłe szanse na przeżycie",
		"Szukaj kart dostępu i uważaj na MTF i obiekty SCP"}
	},
	ROLE_CIC = {
		"Jesteś agentem Chaos Insurgency",
		{"Twoim celem jest pomóc Klasie D",
		"Ty zajmujesz się ich organizacją",
		"Uważaj na MTF i obiekty SCP, oraz czekaj na wsparcie kolegów z CI"}
	},
	ROLE_SECURITY = {
		"Jesteś Ochroniarzem",
		{"Twoim celem jest znalezienie wszystkich naukowców i eliminacja Klasy D",
		"Eskortuj ich do lądowiska",
		"Musisz zabić każdego kto ci przeszkodzi",
		"Słuchaj się swojego Dowódcy i wykonuj jego polecenia"}
	},
	ROLE_CSECURITY = {
		"Jesteś Dowódcą Ochroniarzy",
		{"Twoim celem jest znalezienie wszystkich naukowców i eliminacja Klasy D",
		"Eskortuj ich do lądowiska",
		"Wydawaj polecenia ochroniarzom ci przydzielonym"}
	},
	ROLE_MTFGUARD = {
		"Jesteś Ochroniarzem MTF",
		{"Twoim celem jest znalezienie wszystkich naukowców i eliminacja Klasy D",
		"Eskortuj ich do lądowiska",
		"Musisz zabić każdego kto ci przeszkodzi",
		"Słuchaj się swojego Dowódcy i wykonuj jego polecenia"}
	},
	ROLE_MTFMEDIC = {
		"Jesteś Medykiem MTF",
		{"Twoim celem jest wspieranie innych ochroniarzy i naukowców",
		"Jeśli będą ranni to ich ulecz",
		"Słuchaj się swojego Dowódcy i wykonuj jego polecenia"}
	},
	ROLE_MTFL = {
		"Jesteś Porucznikiem MTF",
		{"Twoim celem jest znalezienie wszystkich naukowców i eliminacja Klasy D",
		"Eskortuj ich do lądowiska",
		"Musisz zabić każdego kto ci przeszkodzi",
		"Słuchaj się Dowódcy i wykonuj jego polecenia",
		"Jeśli Dowódca przydzieli ci ochroniarzy to wydawaj im polecenia",
		"Jeśli Dowódca zginie to przejmij dowodzenie"}
	},
	ROLE_HAZMAT = {
		"Jesteś specjalnym żołnierzem MTF",
		{"Twoim celem jest znalezienie wszystkich naukowców i eliminacja Klasy D",
		"Eskortuj ich do lądowiska",
		"Musisz zabić każdego kto ci przeszkodzi",
		"Słuchaj się Dowódcy i wykonuj jego polecenia"}
	},
	ROLE_MTFNTF = {
		"Jesteś agentem MTF Jednostki Nine-Tailed Fox",
		{"Twoim celem jest znalezienie wszystkich naukowców i eliminacja Klasy D",
		"Eskortuj ich do lądowiska",
		"Musisz zabić każdego kto ci przeszkodzi",
		"Wejdź do placówki i pomóż ochroniarzom",
		"Jeśli jest jakiś Dowódca to wykonuj jego polecenia"}
	},
	ROLE_MTFCOM = {
		"Jesteś Dowódcą MTF",
		{"Twoim celem jest znalezienie wszystkich naukowców",
		"Eskortuj ich do lądowiska",
		"Musisz zabić każdego kto ci przeszkodzi",
		"Wydawaj polecenia ochroniarzom"}
	},
	ROLE_SD = {
		"Jesteś Dyrektorem Placówki",
		{"Twoim celem jest wydawanie poleceń",
		"Jeśli jest jakiś Dowódca MTF lub Dowódca Ochrony to wydawaj im polecenia",
		"Zrób co w swojej mocy by uchronić placówke"}
	},
	ROLE_O5 = {
		"Jesteś Członkiem Rady O5",
		{"Posiadasz nieograniczony dostęp do wszystkiego",
		"Jesteś tutaj najważniejszy, wydawaj polecenia",
		"Zrób cokolwiek, aby uchronić dobre imię fundacji oraz bezpieczeństwo świata"}
	},
	ROLE_CHAOS = {
		"Jesteś żołnierzem Chaos Insurgency",
		{"Twoim celem jest zabicie ochroniarzy MTF",
		"Jeśli znajdziesz personel Klasy D eskortuj go do lądowiska",
		"Zabij każdego kto ci przeszkodzi"}
	},
	ROLE_CHAOSCOM = {
		"Jesteś Dowódcą Chaos Insurgency",
		{"Twoim celem jest wydawanie poleceń żołnierzom CI",
		"Musicie zabić wszystkich ochroniarzy MTF",
		"Zróbcie jak największy chaos w placówce"}
	},
	ROLE_CHAOSSPY = {
		"Jesteś szpiegiem Chaos Insurgency",
		{"Twoim celem jest zabicie ochroniarzy MTF",
		"Będą myśleć, że jesteś z nimi",
		"Jeśli znajdziesz personel Klasy D eskortuj go do lądowiska"}
	},
	ROLE_SPEC = {
		"Jesteś Obserwatorem",
		{'Użyj komendy "br_spectate" żeby wrócić'}
	},
	ADMIN = {
		"Jesteś w trybie administratora",
		{'Użyj komendy "br_admin_mode" aby wrócić do gry w następnej rundzie'}
	},
	ROLE_INFECTD = {
		"Jesteś Presonelem Klasy D",
		{'To jest runda specialna "infekcja"',
		"Musisz współpracować z MTF aby zatrzymać zarazę",
		"Jeżeli zostaniesz zabity przez zombi staniesz się jednym z nich"}
	},
	ROLE_INFECTMTF = {
		"Jesteś ochroniarzem MTF",
		{'To jest runda specialna "infekcja"',
		"Musisz współpracować z Klasą D aby zatrzymać zarazę",
		"Jeżeli zostaniesz zabity przez zombi staniesz się jednym z nich"}
	},
}

polski.lang_end1 = "Runda kończy się w tym miejscu"
polski.lang_end2 = "Czas minął"
polski.lang_end3 = "Gra zakończyła się"

polski.escapemessages = {
	{
		main = "Uciekłeś",
		txt = "Uciekłeś w {t} minut, dobra robota!",
		txt2 = "Następnym razem spróbuj zostać eskortowanym przez MTF żeby dostać bonusowe punkty",
		clr = Color(237, 28, 63),
	},
	{
		main = "Uciekłeś",
		txt = "Uciekłeś w {t} minut, dobra robota!",
		txt2 = "Następnym razem spróbuj zostać eskortowanym przez CI żeby dostać bonus punktów",
		clr = Color(237, 28, 63),
	},
	{
		main = "Zostałeś eskortowany",
		txt = "Zostałeś eskortowany w {t} minut, dobra robota!",
		txt2 = "",
		clr = Color(237, 28, 63),
	},
	{
		main = "Uciekłeś",
		txt = "Uciekłeś w {t} minut, dobra robota!",
		txt2 = "",
		clr = Color(237, 28, 63),
	}
}


polski.ROLES = {}

polski.ROLES.ADMIN = "TRYB ADMINISTRATORA"
polski.ROLES.ROLE_INFECTD = "Personel Klasy D"
polski.ROLES.ROLE_INFECTMTF = "MTF"

polski.ROLES.ROLE_SCPSantaJ = "SCP-SANTA-J"
polski.ROLES.ROLE_SCP173 = "SCP-173"
polski.ROLES.ROLE_SCP106 = "SCP-106"
polski.ROLES.ROLE_SCP049 = "SCP-049"
polski.ROLES.ROLE_SCP096 = "SCP-096"
polski.ROLES.ROLE_SCP066 = "SCP-066"
polski.ROLES.ROLE_SCP682 = "SCP-682"
polski.ROLES.ROLE_SCP082 = "SCP-082"
polski.ROLES.ROLE_SCP689 = "SCP-689"
polski.ROLES.ROLE_SCP457 = "SCP-457"
polski.ROLES.ROLE_SCP999 = "SCP-999"
polski.ROLES.ROLE_SCP939 = "SCP-939"
polski.ROLES.ROLE_SCP0492 = "SCP-049-2"
polski.ROLES.ROLE_SCP0082 = "SCP-008-2"
polski.ROLES.ROLE_SCP966 = "SCP-966"
polski.ROLES.ROLE_SCP023 = "SCP-023"
polski.ROLES.ROLE_SCP076 = "SCP-076-2"
polski.ROLES.ROLE_SCP1471 = "SCP-1471-A"
polski.ROLES.ROLE_SCP1048A = "SCP-1048-A"
polski.ROLES.ROLE_SCP1048B = "SCP-1048-B"
polski.ROLES.ROLE_SCP8602 = "SCP-860-2"

polski.ROLES.ROLE_RES = "Naukowiec"
polski.ROLES.ROLE_MEDIC = "Medyk"
polski.ROLES.ROLE_NO3 = "Naukowiec Poziomu 3"

polski.ROLES.ROLE_CLASSD = "Personel Klasy D"
polski.ROLES.ROLE_VETERAN = "Weteran Klasy D"
polski.ROLES.ROLE_CIC = "Agent CI"

polski.ROLES.ROLE_SECURITY = "Ochroniarz"
polski.ROLES.ROLE_MTFGUARD = "Ochroniarz MTF"
polski.ROLES.ROLE_MTFMEDIC = "Medyk MTF"
polski.ROLES.ROLE_MTFL = "Porucznik MTF"
polski.ROLES.ROLE_HAZMAT = "MTF SCU"
polski.ROLES.ROLE_MTFNTF = "MTF NTF"
polski.ROLES.ROLE_CSECURITY = "Dowódca ochroniarzy"
polski.ROLES.ROLE_MTFCOM = "Dowódca MTF"
polski.ROLES.ROLE_SD = "Dyrektor Placówki"
polski.ROLES.ROLE_O5 = "Członek rady O5"

polski.ROLES.ROLE_CHAOSSPY = "Szpieg CI"
polski.ROLES.ROLE_CHAOS = "Żołnierz CI"
polski.ROLES.ROLE_CHAOSCOM = "Dowódca CI"
polski.ROLES.ROLE_SPEC = "Obserwator"

polski.credits_orig = "Stworzone przez:"
polski.credits_edit = "Zmodyfikowane i poprawione przez:"
polski.settings = "Ustawienia"
polski.updateinfo = "Wyświetlaj zmiany po każdej aktualizacji"
polski.done = "Gotowe"
polski.repe = "Wpisz br_reset_intro aby zobaczyć intro ponownie"

polski.author = "Autor"
polski.helper = "Asystent"
polski.originator = "Pomysłodawca"

polski.updates = {
	"polski",
	"Opis wersji",
	"Opis aktualizacji %s jest niedostępny!",
	"Wersja serwera",
}

ALLLANGUAGES.polski = polski
