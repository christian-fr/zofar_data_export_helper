****************************************************************************
// Dieses Skript wurde erzeugt vom Zofar Online Survey System
// Es dient lediglich als Beispiel und sollte ggf. den eigenen Bedürfnissen angepasst werden.
// Das Skript wurde für Stata 14 erstellt.
// Eine Kompatibilität mit älteren Stata-Versionen kann nicht gewährleistet werden.
****************************************************************************
** Projekt/ Studie: build_sachseneval
** Erstelldatum: 20.10.2023 12:39:52
** Datensatz: Fri Oct 20 12:39:52 CEST 2023
****************************************************************************
** Glossar Missing-Werte
** -9999 : voreingestellte Missing-Werte, insbesondere bei technischen Variablen
** -9992 : Item wurde gemäß Fragebogensteuerung nicht angezeigt oder befindet sich auf der Seite des Befragungsabbruches
** -9990 : Item wurde gesehen, aber nicht beantwortet
** -9991 : Seite, auf der sich das Item befindet, wurde gemäß Fragebogensteuerung oder aufgrund eines vorherigen Befragungsabbruches nicht besucht
** -9995 : Variable wurde nicht erhoben (-9992 oder -9991), jedoch für die Fragebogensteuerung verwendet
*************************************************************************
*************************************************************************

version 14			// Festlegung der Stata-Version
set more off			// Anzeige wird nicht unterbrochen
clear			// löscht die Daten im Memory

*____________Daten importieren____________________
import delimited "..\..\csv\data.csv", bindquote(strict) clear			//Achtung! Pfad gilt nur für die aktuelle Ordnerstruktur!


*____________Wertelabels festlegen & zuweisen____________________
label define consent_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values consent consent_labelset

label define noconsent_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values noconsent noconsent_labelset

label define f01_labelset 10 "[10] Universität" 20 "[20] Hochschule für angewandte Wissenschaft / University of Applied Sciences" 30 "[30] Kunst- oder Musikhochschule" 
label values f01 f01_labelset

label define f02shk_labelset 11 "[11] Technische Universität Chemnitz" 12 "[12] Technische Universität Dresden" 13 "[13] Technische Universität Bergakademie Freiberg" 14 "[14] Universität Leipzig" 21 "[21] Hochschule für Technik und Wirtschaft Dresden" 22 "[22] Hochschule für Technik, Wirtschaft und Kultur Leipzig" 23 "[23] Hochschule Mittweida" 24 "[24] Hochschule Zittau/Görlitz" 25 "[25] Westsächsische Hochschule Zwickau" 31 "[31] Hochschule für Musik Carl Maria von Weber Dresden" 32 "[32] Hochschule für Bildende Künste Dresden" 33 "[33] Palucca Hochschule für Tanz Dresden" 34 "[34] Hochschule für Grafik und Buchkunst Leipzig" 35 "[35] Hochschule für Musik und Theater Felix Mendelssohn Bartholdy Leipzig" 
label values f02shk f02shk_labelset

label define f03_labelset 1 "[1] Professor*innen" 2 "[2] Akademische Assistent*innen" 3 "[3] Wissenschaftliche/künstlerische Mitarbeiter*innen" 4 "[4] Wissenschaftliche/künstlerische Hilfskräfte" 5 "[5] Studentische Hilfskräfte" 6 "[6] Lehrkräfte für besondere Aufgaben (LfbA)" 7 "[7] Mitarbeiter*innen in Service, Technik und Verwaltung (Wissenschaftsunterstützendes Personal)" 8 "[8] Sonstiges, und zwar:" 
label values f03 f03_labelset

label define f04a_labelset 1 "[1] Leitende Angestellte / Meister*innen / Tätigkeit mit umfassenden Führungsaufgaben" 2 "[2] Qualifizierte Angestellte mit mittlerer Leitungsfunktion / hoch qualifizierte Tätigkeit" 3 "[3] Qualifizierte Angestellte ohne Leitungsfunktion / Facharbeiter*innen (mit Lehre) / qualifizierte Tätigkeit" 4 "[4] Ausführende Angestellte / Un- und angelernte Arbeiter*innen / Auszubildende / einfache Tätigkeit" 5 "[5] Beamte im höheren Dienst" 6 "[6] Beamte im gehobenen Dienst" 7 "[7] Beamte im mittleren Dienst" 8 "[8] Beamte im einfachen Dienst" 
label values f04a f04a_labelset

label define f04_labelset 1 "[1] zentral (z. B. Verwaltung, Technik in Dezernaten oder Referaten, hochschulweites Service-Angebot)" 2 "[2] dezentral (z. B. in einem Fachbereich/Institut oder an einer Fakultät)" 3 "[3] sowohl zentral, als auch dezentral" 
label values f04 f04_labelset

