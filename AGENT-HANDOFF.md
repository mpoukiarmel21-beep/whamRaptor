# AGENT-HANDOFF — WhamRaptor

## État actuel
✅ **CRASH FIX LIVRÉ — build-18** (243 822 017 o) : corrige crash à l'ouverture signalé par l'utilisateur (« Ça crache de l'ouverture »).
- Root cause : `WRHomeRedirect` retournait `[NSString UTF8String]` dangling dans `getenv("HOME")` + `WRPaths.rootDir` appelait `NSHomeDirectory` hooké → récursion constructor + `stat`/`access` allouaient `NSString` trop tôt + tous les swizzles faisaient avant UIKit ready.
- Fix : `getenv` → buf `_Thread_local` stable, `realHomePath` capturé avant hook, `WRPaths` → `WRHomeRedirect realHomePath`, `stat`/`access` → pure C `strstr`, `Bootstrap` → `WR_SafeInstall` + hooks non-critiques différés `dispatch_async main`.
- IPA : IG 449.0.0 clean + WhamRaptor @rpath, 243 MB. Repo public master `7cf995e`.

Lien IPA corrigé : https://github.com/mpoukiarmel21-beep/whamRaptor/releases/download/build-18/WhamRaptor.ipa
Release : https://github.com/mpoukiarmel21-beep/whamRaptor/releases/tag/build-18

Builds précédents : build-16 (même taille, crashé à l'open), build-15, base-449 (3×90MB parts).

## En cours
Libre. (Fix crash livré 2026-10-12 — runs 38299034506 + 38299081149 SUCCESS.)

## Prochaine étape
Tester build-18 via Sideloadly. Si toujours crash : récupérer crash log iOS (Réglages > Confidentialité > Analyse) + `WhamRaptor/Documents/WhamRaptor/diagnostics.log`.
Pour rebuild : `gh workflow run build.yml --repo mpoukiarmel21-beep/whamRaptor --ref master -f ipa_url="parts:mpoukiarmel21-beep/whamRaptor/base-449/base449.part"`

## Blocages / risques
- Base IG 449 vieillira — re-découper nouvelle IPA si maj majeure.
- Proxy IP vs ville hors scope.

## Journal
- 2026-10-12 — **FIX crash open build-18** : 5 fichiers (WRHomeRedirect, WRPaths, WRHardening, Bootstrap) — voir État actuel. Runs SUCCESS 2m42s/3m01s, IPA 243M publié.
- 2026-10-12 — Livraison build-16 (233M) — crash constaté.
- 2026-10-12 — From scratch WhamRaptor : chip-aware A13..A19/iOS 26/27, MapKit monde, anti-spinner, isolation HOME/keychain, UI flottante.
