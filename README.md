# 🔫 qb-fleeca — Braquage Fleeca PRO (QBCore)

Script de braquage de banque Fleeca pour FiveM / QBCore : hack VarHack, fouille de tiroirs, coffre à la thermite, cooldowns et condition de policiers.

## ✨ Fonctionnalités

- 🖥️ **Hack du terminal** avec minigame **VarHack** (`ps-ui`)
- 🔥 **Coffre bonus** ouvrable à la **thermite** (minigame Thermite)
- 💰 **Fouille des tiroirs** (loot en bills marqués)
- ⏱️ **Cooldown par banque + par joueur**
- 👮 **Minimum de policiers en ligne** requis
- 🛡️ **Anti-cheat** : toute la validation est côté serveur
- 🎯 Intégration **qb-target** avec `canInteract`

## 📦 Dépendances

| Ressource | Usage |
|---|---|
| [qb-core](https://github.com/qbcore-framework/qb-core) | Framework |
| [qb-target](https://github.com/qbcore-framework/qb-target) | Interactions |
| [ps-ui](https://github.com/Project-Sloth/ps-ui) | Minigames VarHack / Thermite |
| qb-policejob | Alertes police |

## ⚙️ Installation

1. Place le dossier `qb-fleeca` dans `resources/[qb]/`
2. Ajoute dans ton `server.cfg` :

   ```
   ensure qb-fleeca
   ```

   (après `qb-core`, `qb-target` et `ps-ui`)

3. Ajoute les items dans `qb-core/shared/items.lua` :

   ```lua
   ['trojan_usb'] = { name = 'trojan_usb', label = 'USB Trojan', weight = 50, type = 'item',
       image = 'trojan_usb.png', unique = false, useable = false, shouldClose = false,
       description = 'Un outil de hacking sophistiqué' },

   ['thermite'] = { name = 'thermite', label = 'Thermite', weight = 500, type = 'item',
       image = 'thermite.png', unique = false, useable = false, shouldClose = false,
       description = 'Permet de faire fondre une serrure renforcée' },
   ```

4. Ajuste les coords des banques dans `config.lua` (`hackCoords`, `thermiteCoords`, `drawers`).

## 🎮 Déroulement du braquage

1. **[E] Hacker le terminal** (nécessite `trojan_usb`, consommé si réussi)
2. Réussir le **VarHack** puis le téléchargement (15 s)
3. **5 minutes** pour fouiller les tiroirs avant la réactivation du système
4. Optionnel : **thermite sur le coffre** pour un gros loot bonus
5. Fuis avant l'arrivée de la police 🚔

## 🔧 Configuration (`config.lua`)

| Clé | Description |
|---|---|
| `Config.MinCops` | Policiers minimum en ligne |
| `Config.Cooldown` | Cooldown par banque (minutes) |
| `Config.PlayerCooldown` | Cooldown par joueur (minutes) |
| `Config.RobberyDuration` | Durée du braquage (minutes) |
| `Config.DrawerLoot` | Loot des tiroirs |
| `Config.VaultLoot` | Loot du coffre |
| `Config.Banks` | Coords des banques Fleeca |

## 📝 Notes

- Le dispatch utilise `qb-policejob:server:policeAlert` — adapte si tu utilises `ps-dispatch` ou `codex-dispatch`.
- Le hack échoué alerte la police (événement `qb-policejob:client:policeAlert`).