label define f05_labelset 1 "[1] Geisteswissenschaften" 2 "[2] Rechts-, Wirtschafts- und Sozialwissenschaften" 3 "[3] Mathematik, Naturwissenschaften" 4 "[4] Humanmedizin/Gesundheitswissenschaften" 5 "[5] Sport" 6 "[6] Agrar-, Forst- und Ernährungswissenschaften, Veterinärmedizin" 7 "[7] Ingenieurwissenschaften" 8 "[8] Kunst/Kunstwissenschaften, Musik/Musikwissenschaft, Darstellende Kunst, Gestaltung u. ä." -90 "[-90] Überwiegende Zuordnung nicht möglich, da zu gleichen Teilen in mehreren Bereichen beschäftigt" -91 "[-91] Außerhalb der Fächersystematik (z. B. zentrale Verwaltung, technischer Bereich)" 
label values f05 f05_labelset

label define f06_labelset 1 "[1] ja" 2 "[2] nein, befristet" 
label values f06 f06_labelset

label define f07_labelset 1 "[1] Juniorprofessur mit Tenure Track" 2 "[2] Juniorprofessur ohne Tenure Track" 3 "[3] sonstige Professur mit Tenure Track" 4 "[4] sonstige Professur (z. B. Stiftungsprofessur)" 
label values f07 f07_labelset

label define f08_labelset 1 "[1] ja, ausschließlich befristet" 2 "[2] ja, teilweise befristet" 3 "[3] nein, ausschließlich unbefristet" 
label values f08 f08_labelset

label define f09_labelset 1 "[1] nach Wissenschaftszeitvertragsgesetz (WissZeitVG)" 2 "[2] nach Teilzeit- und Befristungsgesetz (TzBfG)" 3 "[3] andere Grundlage, und zwar:" -98 "[-98] weiß nicht" 
label values f09 f09_labelset

label define f10a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10a f10a_labelset

label define f10b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10b f10b_labelset

label define f10c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10c f10c_labelset

label define f10d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10d f10d_labelset

label define f10e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10e f10e_labelset

label define f10f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10f f10f_labelset

label define f10g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10g f10g_labelset

label define f10h_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10h f10h_labelset

label define f10i_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10i f10i_labelset

label define f10j_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10j f10j_labelset

label define f10k_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10k f10k_labelset

label define f10l_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10l f10l_labelset

label define f10m_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10m f10m_labelset

label define f10n_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10n f10n_labelset

label define f10o_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10o f10o_labelset

label define f10p_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10p f10p_labelset

label define f10q_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10q f10q_labelset

label define f10r_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10r f10r_labelset

label define f10s_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10s f10s_labelset

label define f10v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10v f10v_labelset

label define f10w_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f10w f10w_labelset

label define f11_labelset 1 "[1] Ja, ich habe mehrere unmittelbare Vorgesetzte, und zwar:" 2 "[2] Nein" 
label values f11 f11_labelset

label define f11x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f11x f11x_labelset

label define f12_labelset 1 "[1] in Teilzeit" 2 "[2] in Vollzeit" 
label values f12 f12_labelset

label define f13_labelset 1 "[1] mit" -98 "[-98] weiß nicht" -97 "[-97] Frage trifft nicht zu, da kein Stellenanteil vereinbart wurde." 
label values f13 f13_labelset

label define f13x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f13x f13x_labelset

label define f14_labelset 1 "[1] Es sind durchschnittlich" 1 "[1] Es wurden" -97 "[-97] Nein, eine Stundenzahl wurde nicht vereinbart." -98 "[-98] Weiß nicht." 
label values f14 f14_labelset

label define f14x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f14x f14x_labelset

label define f15a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f15a f15a_labelset

label define f15b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f15b f15b_labelset

label define f15x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f15x f15x_labelset

label define f16_labelset 1 "[1] vollständig/überwiegend durch Haushaltsmittel" 2 "[2] vollständig/überwiegend durch Dritt- oder Sondermittel" 3 "[3] zu etwa gleichen Teilen durch Haushaltsmittel und Dritt/-Sondermittel" 4 "[4] anders finanziert, und zwar:" -98 "[-98] weiß nicht" 
label values f16 f16_labelset

label define f17x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f17x f17x_labelset

label define f18_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f18 f18_labelset

label define f19_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f19 f19_labelset

label define f21x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f21x f21x_labelset

label define f22_labelset 1 "[1] Ja, und zwar unbefristet." 2 "[2] Ja, und zwar mit einer Laufzeit von" 3 "[3] Nein." 
label values f22 f22_labelset

label define f22x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f22x f22x_labelset

label define f23_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f23 f23_labelset

label define f24_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f24 f24_labelset

label define f26_labelset 1 "[1] ja" 2 "[2] nein" 
label values f26 f26_labelset

label define f27_labelset 1 "[1] Die Information wurde mir innerhalb der letzten vier Wochen gegeben." 2 "[2] Die Information wurde mir vor etwa" -98 "[-98] weiß nicht" 
label values f27 f27_labelset

