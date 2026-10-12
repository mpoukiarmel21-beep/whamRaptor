# AGENT-HANDOFF — WhamRaptor

## État actuel
✅ **REFONTE LIVRÉE — build-22** (243 835 898 o, 233 MB, run 38305190369 SUCCESS 3m10s).
IPA complet IG 449.0.0 + WhamRaptor corrigé — prêt Sideloadly.

**Lien IPA :** https://github.com/mpoukiarmel21-beep/whamRaptor/releases/download/build-22/WhamRaptor.ipa
Release : https://github.com/mpoukiarmel21-beep/whamRaptor/releases/tag/build-22

Corrections livrées (retour utilisateur) :
1) **Compte fantôme au 1er lancement** — isolation renforcée : `WRHomeRedirect` (getenv HOME buf stable) + `WRFileHook` (fopen) installés AVANT tout, `WRKeychainHook` préfixe `wr.<uuid>:` dès le constructor (host nu = Keychain nu → écran login), `WRPaths` → `realHomePath` (plus d'appel NSHomeDirectory hooké), fichier SQLite/prefs redirigé vers `Documents/WhamRaptor/containers/<uuid>/Home/`.
2) **Bannière bêta TestFlight** — `Info.plist` `FBBuildBranchName` `dev` → `stable` à l'injection + suppression `BetaReportsActive` / `ITSAppUsesNonExemptEncryption`.
3) **Design nul / écritures illisibles** — `WRTheme` refondu premium dark : bg #0B0B10, card #1A1A24, texte blanc, subtext #B8B8C8 lisible, border #2A2A36, accent violet gradient, typo semibold/bold claire.
4) **Carte couleur bizarre en haut + search** — `WRMapPickerVC` refait en AutoLayout safeArea : map plein écran, searchWrap en carte sombre avec border, textField blanc sur card, bottomCard avec info+sub+confirm, nav bar sombre lisible.
5) **Arrière-plan bloque clics** — `WROverlayWindow` (hitTest passthrough : seule la zone du bouton 50×50 intercepte, reste = pass-through), `windowLevel = UIWindowLevelAlert - 1`, pas `+10`. Panel/list/create refaits en InsetGrouped + header card.
6) **Toutes refs Ryuk** — déjà nettoyées (RyukGram.bundle/FLEX/CydiaSubstrate supprimés, LC_LOAD_WEAK_DYLIB via LIEF).

Repo : https://github.com/mpoukiarmel21-beep/whamRaptor — master ca4da78→build-22. Base : `base-449` (3×90MB parts RyukGram-No-Plugins_1.4.5_IG449.0.0).

## En cours
Libre. (Refonte UI + isolation + bêta fix pushée 2026-10-12.)

## Prochaine étape
Tester build-22 via Sideloadly :
- Désinstaller build-16/18, installer build-22, vérifier : pas de compte au 1er lancement, pas de bannière bêta, design lisible, carte correcte, bouton ◈ ne bloque plus.
- Si host a déjà un compte : supprimer et réinstaller OU switcher sur un container vide → le host doit rester propre.
Pour rebuild : `gh workflow run build.yml --repo mpoukiarmel21-beep/whamRaptor --ref master -f ipa_url="parts:mpoukiarmel21-beep/whamRaptor/base-449/base449.part"`

## Blocages / risques
- Host déjà connecté avant install WhamRaptor : Keychain existant déjà hors préfixe → reste visible jusqu'à déconnexion manuelle + réinstall propre (comportement attendu).
- IP vs ville hors scope.

## Journal
- 2026-10-12 — **REFONTE build-22** : 15 fichiers (WRTheme/WROverlayWindow/WRFloatingButton/WRPanelVC/WRCreateVC/WRMapPickerVC/WRListPickerVC/WRFileHook/WRKeychainHook/Bootstrap/WRHomeRedirect + CI Info.plist). Fix isolation + bêta + UI premium + overlay passthrough + carte safeArea. Run 38305190369 SUCCESS, IPA 243M publié.
- 2026-10-12 — Fix crash open build-18 (HOME getenv buf, realHome, pure-C stat/access, deferred hooks).
- 2026-10-12 — From scratch WhamRaptor build-16 (tweak compile, IPA 233M).
