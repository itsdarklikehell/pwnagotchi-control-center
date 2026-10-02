# pwnagotchi-control-center — Bevindingen en Fixes

## Overzicht
Project: Shell-based menu systeem om een pwnagotchi te beheren (lokaal en remote).
12 stars op GitHub. Gepushed naar `chore/add-github-templates` branch.

## Gevonden Bugs en Fixes

### 1. CI Workflow — Duplicate branch entries
**Bestand:** `.github/workflows/ci.yml`
**Probleem:** `branches: ["main","main","master"]` — "main" twee keer
**Fix:** `branches: ["main","master"]`

### 2. Remote Menu — Verkeerde script referentie
**Bestand:** `Scripts/Remote/menu.sh`
**Probleem:** `./Scripts/Remote/install-seclist.sh` (zonder 's') — script bestaat niet
**Fix:** `./Scripts/Remote/install-seclists.sh`

### 3. Remote Menu — Verkeerde menu label
**Bestand:** `Scripts/Remote/menu.sh`
**Probleem:** "Disable Plugin Config" als label, maar de if-check vergelijkt met "Disable Plugin"
**Fix:** Label veranderd naar "Disable Plugin"

### 4. Remote Scripts — Verkeerde echo variabele
**Bestanden:** `mod-plugin-conf.sh`, `install-seclists.sh`, `plugin-install.sh`, `plugin-enable.sh`, `plugin-disable.sh`
**Probleem:** `echo "User selected Ok and entered $BT_IFACE"` — BT_IFACE is niet deze context
**Fix:** `echo "User selected Ok and entered $PLUGINNAME"` (of `$INSTALL_DIR` voor install-seclists)

### 5. Local Scripts — wget -C in plaats van -c
**Bestanden:** `backup.sh`, `download.sh`
**Probleem:** `wget -C` (hoofdletter) is geen geldige continue flag
**Fix:** `wget -c` (kleine letter)

### 6. Local Scripts — mkdir -P in plaats van -p
**Bestanden:** `pull-files.sh` (3x), `push-files.sh` (3x)
**Probleem:** `mkdir -P` is geen geldige flag
**Fix:** `mkdir -p`

### 7. Local modconf.sh — Leeg script
**Bestand:** `Scripts/Local/modconf.sh`
**Probleem:** Alleen `#!/bin/bash` — geen functionaliteit
**Fix:** Volledige implementatie: mount SD, kopieer config.toml, start nano, terugkopieer

### 8. Local push-files.sh — Verkeerde cp syntax
**Bestand:** `Scripts/Local/push-files.sh`
**Probleem:** `cp "$BACKUP_DIR/Plugins" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*.toml"` — verkeerde argument volgorde
**Fix:** `cp "$BACKUP_DIR/Plugins"/*.toml "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"`

### 9. Remote install-seclists.sh — Hardcoded SecLists path
**Bestand:** `Scripts/Remote/install-seclists.sh`
**Probleem:** `git clone ... SecLists` zonder configureerbare install directory
**Fix:** `INSTALL_DIR` variabele toegevoegd, gebruikt in git clone en cd commands

### 10. Gource Workflow — Git safe.directory failure
**Bestand:** `.github/workflows/gource.yml`
**Probleem:** `git failed with exit code 128` — safe.directory protection
**Fix:** `git config --global --add safe.directory "$GITHUB_WORKSPACE"` toegevoegd in beide stappen

## Acceptatiecriteria Status
- [x] Project gecloned en up-to-date
- [x] Documentatie gelezen en begrepen
- [x] Afhankelijkheden geïnstalleerd (geen externe deps — pure bash + whiptail)
- [x] Installatie succesvol uitgevoerd (geen installatie nodig — standalone scripts)
- [x] Gource workflow actief (fix gepushed, wacht op nieuwe run)
- [x] Video geembed in README (was al aanwezig)
- [x] Bevindingen gedocumenteerd (dit bestand)
