# SMKITS5 / Dokumentation / Variationen nach Testprotokoll
| Schlüssel/Passwort | Einbettungsdaten | nicht-unterstützte Tools |
| :---: | :---: | --- |
| kein Schlüssel | kurze Einbettung | jphide, steghide |
| kein Schlüssel | mittellange Einbettung | jphide, steghide |
| kein Schlüssel | lange Einbettung | jphide, steghide |
| kein Schlüssel | Einbettung mit geringer Entropie | jphide, steghide |
| kein Schlüssel | binäre Einbettung | jphide, steghide, f5 |
| kurzer Schlüssel | kurze Einbettung | jsteg |
| kurzer Schlüssel | mittellange Einbettung | jsteg |
| kurzer Schlüssel | lange Einbettung | jsteg |
| kurzer Schlüssel | Einbettung mit geringer Entropie | jsteg |
| kurzer Schlüssel | binäre Einbettung | jsteg, f5 |
| langer Schlüssel | kurze Einbettung | jsteg |
| langer Schlüssel | mittellange Einbettung | jsteg |
| langer Schlüssel | lange Einbettung | jsteg |
| langer Schlüssel | Einbettung mit geringer Entropie | jsteg |
| langer Schlüssel | binäre Einbettung | jsteg, f5 |
## Anmerkungen
- **jphide**: benötigt zwangsweise eine Schlüssel zur Einbettung, kein Schlüssel wird nicht unterstützt
  - `2 Schlüsselvariationen ⋅ 5 Einbettungen = 10 Stego-Einbettungen` nach Testprotokoll
- **jsteg**: unterstützt generell keine Einbettungsschlüssel
  - `1 Schlüsselvariation ⋅ 5 Einbettungen = 5 Stego-Einbettungen` nach Testprotokoll
- **outguess**:
  - `3 Schlüsselvariationen ⋅ 5 Einbettungen = 15 Stego-Einbettungen` nach Testprotokoll
- **outguess-0.13**:
  - `3 Schlüsselvariationen ⋅ 5 Einbettungen = 15 Stego-Einbettungen` nach Testprotokoll
- **steghide**: benötigt zwangsweise eine Schlüssel zur Einbettung, kein Schlüssel wird nicht unterstützt
  - `2 Schlüsselvariationen ⋅ 5 Einbettungen = 10 Stego-Einbettungen` nach Testprotokoll
- **f5**: Binärdaten werden nicht unterstützt, da die Einbettungsdaten als Parameter übergeben werden und Steuerzeichen dabei falsch interpretiert werden können, was zu falschem Auslesen führt
  - `3 Schlüsselvariationen ⋅ 4 Einbettungen = 12 Stego-Einbettungen` nach Testprotokoll
- das bedeutet in der Summe `67 Stego-Einbettungen` pro Cover-Bild
- **kurzer Schlüssel**: `4 Bytes`, langer Schlüssel: `50 Bytes`
- **kurze Einbettung**: `67 Bytes`, mittellange Einbettung: `1.53 KB`, lange Einbettung: `17.5 KB`, Einbettung mit geringer Entropie: `16 KB`, binäre Einbettung: `16.8 KB`
