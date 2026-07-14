# Contributing to Proxi

## Convenzione dei commit (Conventional Commits)

Tutti i commit devono seguire il formato:

```
<type>(<scope opzionale>): <descrizione breve al presente>

[corpo opzionale con dettagli]

[footer opzionale, es. BREAKING CHANGE: ..., Closes #12]
```

### Tipi ammessi

| Tipo       | Uso                                                              |
|------------|-------------------------------------------------------------------|
| `feat`     | Nuova funzionalità utente-visibile                                |
| `fix`      | Correzione di un bug                                              |
| `chore`    | Manutenzione (dipendenze, config, build) senza impatto sul codice utente |
| `docs`     | Solo documentazione (README, docs/*)                              |
| `style`    | Formattazione, whitespace, lint — nessun cambio di logica          |
| `refactor` | Ristrutturazione del codice senza cambiare comportamento           |
| `perf`     | Miglioramento delle prestazioni                                   |
| `test`     | Aggiunta o correzione di test                                      |
| `ci`       | Modifiche alla pipeline CI/CD (`.github/workflows/*`)              |
| `build`    | Modifiche al sistema di build o dipendenze esterne                 |
| `revert`   | Revert di un commit precedente                                    |

### Esempi

```
feat(map): aggiungi visualizzazione utenti vicini sulla mappa
fix(auth): correggi crash al login con token scaduto
chore: aggiorna dipendenze a Flutter 3.44
docs: aggiungi guida al branding e app icon
ci: aggiungi workflow di release per build APK firmata
```

### Scope

Lo scope (tra parentesi) è opzionale e dovrebbe riferirsi alla feature
toccata: `auth`, `map`, `chat`, `profile`, `proximity`, `core`, `ci`.

### Branching

- `main`: branch stabile, sempre deployabile.
- `feature/<nome>`: nuove funzionalità, mergiate in `main` via PR.
- `release`: branch da cui la pipeline CI/CD compila la APK di release
  (vedi `.github/workflows/release.yml`).
- Tag `vX.Y.Z` (SemVer): ogni tag crea automaticamente una GitHub Release
  con l'APK allegato.
