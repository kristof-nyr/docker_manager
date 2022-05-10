#!/bin/bash
#Készítette: Nyári Kristóf
#Neptun: BFARTM

export readonly DOCKER_USERNAME=$(head -1 ./credentials.md | base64 -d)
export readonly DOCKER_PASSWORD=$(tail -1 ./credentials.md | base64 -d)
export readonly TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USERNAME}'", "password": "'${DOCKER_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

#Echo color variables
RED='\033[0;31m'
NC='\033[0m' # No Color

#Ez a metódus ellenőrzi, hogy a script futásához szükséges csomagok telepítve vannak-e
#Pirossal kiírja ha nem, valamint a telepítés menetét
#(echo végén a ${NC} visszaváltoztatja a temrinál output színét defaultra)
checkPackages() {
    if [[ ! -f /usr/bin/curl ]];then
        echo -e "\n${RED}curl not found"
        echo -e "Run: zypper install curl | rpm -i curl${NC}"
        exit 1
    fi
    if [[ ! -f /usr/bin/docker ]];then
        echo -e "\n${RED}docker not found"
        echo -e "Run: zypper install docker | rpm -i docker${NC}"
        exit 1
    fi
    if [[ ! -f /usr/bin/jq ]];then
        echo -e "\n${RED}jq not found"
        echo -e "Run: zypper install jq | rpm -i jq${NC}"
        exit 1
    fi
}


#Help function, ami kiírja a script lehetséges használati módjait
displayHelp() {
    echo -e "Wrong number of parameters!\nUsage:";
    echo -e "\n To list all repos in given namespace:\n ${0##*/} <namespace>"
    echo -e "\n To list tags of the given repository:\n ${0##*/} <namespace> <repository>"
    echo -e "\n To pull a certain docker image:\n ${0##*/} <namespace> <repository> <tag>"
}

displayHeader() {
    echo -e "=====================================================\n==================BFARTM HOMEWORK====================\n====================================================="
}

#Kilistázza az adott namespace-n belüli repository-k nevét
getRepositories() {
    namespace=$1
    curl -s -H "Authorization: JWT ${TOKEN}" "https://hub.docker.com/v2/repositories/${namespace}/?page_size=25" | jq -r '.results|.[]|.name'

}

#Kilistázza a megadott namespace:repository-ben elérhető image-k adatait és tag-jeit => ebből lehet megtudni mit szeretnénk lehúzni
getSummary() {
    namespace=$1
    repository=$2
    curl -s -H "Authorization: JWT ${TOKEN}" "https://hub.docker.com/v2/repositories/${namespace}/${repository}/tags/?page_size=25" | jq -r '.results|.[]| {name, images}'
}

#Lehúzza a specifikált docker image-t
pullDockerImage() {
    namespace=$1
    repository=$2
    tag=$3
    docker pull "${namespace}"/"${repository}":"${tag}"
}


main() {
    displayHeader
    checkPackages
    case "$#" in
        1)
            getRepositories "$1"
            return
        ;;
        2)
            getSummary "$1" "$2"
            return
        ;;
        3)
            pullDockerImage "$1" "$2" "$3"
            return
        ;;
        *)
            displayHelp
            exit 1;
        ;;
    esac
}


main "$@"