label define f27x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f27x f27x_labelset

label define f28a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28a f28a_labelset

label define f28b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28b f28b_labelset

label define f28c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28c f28c_labelset

label define f28d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28d f28d_labelset

label define f28e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28e f28e_labelset

label define f28f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28f f28f_labelset

label define f28g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28g f28g_labelset

label define f28h_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28h f28h_labelset

label define f28v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28v f28v_labelset

label define f28w_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f28w f28w_labelset

label define f29_labelset 1 "[1] (noch) keinen" 2 "[2] Bachelor" 3 "[3] Master/Staatsexamen/Diplom/Magister" 4 "[4] Sonstiges, und zwar:" 
label values f29 f29_labelset

label define f30_labelset 1 "[1] Ja." 2 "[2] Nein, aber ich promoviere derzeit." 3 "[3] Nein, und ich promoviere (derzeit) auch nicht." 
label values f30 f30_labelset

label define f31_labelset 1 "[1] Ja." 2 "[2] Nein, aber eine andere Person betreut mich." 3 "[3] Nein, ich habe derzeit (noch) keine Betreuung." -98 "[-98] Weiß nicht." 
label values f31 f31_labelset

label define f32_labelset 1 "[1] Ja, ich bin habilitiert." 2 "[2] Nein, aber ich befinde mich im Habilitationsprozess." 3 "[3] Nein, ich bin nicht habilitiert und befinde mich auch nicht im Habilitationsprozess." 
label values f32 f32_labelset

label define f33_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f33 f33_labelset

label define f34_labelset 1 "[1] ja, schriftlich vereinbart" 2 "[2] ja, aber nur mündlich vereinbart" 3 "[3] nein" 
label values f34 f34_labelset

label define f35_labelset 1 "[1] Der vereinbarte Anteil beträgt:" 2 "[2] Es ist kein genauer Anteil festgelegt." 
label values f35 f35_labelset

label define f35x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f35x f35x_labelset

label define f36x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f36x f36x_labelset

label define f37x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f37x f37x_labelset

label define f38x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f38x f38x_labelset

label define f39a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39a f39a_labelset

label define f39b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39b f39b_labelset

label define f39c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39c f39c_labelset

label define f39d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39d f39d_labelset

label define f39e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39e f39e_labelset

label define f39f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39f f39f_labelset

label define f39g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39g f39g_labelset

label define f39v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39v f39v_labelset

label define f39w_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f39w f39w_labelset

label define f40_labelset 1 "[1] Lebenszeitprofessur" 2 "[2] (andere) Leitungsposition" 3 "[3] Lehrkraft für besondere Aufgaben" 4 "[4] entfristete Mittelbaustelle" 5 "[5] (andere) Position ohne Leitungsfunktion" 6 "[6] Selbstständigkeit/Freiberufliche Tätigkeit" 7 "[7] andere Position, und zwar:" -98 "[-98] weiß nicht" 
label values f40 f40_labelset

label define f41_labelset 1 "[1] ja" 2 "[2] nein" 
label values f41 f41_labelset

label define f42_labelset 1 "[1] ja" 2 "[2] nein" 
label values f42 f42_labelset

label define f43_labelset 1 "[1] ja, in der gleichen Personalkategorie wie derzeit" 2 "[2] ja, (auch) in einer anderen Personalkategorie als derzeit" 3 "[3] nein" 
label values f43 f43_labelset

label define f44a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f44a f44a_labelset

label define f44b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f44b f44b_labelset

label define f44c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f44c f44c_labelset

label define f44d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f44d f44d_labelset

label define f44e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f44e f44e_labelset

label define f44f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f44f f44f_labelset

label define f44v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f44v f44v_labelset

label define f45x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f45x f45x_labelset

label define f46x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f46x f46x_labelset

label define f47x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f47x f47x_labelset

label define f48x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f48x f48x_labelset

label define f49_labelset 1 "[1] Ja, insgesamt gab es:" 2 "[2] Nein, es gab keine ungewollten Beschäftigungslücken." 
label values f49 f49_labelset

label define f49x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f49x f49x_labelset

label define f50x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f50x f50x_labelset

label define f51a_labelset 1 "[1] Das mache ich überwiegend/häufig." 2 "[2] Das mache ich gelegentlich." 3 "[3] Das mache ich üblicherweise nicht." 
label values f51a f51a_labelset

label define f51b_labelset 1 "[1] Das mache ich überwiegend/häufig." 2 "[2] Das mache ich gelegentlich." 3 "[3] Das mache ich üblicherweise nicht." 
label values f51b f51b_labelset

label define f51c_labelset 1 "[1] Das mache ich überwiegend/häufig." 2 "[2] Das mache ich gelegentlich." 3 "[3] Das mache ich üblicherweise nicht." 
label values f51c f51c_labelset

