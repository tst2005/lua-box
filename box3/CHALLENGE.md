
# compat

* que l'outil fonctionne sur tous les interpreteurs lua (lua 5.1/5.2/5.3, luajit 2.0/2.1, ...)
  * il faut une couche de compat pour construire la suite sur une seule API/comportement.
  * [x] solution: uniformapi.lua

# class-instance-env

* utiliser un systeme de class + instance pour préparer une sandbox et pouvoir en instancier plusieurs.
  * il faut pouvoir convertir une instance en environnement
  * [x] solution: mini/proxy/ro2rw-shadowself*.lua

# shadowself

* ne pas exposer l'instance via les proxy (particulierement dans les reponses)
  * [x] solution: mkproxy2* dans mini/proxy/mkproxies.lua

# stable-proxy

* quand on génère des proxy on s'attend a avoir la meme fonction lors d'un prochain appel.
  * il faut reussir a garder en memoire les proxies générés, sans obtenir de memory leak.
  * [x] solution: mini/proxy/ro2rw-*.lua (voir __index et __newindex)

# private-vs-public methods

* pour implementer/emuler on a parfois besoin de fonction interne qui ne seront pas exposée/accessible dans l'environnement final
  * il faut un moyen d'exporter dans l'environnement final seulement les methodes publiques
  * [x] solution: mkproxy*prefix dans mini/proxy/ro2rw-shadowself*.lua + design de la class box en utilisant un prefix _pub_ pour les methodes a rendre accessible depuis l'env via proxy
    * limitation: only support string key request; non string field must be setup in the writable space equal to a client value set action

# shadowregistry

* certaines fonctions standard de l'interpreteur lua ont besoin et accès a d'autres fonctions et le font via un registre interne (exemple pairs() accede a next() meme si _G.next = nil)
  * il faut un accès a un registre caché (mais qui utilise des fonctions coté env (les "proxy" en cache ...)
  * [x] solution: mini/proxy/ro2rw-*shadowregistry*.lua avec une séparation de la gestion de la mise a jour et du cache de proxy des methodes de l'instance

# less-cache/hot-switch

* permettre que si on change des fonctions bas niveau ca se répercute sur toutes les instances en bout de chaine
  * il faut eviter de tout mettre en cache dans des variables locales
  * [ ] solution: design sans cache local et des modules avec passage de l'env global personnalisable ... WIP

# metaproxy all

* un proxy doit faire suivre aussi toutes les operations utilisant des meta (pour les operateurs, etc.)
  * [ ] solution: mini/proxy/ro2rw-*metaproxy*.lua ... WIP

# metaproxy-for-pairs

* particulierement difficile, car ca touche aux iterateurs et qu'il faut naviguer entre l'instance à la creation puis l'iterateur généré devra supporter de recevoir n'importe quelle table et savoir revenir sur l'instance si on lui donne l'env global ...
  * [ ] solution: mini/proxy/ro2rw-*metaproxy*.lua ... WIP

# creator-helpers

* utiliser une base commune simple et construire sa box en piochant dans de multiples implementations equivalente disponibles (exemple exposer les fonctions de FS réelles, utiliser des fonctions de FS virtuel, ...)
  * il faut des outils pour remplir un classe en ajoutant des methodes (ce qui est habituellement fait par le dev a froid, pas au runtime)
  * [ ] solution: boxcreator/boxctl ? ... WIP

# perfect-fake

* pouvoir feinter de ne pas etre là.
  * [ ] solution: ... WIP

