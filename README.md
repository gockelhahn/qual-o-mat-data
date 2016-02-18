# qual-o-mat-data

Dieses Repository enthält Daten, welche aus den öffentlich zugänglichen PDF-Dokumenten des [Wahl-O-Mats](https://www.wahl-o-mat.de/) der [Bundeszentrale für politische Bildung](https://www.bpb.de/politik/wahlen/wahl-o-mat/) erstellt wurden.

## Intention

Nach dem Prinzip von [Open Data](https://de.wikipedia.org/wiki/Open_Data) sollten alle öffentlichen Daten möglichst [maschinenlesbar](https://en.wikipedia.org/wiki/Machine-readable_data) zur Verfügung gestellt werden, damit man sie filtern, verknüpfen oder anderweitig verarbeiten kann.

## Kritik zur Ausgangslage

Der angesprochene Wahl-O-Mat ist eine serverseitige Webanwendung, die dem Wähler einen ersten Schritt zur Meinungsbildung über zur Wahl stehende Parteien anbietet. Allein durch diesen Fakt können folgende Dinge nicht hundertprozentig garantiert werden:
- anonyme Nutzung des Dienstes
- Nichtverwertung der Antworten (zu statistischen Zwecken)

**Hinweis:**
Bis zum Jahr 2015 stehen auch Offline-Versionen zum Download bereit (z.B. [Europawahl 2014](https://www.wahl-o-mat.de/europawahl2014/wahlomat.zip)). Nichtsdestotrotz sind die mitgelieferten Daten weder strukturiert noch vom Programmcode getrennt gehalten.

Desweiteren wird nach Beantwortung und Gewichtung aller Aussagen ein Ergebnis als Gegenüberstellung von maximal acht Parteien erlaubt. Dies ist nicht nur umständlich, sondern grenzt auch Parteien vom Meinungsbild aus, welche aufgrund dieser Restriktion von vornherein durch den Benutzer ausgeschlossen werden müssen.

**Abhilfe:**
*main_app.html*
```javascript
var CONST_PARTEIENAUSWAHL_MAX = 99;
```

## Vision

Für die Zukunft ist ein freier und offline-fähiger "Wahlomat" als [Open-Source](https://de.wikipedia.org/wiki/Open_Source)-Implementierung angedacht. Zusätzlich wäre es erstrebenswert, wenn auch andere Projekte jene Datenbasis nutzen, z.B. um eigene Front-Ends zu erstellen oder die Daten visuell aufzubereiten.

## Richtigkeit der Daten

Da das Konvertieren der PDF-Dokumente zurzeit noch nicht automatisiert ist, kann es trotz aller Vorsichtsmaßnahmen und Prüfungen zu Übertragungsfehlern kommen.

## Disclaimer

Die hier abgelegten Daten gehören weiterhin den oben verlinkten Parteien. Es wird weder das Copyright beansprucht noch eine eigene Lizenz angewendet.