label define f52a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52a f52a_labelset

label define f52b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52b f52b_labelset

label define f52c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52c f52c_labelset

label define f52d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52d f52d_labelset

label define f52e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52e f52e_labelset

label define f52f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52f f52f_labelset

label define f52g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52g f52g_labelset

label define f52h_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52h f52h_labelset

label define f52i_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52i f52i_labelset

label define f52j_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52j f52j_labelset

label define f52k_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52k f52k_labelset

label define f52l_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52l f52l_labelset

label define f52v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f52v f52v_labelset

label define f53_labelset 1 "[1] ja" 2 "[2] nein, aber der Abschluss einer Vereinbarung ist in Vorbereitung" 3 "[3] nein" 
label values f53 f53_labelset

label define f54a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54a f54a_labelset

label define f54b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54b f54b_labelset

label define f54c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54c f54c_labelset

label define f54d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54d f54d_labelset

label define f54e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54e f54e_labelset

label define f54f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54f f54f_labelset

label define f54g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54g f54g_labelset

label define f54h_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54h f54h_labelset

label define f54i_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54i f54i_labelset

label define f54j_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54j f54j_labelset

label define f54k_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54k f54k_labelset

label define f54v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54v f54v_labelset

label define f54w_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f54w f54w_labelset

label define f55a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f55a f55a_labelset

label define f55b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f55b f55b_labelset

label define f55c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f55c f55c_labelset

label define f55d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f55d f55d_labelset

label define f55e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f55e f55e_labelset

label define f55f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f55f f55f_labelset

label define f56a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f56a f56a_labelset

label define f56b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f56b f56b_labelset

label define f56c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f56c f56c_labelset

label define f56d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f56d f56d_labelset

label define f57a_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57a f57a_labelset

label define f57b_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57b f57b_labelset

label define f57c_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57c f57c_labelset

label define f57d_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57d f57d_labelset

label define f57e_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57e f57e_labelset

label define f57f_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57f f57f_labelset

label define f57g_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57g f57g_labelset

label define f57h_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57h f57h_labelset

label define f57i_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57i f57i_labelset

label define f57j_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57j f57j_labelset

label define f57k_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57k f57k_labelset

label define f57l_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57l f57l_labelset

label define f57v_labelset 1 "[1] sehr wichtig" 2 "[2] eher wichtig" 3 "[3] weniger wichtig" 4 "[4] nicht wichtig" 
label values f57v f57v_labelset

label define f58a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f58a f58a_labelset

label define f58b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f58b f58b_labelset

label define f58c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f58c f58c_labelset

label define f58d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f58d f58d_labelset

label define f59a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59a f59a_labelset

label define f59b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59b f59b_labelset

label define f59c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59c f59c_labelset

label define f59d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59d f59d_labelset

label define f59e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59e f59e_labelset

label define f59f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59f f59f_labelset

label define f59g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59g f59g_labelset

label define f59h_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59h f59h_labelset

label define f59v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f59v f59v_labelset

label define f60_labelset 1 "[1] Ja, und ich habe angenommen." 2 "[2] Ja, und ich habe abgelehnt." 3 "[3] Nein, mir wurde kein Gespräch angeboten." 
label values f60 f60_labelset

label define f61_labelset 1 "[1] Ja" 2 "[2] Nein" 
label values f61 f61_labelset

label define f62_labelset 1 "[1] Ja" 2 "[2] Nein" -98 "[-98] Kann ich nicht beurteilen." 
label values f62 f62_labelset

label define f63_labelset 1 "[1] Ja" 2 "[2] Nein" -98 "[-98] Kann ich nicht beurteilen." 
label values f63 f63_labelset

label define f64a_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" 
label values f64a f64a_labelset

label define f64b_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -98 "[-98] kann ich nicht beurteilen" 
label values f64b f64b_labelset

label define f64c_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" 
label values f64c f64c_labelset

label define f65a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f65a f65a_labelset

label define f65b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f65b f65b_labelset

label define f65c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f65c f65c_labelset

label define f65d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f65d f65d_labelset

label define f65e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f65e f65e_labelset

label define f65f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f65f f65f_labelset

label define f65g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f65g f65g_labelset

label define f66a_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66a f66a_labelset

label define f66b_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66b f66b_labelset

label define f66c_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66c f66c_labelset

label define f66d_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66d f66d_labelset

label define f66e_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66e f66e_labelset

label define f66f_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66f f66f_labelset

label define f66g_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66g f66g_labelset

label define f66h_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66h f66h_labelset

label define f66i_labelset 1 "[1] sehr zufrieden" 2 "[2] eher zufrieden" 3 "[3] eher unzufrieden" 4 "[4] sehr unzufrieden" -97 "[-97] trifft nicht zu" 
label values f66i f66i_labelset

