# Docker image kezelő script
### Készítette: Nyári Kristóf, BFARTM
---
## Dokumentáció:
Ez a script paraméterezettségétől függően eltérő információkat ad vissza docker image-kről
> A script futtatásához szükséges a `docker`, `curl` és a `jq` package

> Telepítés: OpenSUSE: `zypper install docker` | `zypper install curl` | `zypper install jq`

> RedHat: `rpm -i docker` | `rpm -i curl` | `rpm -i jq`


---
A script indítása előtt a user-t hozzá kell adni a docker csoporthoz
```bash
sudo gpasswd -a `(whoami)` docker
sudo systemctl restart docker
```
A script futtatása
```
chmod u+x ./docker_manager.sh

To list all repos in given namespace
./docker_manager.sh <namespace>

To list tags of the given repository
./docker_manager.sh <namespace> <repository>

To pull a certain docker image
./docker_manager.sh <namespace> <repository> <tag>
```