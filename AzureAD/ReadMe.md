# Azure AD Scripte
Powershell Scripte rund um Active Directory
_Azure AD: Azure Active Directory_

## Allgemeine Informationen für Azure AD
Es müssen bestimmte Voraussetzungen erfüllt werden, bevor eine Verbindung zu Azure AD mit PowerShell hergestellt werden kann.
### Voraussetzungen
1. Powershell Version minimum 5.1
2. MSOnline Modul
3. AzureAD Modul

**Installation:**
```sh
Install-Module -Name MSOnline
```
```sh
Install-Module -Name AzureAD
```
>Bitte dabei berücksichtigen, dass für die Installation dieser Module Administratoren Berechtigung nötig ist.
Alternativ sie können die Module nur für die aktuell angemeldete Benutzer installieren:
```sh
Install-Module -Name MSOnline -Scope CurrentUser
Install-Module -Name AzureAD -Scope CurrentUser
```
Bei Problemen bitte folgende [Artikel durchlesen.](https://blog.rmilne.ca/2020/11/10/unable-to-install-powershell-modules-unable-to-download-from-uri-error/)

**Bitte beachten:** Eine Anmeldung im Azure AD bei default muss immer erfolgen. Der Benutzer wird nach E-Mail Adresse und nach seinem Kennwort befragt.

## Übersicht der Scripte
>Bei allen Abfragen, die eine konkrete Azure App betrifft muss man für eine detaillierte Abfrage die entsprechende Berechtigungen haben. Die normale User können nur bestimmt Daten aus Azure AD auslesen. Die Daten zu der Anmeldung im Azure AD werden in einem separaten Fenster abgefragt.

| Datei | Beschreibung |
| ------ | ------ |
| 1. AzureAD.GenerateSecret.ps1 | Estellen neuer Client Secret anhand einer Application ID |
| 2. Details4AzureApps.ps1 | Abfagen aller Azure Applikationen mit Details und exportieren als JSON |
| 3. GenerateNewToken.ps1 | Erstellen ein neuer JWT Token Datei für eine bestimmte Applikaion und exportiert den Token in Datei|
| 4. GetPersonalJWT.ps1 | Erstellen Personal JWT Token und exportiert den Token in Datei |
| 5. ListAllUsersforAppRole.ps1 | Auflisten alle Users die in einer bestimmte Applikation Rolle zugeordnet ist |

### 1. AzureAD.GenerateSecret.ps1
Ziel und Beschreibung: nach gewisse Zeit wird der für die einzelne Azure Applikationen generierte Client Secret ablaufen. Mit der PS Code kann man diese Secret neu generieren / verlängern. 

##### Voraussetzung 
Eine Client Secret kann nur die Benutzer erstellen die dafür berechtigt sind. Die gewünschte Applikation ID muss zur Sicherheit abgefragt werden bevor die Code ausgeführt wird. Die Applikationen ID sind für die einzelne Umgebungen unterschiedlich. Wenn man mit QA Account in Azure anmeldet, werden die ID's zu den Applikationen Hinsicht auf QA-Umgebungen abgefragt. Beipiel für Abfrage der Details zu den Applikationen:
```sh
$Applications = Get-AzureADApplication -all $true
```


> Bei der Generieren einer Secret muss man bestimmte Details zu der Applikation kennen. In dem Beipiel nutzen wir die Applikation ID für die eindeutige Identifikation der Applikation als Parameter.

```sh
$azureApp = Get-AzureADApplication -Filter "appId eq '$ApplID'";
```
##### Parameters
Es ist möglich die Enddatum der Gültigkeit in der Code mit dem Parameter **_-EndDate_** einzugeben:
```sh
$passwordCredential = New-AzureADApplicationPasswordCredential -ObjectId $azureApp.ObjectId -CustomKeyIdentifier "Current 2021" -StartDate (Get-Date) -EndDate ((Get-Date).AddYears(1));
```

**Bitte Beachten:** die Client Secret wird nur einmal lesbar gemacht. Nach die erste Ausführung wird die Client Secret nicht mehr als String aus AzureAD auslesbar.

### 2. Details4AzureApps.ps1
Ziel und Beschreibung: mit der PS Code kann man Details über die Azure Applikationen anfragen. Die Ergebnisse werden in einer JSON Datei exportiert. 
> Mit der Beipiel Code werden alle Applikationen abgefragt, mit dem man zu tun hat.

##### Voraussetzungen
Es werden nur die Applikationen abgefragt, mit dem man im Azure AD zu der Applikation eine Assignment hat.

##### Das Output
Es wird ein JSON-Datei mit dem folgenden Inhalt generiert:
```sh
"displayname" = $AppName
"owner" = $owner_name
"applid"  = $ApplID 
"appid" = $AppID
"startdate"  = $StartDate
"enddate"  = $EndDate
"daysleft"  = $ODays
```
Die PS Code prüft auch ob die Applikation eine noch gültige Client Secret hat und schreibt in der JSON Datei die Ergebnisse **_daysleft_** zurück.

### 3. GenerateNewToken.ps1
Ziel und Beschreibung: falls nötig kann man für eine bestimmt Azure Applikation eine temporäre JWT Token generieren.

##### Voraussetzungen und Parameters
Folgende Daten muss bekannt sein bevor man ein JWT Token generiert:
> Es muss berücksichtigt werden aus welche Umgebung man die Daten abfeuern möchte!

```sh
$ClientId => Das ist die Application ID der Applikation / bzw. für Worker
$ClientSecret => Der generierte Client Secret der Applikation / Worker
$Tenant => Tenant von der APP
$AppClientId => Application ID 
```
##### Output
Nach Auführen der Code werden zwei Art von Dateien erzeugt mit folgendem Inhalt
```sh
Tokenfile = ".\jwt.txt" => JWT Token mit dem Header Bearer
TokenIo = ".\jwt.io" => nut der JWT Token
```
In dem Beipiel kann man zu dem NeoWorker (PROD) einen JWT Token generieren.

### 4. GetPersonalJWT.ps1
Ziel und Beschreibung: Mit Benutzung des Modules vom ChromeDriver kann man seine eigene JWT Token entnehmen. Die Code macht nichts anderes, als er im Hintergrund die Chrome in separaten Fenster aufruft, meldet mit der Useremail Adresse an und zieht von der Webseite den Token ab. Die PS übernimmt die E-Mail Adresse von dem angemeldeten Benutzers:
```sh
$EmailLoggedUser = ([adsi]"LDAP://$(whoami /fqdn)").mail
```

Der JWT Token wird dann in separate Datei geschrieben. Es werden auch weitere Details abgefragt und diese in separate Datei geschrieben. 
Im Hintergrund wird die folgende URL aufgerufen:
```sh
https://appurl/.auth/me
```

##### Voraussetzungen
Der Browser Chrome und auch der ChromeDriver mit der entsprechende Version muss auf dem Client vorhanden sein. Die Ressoursen (dll) kann man von der URL herunterladen: [ChromeDriver](https://chromedriver.chromium.org/downloads). Die Pfad zum Modul ist in der Code festgeschrieben und der Variable **_$WebDriverDLLPath_** muss entsprechend angepasst werden:
```sh
$WebDriverDLLPath = "$pathtoApp\Ressources\ChromeDriver\WebDriver.dll"
```
##### Outputs und Variablen
Die Ergebnisse werden in verschiedene TXT-Dateien geschrieben. Mit Hilfe der Nutzung der folgende Funktions besteht die Möglichkeit von dem generierten Token alle Details auszulesen.
```sh
JWTtokenDetails
```
Folgende Informationen werden in verschiedene Dateien gespeichert:
```sh
$Tokenfile = $pathtoApp + "\Other\UserJWTToken.txt" => In der Datei wird der JWT Token geschrieben
$UserDisplayName = $pathtoApp + "\Other\UserDisplayName.txt" => Hier wird der Name des Benutzers geschrieben
$UserRoles = $pathtoApp + "\Other\UserRoles.txt" => Es werden gleicht auch die Rollen in Datei geschrieben
$JWTValid = $pathtoApp + "\Other\PersonalJWTValid.txt" => die Gültigkeit des Tokens wird auch geschrieben (H, m, s)

```
### 5. ListAllUsersforAppRole.ps1
Ziel und Beschreibung: es besteht die Möglichkeit, dass man je nach Applikation Rollen die Benutzer abfragt. In der Beispiel wird die Applikation Rolle _XXX_ anhand seiner ObjektID im Azure AD abgefragt. Die Ergebnisse werden in einer JSON-Datei geschrieben.

##### Voraussetzungen
Die ObjektID der betr. Applikation Rolle muss bekannt sein und muss ab besten vorher abgefragt und geprüft werden. 
>In der Code findet man  die ObjektID's zu den meisten App Rollen

##### Outputs und Variablen
Folgende Informationen werden im JSON-Datei geschrieben:
```sh
"displayname" = $Displayname
"email" = $Mail
"aacount"  = $AAccount 
"phone"  = $Mobile
"landline"  = $Landline
"company"  = $Company
"country"  = $Country
"city"  = $City
"dep"  = $Dep
```
Wenn die Code auch mit weiteren/allen App Rollen erweitert wird, kann gerne das Output auch mit dem Name der AppRole erweitert werden.
```sh
"approle" = $GruppeName
```