label define f67a_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67a f67a_labelset

label define f67b_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67b f67b_labelset

label define f67c_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67c f67c_labelset

label define f67d_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67d f67d_labelset

label define f67e_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67e f67e_labelset

label define f67f_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67f f67f_labelset

label define f67g_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67g f67g_labelset

label define f67h_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67h f67h_labelset

label define f67i_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67i f67i_labelset

label define f67j_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67j f67j_labelset

label define f67k_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67k f67k_labelset

label define f67l_labelset 1 "[1] trifft voll zu" 2 "[2] trifft eher zu" 3 "[3] trifft eher nicht zu" 4 "[4] trifft nicht zu" -97 "[-97] kann ich nicht beurteilen" 
label values f67l f67l_labelset

label define f68_labelset 1 "[1] Ja, die Inhalte sind mir bekannt." 2 "[2] Davon habe ich schon mal gehört, aber ich kenne die Inhalte nicht oder nicht genau." 3 "[3] Nein, davon habe ich noch nicht gehört." 
label values f68 f68_labelset

label define f70a_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f70a f70a_labelset

label define f70b_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f70b f70b_labelset

label define f70c_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f70c f70c_labelset

label define f70d_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f70d f70d_labelset

label define f70e_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f70e f70e_labelset

label define f70f_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f70f f70f_labelset

label define f70v_labelset 1 "[1] ja" 2 "[2] nein" -98 "[-98] weiß nicht" 
label values f70v f70v_labelset

label define f71a_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71a f71a_labelset

label define f71b_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71b f71b_labelset

label define f71c_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71c f71c_labelset

label define f71d_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71d f71d_labelset

label define f71e_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71e f71e_labelset

label define f71f_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71f f71f_labelset

label define f71g_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71g f71g_labelset

label define f71h_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71h f71h_labelset

label define f71i_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71i f71i_labelset

label define f71j_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71j f71j_labelset

label define f71k_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71k f71k_labelset

label define f71v_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f71v f71v_labelset

label define f72a_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72a f72a_labelset

label define f72b_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72b f72b_labelset

label define f72c_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72c f72c_labelset

label define f72d_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72d f72d_labelset

label define f72e_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72e f72e_labelset

label define f72f_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72f f72f_labelset

label define f72g_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72g f72g_labelset

label define f72h_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72h f72h_labelset

label define f72i_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72i f72i_labelset

label define f72j_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72j f72j_labelset

label define f72k_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72k f72k_labelset

label define f72v_labelset 1 "[1] genutzt" 2 "[2] nicht genutzt" 
label values f72v f72v_labelset

label define f73x_labelset 1 "[1] Ja" 0 "[0] Nein" 
label values f73x f73x_labelset

label define f74_labelset 1 "[1] männlich" 2 "[2] weiblich" 3 "[3] divers" -98 "[-98] Ich möchte hierzu keine Angabe machen." 
label values f74 f74_labelset

