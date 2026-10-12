# AGENT-HANDOFF — WhamRaptor

## État actuel
✅ **LIVRÉ — build-16** (243 820 362 o, 243 MB) : IPA Instagram complet avec WhamRaptor injecté, prêt Sideloadly.
- Base : `RyukGram-No-Plugins_1.4.5_IG449.0.0.ipa` (IG 449.0.0, 269.5 MB, SHA256 6469efa1...) découpée en `base449.part00..02` → release `base-449`.
- Dylib : `WhamRaptor.dylib` compilé sur `macos-14` (Theos, `ldid`, `insert_dylib --all-yes --weak --inplace @rpath/WhamRaptor.dylib < /dev/null`), `otool` vérifié, `codesign -`.
- Repo public : https://github.com/mpoukiarmel21-beep/whamRaptor (master, 7fed99c..9621078).

Lien IPA : https://github.com/mpoukiarmel21-beep/whamRaptor/releases/download/build-16/WhamRaptor.ipa
Fallback build-15 identique : https://github.com/mpoukiarmel21-beep/whamRaptor/releases/download/build-15/WhamRaptor.ipa
Release : https://github.com/mpoukiarmel21-beep/whamRaptor/releases/tag/build-16

Fonctionnel : bouton flottant ◈ translucide gauche (draggable, alpha 0.55→0.25), panel containers (créer/renommer/supprimer/📍), MapKit carte monde moderne (pins, tap, zoom, search, liste filtrante), stockage isolé illimité par container (`Documents/WhamRaptor/containers/<uuid>/Home`), footprint chip-aware (A13→A19 Pro, iOS 26/27, host A13 → famille 11/Pro/Max proposée), keychain/prefs/appGroup/pasteboard isolés, anti-detection (DeviceCheck/AppAttest/jailbreak), fix spinner signup (gInDelivery + sync main + fallback didFail + isActive=hasLocation).

## En cours
Libre. (Dernière session : OpenCode, 2026-10-12, build-16 livré.)

## Prochaine étape
Aucune — IPA testable. Pour reconstruire :
`gh workflow run build.yml --repo mpoukiarmel21-beep/whamRaptor --ref master -f ipa_url="parts:mpoukiarmel21-beep/whamRaptor/base-449/base449.part"`
→ nouveau `build-<run_number>/WhamRaptor.ipa`.
Pour mettre à jour WhamRaptor : éditer Tweak/** → `git push` → CI build dylib + réinjecte automatiquement si base-449 présente.

## Blocages / risques
- Base RyukGram déjà sideload (IG 449.0.0) — maj IG 450+ = re-découper nouvelle base.
- IP vs ville non spoofé (proxy externe à l'utilisateur).
- LIEF laisse `LC_LOAD_WEAK_DYLIB @rpath/RyukGram` faible résiduelle (fichiers déjà supprimés) — ignorée à l'exécution, warning seulement.

## Journal
- 2026-10-12 — **LIVRAISON build-16** (run 38294222650, SUCCESS 3m32s) + push build auto 38294211653 : IPA 233M WhamRaptor injecté via parts base-449. Correction LIEF `DylibCommand.name` (path→name) puis `still weak` toléré (fichiers rm déjà). Workflow unique `Setup Theos → Build dylib → Download base IPA (parts) → Clean+Inject → Upload → Release`.
- 2026-10-12 — Build CI réparé (7 correctifs : nullability, Method import, WRDeviceIdentity forward, unused var, rename→wr_rename, ldid, make flags, lief --break-system-packages). Dylib compile OK, IPA packaging finalisé.
- 2026-10-12 — From scratch WhamRaptor (0 copie raptor) : chip-aware A13..A19/iOS 26/27, MapKit monde, WRLocationSpoof anti-spinner, isolation HOME/keychain/pasteboard/appGroup/prefs, UI flottante + panel, LaunchGuard safe-mode. Base RyukGram 449 découpée 3×90MB, release base-449 créée.
