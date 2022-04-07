# AD Scripte
Powershell Scripte rund um Active Directory

## Übersicht der Scripte

| Datei | Beschreibung |
| ------ | ------ |
| .\CompareUsers.ps1 | Vergleichen der Email Adresse der Benutzer anhand einer CSV-Datei |
| .\CompareUsersEmail.ps1 | Vergleichen der Email Adresse **eines betr. Benutzers** anhand der E-Mail Adresse |
| .\CheckingIfUserHasSoLiMaTRolle.ps1 | Auflisten alle Benutzer für eine best. SoLiMaT Rolle |

#### 1. CompareUsers.ps1 / CompareUsersEmail.ps1
Ziel und Beschreibung:
im SoLiMaT nach die MCI Migration wurden festgestellt, dass bestimmte Users schon neue E-Mail Adresse haben. Um die neue/richtige E-Mail Adressen zu bekommen, werden alle User Email Adressen im AD vergliechen und die Ergebnisse als JSON exportiert.

##### Voraussetzung
**Input**
Datei Format **_CSV_**, wo der Delimiter ist **"_;_"**. Die Datei beinhaltet folgende Felder:
```sh
ID, Email
```

**Output**
Datei Format **_JSON_** und beinhaltet folgende Felder:
```sh
UserID = $UserID
Email = $Email
CheckingEmail = $email_address
```
**Email**: alte E-Mail, kommt aus der CSV-Datei
**CheckingEmail**: neue Email aus AD
##### Funktionen
Es wurde eine Funktion gebaut, mit der man anhand der E-Mail Adresse der Benutzer feststellen kann
in welchem Domain er gehört.
```sh
Get-AdUserByMail
```
>Die Abfarge aus AD wird mit dem Filter _Domain_ also erweiter.
Die Powershell Code kann aktuell nur für die folgende Domaine die Userdaten abfragen:
"CDS", "EMEA1", "EMEA2"

##### Hinweis
**Hinsicht auf der User Menge, kann die Ausführung auch mehr als 50 Minuten dauern.**

--------------------

#### 2. CheckingIfUserHasSoLiMaTRolle.ps1

Ziel und Beschreibung:
Es ist auch möglich aus der Active Directory die Mitgliedschaften der Users abzufragen. In der Code fragen wir bestimmte Daten von Users ab. Die konkrete SoLiMaT Rolle wird nicht abgefragt es wird nur geprüft ob eine Solimat Rolle für den User im AD vorhanden ist.

**Method:**
```sh
$all_ad_group = ([ADSISEARCHER]"proxyaddresses=$($smtp)").Findone().Properties.memberof -replace '^CN=([^,]+).+$','$1'
```
>Mit der Abfrage werden alle Mitgliedschaften des Benutzers abgefragt.
Für uns sind aber nur die SoLiMaT Gruppen relevant: **_GRP-19976_**
```sh
if($solimatgroups.StartsWith("GRP-19976")){}
```

##### Voraussetzung
**Input**
Datei Format **_TXT_**, wo der Delimiter ist **"_;_"**. Die Datei beinhalten nur E-Mail Adressen:
_Alle aufgeführten E-Mail Adressen müssen in neue Zeile geschrieben werden. (Kein Delimiter)_
```sh
Email1
Email2
Email3
usw...
```

**Output**
Datei Format **_JSON_** und beinhaltet folgende Informationen:
```sh
"displayname" = $name
"email"  = $email_address
"country"  = $country
"location"  = $standort
"licence"  = $licence
"solimat" = $soli
```