*____________Variablenlabels importieren____________________
label var preloadpre_hs ""
label var consent " Ich habe die Datenschutzerklärung gelesen und bin damit einverstanden, dass me"
label var noconsent " Ich habe den Hinweis verstanden und möchte nicht teilnehmen."
label var flag_index ""
label var f01 "Würden Sie uns zumindest mitteilen, an welcher Hochschulart Sie beschäftigt sin"
label var f02shk "Bitte sagen Sie uns zunächst, über welche Hochschule Sie zu dieser Befragung ei"
label var f03 "Welcher Personalkategorie ordnen Sie sich selbst zu?"
label var f03str "Welcher Personalkategorie ordnen Sie sich selbst zu? Sonstiges, und zwar:"
label var flag_f03 ""
label var f04a "Welcher beruflichen Stellung oder Laufbahngruppe ordnen Sie sich zu bzw. welche"
label var f04 "Sind Sie als Mitarbeiter*in in Service, Technik und Verwaltung (wissenschaftsun"
label var f05 "Welcher Fächergruppe ist Ihre Stelle am ehesten zugehörig?"
label var f06 "Ist Ihre Professur unbefristet?"
label var f07 "Um was für eine befristete Professur handelt es sich?"
label var f08 "Sind Sie (ganz oder teilweise) befristet beschäftigt?"
label var f09 "Auf welcher gesetzlichen Grundlage sind Sie befristet beschäftigt?"
label var f09_str "Auf welcher gesetzlichen Grundlage sind Sie befristet beschäftigt? andere Grund"
label var f10a "Welche Befristungsgründe treffen auf Sie zu? Die Vertragslaufzeit ist an die Pr"
label var f10b "Welche Befristungsgründe treffen auf Sie zu? Stelle ist eine Vertretung (z. B. "
label var f10c "Welche Befristungsgründe treffen auf Sie zu? Studien- oder Promotionsabschluss "
label var f10d "Welche Befristungsgründe treffen auf Sie zu? Befristungsgrenze des Wissenschaft"
label var f10e "Welche Befristungsgründe treffen auf Sie zu? Finanzierung läuft aus, mehr Mitte"
label var f10f "Welche Befristungsgründe treffen auf Sie zu? Die Vertragslaufzeit ist an die Vo"
label var f10g "Welche Befristungsgründe treffen auf Sie zu? Überbrückung, Zwischenfinanzierung"
label var f10h "Welche Befristungsgründe treffen auf Sie zu? Bevorstehende Förderung aus andere"
label var f10i "Welche Befristungsgründe treffen auf Sie zu? Vertrag ist an eine bestimmte Aufg"
label var f10j "Welche Befristungsgründe treffen auf Sie zu? Der Bedarf an der Arbeitsleistung "
label var f10k "Welche Befristungsgründe treffen auf Sie zu? Die Befristung erfolgt im Anschlus"
label var f10l "Welche Befristungsgründe treffen auf Sie zu? Die Eigenart der Arbeitsleistung b"
label var f10m "Welche Befristungsgründe treffen auf Sie zu? Die Befristung dient der Erprobung"
label var f10n "Welche Befristungsgründe treffen auf Sie zu? Die Vergütung ist haushaltsrechtli"
label var f10o "Welche Befristungsgründe treffen auf Sie zu? Die Befristung beruht auf einem ge"
label var f10p "Welche Befristungsgründe treffen auf Sie zu? Befristung erfolgt sachgrundlos (z"
label var f10q "Welche Befristungsgründe treffen auf Sie zu? Mein*e Vorgesetzte*r hat es so ent"
label var f10r "Welche Befristungsgründe treffen auf Sie zu? Eigener Wunsch, persönliche Gründe"
label var f10s "Welche Befristungsgründe treffen auf Sie zu? Auslaufende Aufenthaltsgenehmigung"
label var f10v "Welche Befristungsgründe treffen auf Sie zu? Anderer Grund, und zwar:"
label var f10v_str "Welche Befristungsgründe treffen auf Sie zu? Anderer Grund, und zwar:"
label var f10w "Welche Befristungsgründe treffen auf Sie zu? Weiß nicht. / Mir wurde kein Grund"
label var f11 "Haben Sie mehr als eine*n unmittelbare*n Vorgesetzte*n?"
label var f11_str ""
label var f11x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f12 "Sind Sie an Ihrer Hochschule in Teilzeit oder in Vollzeit beschäftigt?"
label var f13 "In welchem Stellenanteil sind Sie derzeit an Ihrer Hochschule insgesamt beschäf"
label var f13a_str ""
label var f13x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f14 "Können Sie Angaben zur vereinbarten Wochenarbeitszeit oder der vereinbarten Ges"
label var f14a_str ""
label var f14b_str ""
label var f14x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f15a "In welchem Stellenumfang sind Sie an Ihrer Hochschule jeweils befristet und unb"
label var f15a1_str ""
label var f15a2_str ""
label var f15b "In welchem Stellenumfang sind Sie an Ihrer Hochschule jeweils befristet und unb"
label var f15b1_str ""
label var f15b2_str ""
label var f15x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f16 "Wie ist Ihre Stelle bzw. der befristete Anteil Ihrer Stelle finanziert?"
label var f16_str "Wie ist Ihre Stelle bzw. der befristete Anteil Ihrer Stelle finanziert? anders "
label var f17_str ""
label var f17x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f18 "War die Stelle Ihres gegenwärtigen Vertrags ausgeschrieben?"
label var f19 "Wurde bei der Ausschreibung angegeben, in welche Entgeltgruppe Sie voraussichtl"
label var f21_str ""
label var f21x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f22 "Haben Sie bereits einen Folgevertrag unterschrieben?"
label var f22_str ""
label var f22x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f23 "War die Stelle Ihres Folgevertrags ausgeschrieben?"
label var f24 "Wurde bei dieser Ausschreibung angegeben, in welche Entgeltgruppe Sie voraussic"
label var f26 "Wurden Sie seit Beginn des gegenwärtigen Arbeitsvertrags darüber informiert, ob"
label var f27 "Wie lange ist das ungefähr her?"
label var f27_str ""
label var f27x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f28a "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28b "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28c "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28d "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28e "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28f "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28g "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28h "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28v "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28v_str "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f28w "Wissen Sie schon, wie es im Anschluss an Ihre gegenwärtige Beschäftigung berufl"
label var f29 "Nach diesen Fragen zu Ihrer derzeitigen Beschäftigung haben wir nun einige Frag"
label var f29_str "Nach diesen Fragen zu Ihrer derzeitigen Beschäftigung haben wir nun einige Frag"
label var f30 "Sind Sie promoviert?"
label var f31 "Werden Sie in Ihrer Promotion von Ihrer/Ihrem Dienstvorgesetzten betreut?"
label var f32 "Sind Sie habilitiert?"
label var f33 "Gehört die wissenschaftliche oder künstlerische Weiterqualifizierung laut Arbei"
label var f34 "Und ist Ihnen ein Teil Ihrer Arbeitszeit zur wissenschaftlichen oder künstleris"
label var f35 "Wie hoch ist dieser vereinbarte Anteil Ihrer Arbeitszeit, der Ihnen zur Qualifi"
label var f35_str ""
label var f35x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f36_str ""
label var f36x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f37a_str ""
label var f37b_str ""
label var f37c_str ""
label var f37d_str ""
label var f37e_str ""
label var f37v_str ""
label var f37x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f38a_str ""
label var f38b_str ""
label var f38c_str ""
label var f38v_str ""
label var f38x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f39a "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39b "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39c "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39d "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39e "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39f "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39g "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39v "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39v_str "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f39w "Wenn Sie nun einmal an Ihre berufliche Zukunft denken: In welchem Bereich möcht"
label var f40 "Und welche Position entspricht am ehesten Ihrer langfristigen Vorstellung?"
label var f40_str "Und welche Position entspricht am ehesten Ihrer langfristigen Vorstellung? ande"
label var f41 "Kommen wir noch einmal kurz zurück zu Ihrer Berufsbiografie an sächsischen Hoch"
label var f42 "Waren Sie zuvor als studentische Hilfskraft an einer staatlichen Hochschule in "
label var f43 "Gab es weitere Vorbeschäftigungen an einer staatlichen Hochschule in Sachsen?"
label var f44a "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f44b "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f44c "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f44d "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f44e "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f44f "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f44v "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f44_str "In welcher weiteren Personalkategorie waren Sie zuvor bereits an einer staatlic"
label var f45_str ""
label var f45x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f46_m ""
label var f46_y ""
label var f46x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f47_str ""
label var f47x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f48_y ""
label var f48x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f49 "Und gab es in dieser Zeit tatsächliche, ungewollte Beschäftigungslücken, d. h. "
label var f49_str ""
label var f49x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f50_str ""
label var f50x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f51a "Unmittelbare Unterstützung und Zuarbeiten im Bereich Forschung (z. B. Literatur"
label var f51b "Unmittelbare Unterstützung und Zuarbeiten im Bereich Lehre und Prüfungen (z. B."
label var f51c "Sonstige Unterstützung und Zuarbeiten, die sich nicht unmittelbar den Bereichen"
label var f52a "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52b "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52c "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52d "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52e "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52f "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52g "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52h "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52i "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52j "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52k "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52l "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52v "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f52v_str "Hier möchten wir noch einmal genauer nachfragen. Welche sonstigen Aufgaben über"
label var f53 "Nachdem wir nun viele Fragen zu Ihrer Beschäftigung gestellt haben, geht es auf"
label var f54a "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54b "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54c "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54d "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54e "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54f "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54g "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54h "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54i "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54j "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54k "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54v "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54v_str "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f54w "Uns interessieren die Inhalte Ihrer Betreuungsvereinbarung. Welche der folgende"
label var f55a "Welche der folgenden Aussagen trifft bzw. treffen auf Gespräche mit Ihrem/Ihrer"
label var f55b "Welche der folgenden Aussagen trifft bzw. treffen auf Gespräche mit Ihrem/Ihrer"
label var f55c "Welche der folgenden Aussagen trifft bzw. treffen auf Gespräche mit Ihrem/Ihrer"
label var f55d "Welche der folgenden Aussagen trifft bzw. treffen auf Gespräche mit Ihrem/Ihrer"
label var f55e "Welche der folgenden Aussagen trifft bzw. treffen auf Gespräche mit Ihrem/Ihrer"
label var f55f "Welche der folgenden Aussagen trifft bzw. treffen auf Gespräche mit Ihrem/Ihrer"
label var f56a "Welche weiteren Unterstützungsleistungen können Sie berichten? Ihr*e Betreuer*i"
label var f56b "Welche weiteren Unterstützungsleistungen können Sie berichten? Ihr*e Betreuer*i"
label var f56c "Welche weiteren Unterstützungsleistungen können Sie berichten? Ihr*e Betreuer*i"
label var f56d "Welche weiteren Unterstützungsleistungen können Sie berichten? Ihr*e Betreuer*i"
label var f57a "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57b "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57c "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57d "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57e "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57f "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57g "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57h "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57i "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57j "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57k "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57l "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57v "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f57v_str "Welche Rolle spielen die nachfolgenden Felder im Rahmen Ihrer gegenwärtigen Qua"
label var f58a "Der Rahmenkodex über den Umgang mit befristeter Beschäftigung an den sächsische"
label var f58b "Der Rahmenkodex über den Umgang mit befristeter Beschäftigung an den sächsische"
label var f58c "Der Rahmenkodex über den Umgang mit befristeter Beschäftigung an den sächsische"
label var f58c_str "Der Rahmenkodex über den Umgang mit befristeter Beschäftigung an den sächsische"
label var f58d "Der Rahmenkodex über den Umgang mit befristeter Beschäftigung an den sächsische"
label var f59a "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59b "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59c "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59d "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59e "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59f "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59g "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59h "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59v "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f59v_str "Warum werden Sie in absehbarer Zeit nicht über den normalen Befristungsrahmen d"
label var f60 "Im Folgenden geht es um jährliche Gespräche, die mit Ihrer/Ihrem Dienstvorgeset"
label var f61 "Hat dieses Gespräch stattgefunden?"
label var f62 "Haben Sie im Rahmen des Jahresgespräches Feedback über Ihre Leistungen und Ihre"
label var f63 "Haben Sie im Rahmen des mit Ihnen geführten Jahresgesprächs mit Ihrer bzw. Ihre"
label var f64a "Wie beurteilen Sie die nachfolgende Aussage zu dem mit Ihnen geführten Jahresge"
label var f64b "Wie beurteilen Sie die nachfolgende Aussage zu dem mit Ihnen geführten Jahresge"
label var f64c "Wie beurteilen Sie die nachfolgende Aussage zu dem mit Ihnen geführten Jahresge"
label var f65a "Welche Wirkungen hatte das Jahresgespräch auf Sie? Durch das Gespräch hat sich "
label var f65b "Welche Wirkungen hatte das Jahresgespräch auf Sie? Durch das Gespräch hat sich "
label var f65c "Welche Wirkungen hatte das Jahresgespräch auf Sie? Das Gespräch hat sich positi"
label var f65d "Welche Wirkungen hatte das Jahresgespräch auf Sie? Durch das Gespräch habe ich "
label var f65e "Welche Wirkungen hatte das Jahresgespräch auf Sie? Das Gespräch hatte keine Wir"
label var f65f "Welche Wirkungen hatte das Jahresgespräch auf Sie? Das Gespräch hat zu Spannung"
label var f65g "Welche Wirkungen hatte das Jahresgespräch auf Sie? Das Gespräch hat zu Spannung"
label var f66a "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? Verhältnis zu Kolle"
label var f66b "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? Verhältnis zu Vorge"
label var f66c "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? eigene Lehrtätigkei"
label var f66d "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? eigene Forschungstä"
label var f66e "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? Beschäftigungssiche"
label var f66f "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? berufliche Perspekt"
label var f66g "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? Verwirklichung eige"
label var f66h "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? erreichte beruflich"
label var f66i "Wie zufrieden sind Sie mit folgenden Aspekten Ihrer Stelle? berufliche Situatio"
label var f67a "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67b "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67c "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67d "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67e "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67f "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67g "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67h "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67i "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67j "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67k "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f67l "Wie beurteilen Sie die nachfolgenden Aussagen vor dem Hintergrund Ihrer bisheri"
label var f68 "Kennen Sie den „Rahmenkodex über den Umgang mit befristeter Beschäftigung und d"
label var f69a_str "Wie beurteilen Sie den Rahmenkodex? Größte Stärken:"
label var f69b_str "Dringendster Handlungsbedarf:"
label var f70a "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f70b "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f70c "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f70d "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f70e "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f70f "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f70v "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f70v_str "Kurz vor Ende der Befragung bitten wir an dieser Stelle um Ihre Einschätzungen "
label var f71a "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71b "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71c "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71d "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71e "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71f "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71g "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71h "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71i "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71j "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71k "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71v "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f71v_str "Welche Anlaufstellen sind Ihnen bekannt, um Fälle von Machtmissbrauch höher ges"
label var f72a "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Ombudsstell"
label var f72b "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Gleichstell"
label var f72c "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Diversitäts"
label var f72d "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Personalabt"
label var f72e "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Justiziaria"
label var f72f "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Studienbera"
label var f72g "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Studiendeka"
label var f72h "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Hochschulle"
label var f72i "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Beauftragte"
label var f72j "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Personalrat"
label var f72k "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Beschwerdes"
label var f72v "Und haben Sie diese Anlaufstelle(n) in diesem Zusammenhang genutzt? Andere: #{f"
label var f73_y ""
label var f73x " Ich habe den Hinweis verstanden und möchte dennoch fortfahren."
label var f74 "Bitte nennen Sie uns Ihr Geschlecht."
label var f75_str "Zum Abschluss dieser Befragung danken wir Ihnen sehr für Ihre Teilnahme. Wenn S"
label var cncl_str "Bitte beachten Sie, dass Sie die Befragung nur fortführen können, wenn Sie eine"

*_____________Arbeitsdatensatz importieren____________________
saveold "..\..\csv\arbeitsdaten.dta", replace
