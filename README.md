Installation
	1.	Krav:
	•	Flutter SDK (minst version 3.x.x)
	•	Enhet eller emulator för MacOS/iOS
	2.	Installationssteg:
# Klona projektet
git clone https://github.com/Javadov/parkomatApp.git

# Gå till projektmappen
cd parking_admin
cd parking_shared
cd parking_user

# Installera beroenden
flutter pub get

# Starta appen
flutter run



Implementerade funktioner på Klient sida
1.	Parkering
	•	Visa tillgängliga parkeringsplatser på en karta.
	•	Sök med avancerade sökfunktion (ID, adress, stad, pris m.m.).
	•	Markörer som visar detaljer om parkeringsplatser.

2.	Mina parkeringar
	•	Visa aktiva parkeringar med möjlighet att stoppa eller förlänga dem.
	•	Visa parkeringshistorik med sorteringsfunktioner.

3.	Användarprofil
	•	Redigera personuppgifter.
	•	Hantera fordon.
	•	Hantera favoriter och inställningar.
	•	Logga ut.


Implementerade funktioner på Admin sida
1.	Hantera parkeringsplatser
	•	Lägg till, redigera eller ta bort parkeringsplatser.
	•	Visa en lista över alla parkeringsplatser med detaljer som pris, adress och status.

2.	Användarhantering
	•	Visa en lista över alla användare.
	•	Redigera eller ta bort användarkonton.
	•	Visa detaljerad historik över användarnas parkeringar.

3.	Rapporter och analyser
	•	Generera rapporter över parkeringsanvändning.
	•	Visa statistik som totala inkomster, mest använda parkeringsplatser och användartrender.
