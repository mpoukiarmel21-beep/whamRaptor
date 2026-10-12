# AGENT-HANDOFF — WhamRaptor

## État actuel
From scratch (zéro copie raptor). IPA autorisé: `RyukGram-No-Plugins_1.4.5_IG449.0.0.ipa` (IG 449.0.0, 269.5 MB). Base nettoyée prévue en CI (LIEF). Scaffolding complet: Makefile rootless, control, plist, entitlements, vendor fishhook, Bootstrap + Core/Spoof/UI/Util (27 fichiers). CI `build.yml` prêt (macos-14, THEOS, insert_dylib --all-yes < /dev/null, LIEF clean, codesign ad-hoc, release build-N).

## En cours
2026-10-12 — OpenCode — scaffolding + impl complète en cours, avant premier push.

## Prochaine étape
1. `git init` + push public `WhamRaptor` (repo à créer)
2. `gh workflow run build.yml` avec ipa_url RyukGram (ou parts si besoin)
3. Tester `WhamRaptor.ipa` via Sideloadly — vérifier bouton flottant, création container, carte monde, timezone/langue, signup sans spinner

## Blocages / risques
- iOS 27 pool prospectif (A19) — noms machines `iPhone18,x` présumés, ajuster si Apple publie autres IDs.
- IP vs ville non spoofé (hors scope, proxy externe).
- RyukGram déjà sideload IPA (pas besoin base App Store) — clean via LIEF en CI seulement si base fournie.

## Journal
- 2026-10-12 — From scratch WhamRaptor: chip-aware identity (A13..A19, propose même famille que host ex: A13→11/Pro/Max), iOS 26/27, carte monde MapKit moderne (pins + tap + callout + search + liste), WRLocationSpoof fix anti-spinner (gInDelivery @try/@finally, sync main, fallback didFail, hooks minimaux, isActive=hasLocation), isolation HOME/keychain/pasteboard/appGroup/prefs, UI flottante translucide 0.55 + panel/containers + create + mappicker, LaunchGuard safe-mode, Diagnostics, build.yml robuste.
