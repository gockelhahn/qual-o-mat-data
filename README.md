# qual-o-mat-data

Dieses Repository enthält Daten, welche aus den öffentlich zugänglichen Offline-Versionen und PDF-Dokumenten des [Wahl-O-Mats](https://www.wahl-o-mat.de/) der [Bundeszentrale für politische Bildung](https://www.bpb.de/politik/wahlen/wahl-o-mat/) erstellt wurden.

## Intention

Nach dem Prinzip von [Open Data](https://de.wikipedia.org/wiki/Open_Data) sollten alle öffentlichen Daten möglichst [maschinenlesbar](https://en.wikipedia.org/wiki/Machine-readable_data) zur Verfügung gestellt werden, damit man sie filtern, verknüpfen oder anderweitig verarbeiten kann.

## Kritik zur Ausgangslage

Der angesprochene Wahl-O-Mat ist eine serverseitige Webanwendung, die dem Wähler einen ersten Schritt zur Meinungsbildung über zur Wahl stehende Parteien anbietet. Allein durch diesen Fakt können folgende Dinge nicht hundertprozentig garantiert werden:
- anonyme Nutzung des Dienstes
- Nichtverwertung der vom Benutzer gegebenen Antworten (z.B zu statistischen Zwecken)

**Hinweis:**
Leider stehen nur bis zum Jahr 2015 Offline-Versionen zum Download bereit (z.B. [Europawahl 2014](https://www.wahl-o-mat.de/europawahl2014/wahlomat.zip)). Nichtsdestotrotz sind die mitgelieferten Daten weder strukturiert noch so aufbereitet, dass man sie ohne Anpassungen für andere Projekte wiederverwenden könnte.

Des Weiteren wird nach Beantwortung und Gewichtung aller Aussagen ein Ergebnis als Gegenüberstellung von maximal acht Parteien erlaubt. Dies ist nicht nur umständlich, sondern grenzt auch Parteien vom Meinungsbild aus, welche aufgrund dieser Restriktion von vornherein durch den Benutzer ausgeschlossen werden müssen.

**Abhilfe** (nur in der Offline-Version möglich): folgende Variable in der Datei *main_app.html* anpassen.
```javascript
var CONST_PARTEIENAUSWAHL_MAX = 99;
```

## Vision

Für den Moment wurde bereits ein schlanker, clientseitiger und offline-fähiger ["Qual-O-Mat"](https://github.com/gockelhahn/qual-o-mat-kiss) als [Open-Source Software](https://de.wikipedia.org/wiki/Open_Source) veröffentlicht. Für die Zukunft wäre es jedoch erstrebenswert, wenn auch andere Projekte diese Datenbasis für z.B. folgende Ideen nutzen würden:
- Welche Parteien teilen die gleiche Meinung zu bestimmten Themen?
- Wo findet ein Meinungswechsel einer Partei von Wahl zur Wahl statt?
- Grafische und statistische Aufbereitung der Daten
- ...

## Richtigkeit der Daten

Da das Konvertieren der PDF-Dokumente nur für Daten bis zum Jahr 2015 automatisiert werden konnte, kann es trotz aller Vorsichtsmaßnahmen und Prüfungen zu Übertragungsfehlern kommen.

## Disclaimer

Die hier abgelegten Daten gehören weiterhin den oben verlinkten Parteien. Es wird weder das Copyright beansprucht noch eine eigene Lizenz angewendet.
