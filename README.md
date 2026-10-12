# WhamRaptor

Containers isolés type Crane/Ghost pour Instagram — sideload (Sideloadly).

- **Bouton flottant** translucide à gauche, draggable, tap → menu containers.
- **Nombre illimité** de containers, chacun = stockage isolé + footprint appareil unique (chip-aware, iOS 26/27) + suppression nuke sans impacter l'app principale.
- **Fake localisation carte monde** : MapKit zoomable + pins + recherche + liste filtrante. Choix ville → heure/timezone + langue auto par container.
- **Anti-detection** : DeviceCheck/AppAttest bloqués, jailbreak checks bypass, keychain/prefs/app-group/pasteboard isolés, location pass-through quand aucune ville (fix spinner signup).

## Build

CI `macos-14` — Theos + `insert_dylib --all-yes < /dev/null` + clean IPA via LIEF si besoin.

- Workflow: `.github/workflows/build.yml`
- Déclenchement: `gh workflow run build.yml -f ipa_url="https://.../base.ipa"` ou `parts:owner/repo/tag/prefix`
- Sans `ipa_url`, publie uniquement le `.deb`.

## Install

Télécharger `WhamRaptor.ipa` depuis Releases, installer via Sideloadly (ad-hoc signé, Sideloadly re-signe).

## Dev

```
make clean && make -j8 FINALPACKAGE=1
```

Entrée: `Tweak/Bootstrap.m` → `WRLaunchGuard` → hooks → `WRFloatingButton`.

## Structure

- `Tweak/Core` — WRPaths/Container/Store/HomeRedirect/AppRelaunch
- `Tweak/Spoof` — DeviceIdentity(chip-aware)/DeviceSpoof/Locale/Timezone/Location/Hardening/Keychain/Prefs/AppGroup/Pasteboard
- `Tweak/UI` — FloatingButton/Panel/Create/MapPicker(ListPicker)/Theme/Glass/L10n/ActionSheet
- `Tweak/Util` — LaunchGuard/Diagnostics
- `vendor/fishhook` — vendored
