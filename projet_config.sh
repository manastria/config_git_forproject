#!/bin/bash

_DEBUG="off"

DEBUG()
{
	[ "$_DEBUG" == "on" ] &&  $@
}

# Colors
declare -r ESC_SEQ="\x1b["
declare -r COL_RESET=$ESC_SEQ"39;49;00m"
declare -r COL_RED=$ESC_SEQ"31;01m"
declare -r COL_GREEN=$ESC_SEQ"32;01m"
declare -r COL_YELLOW=$ESC_SEQ"33;01m"
declare -r COL_BLUE=$ESC_SEQ"34;01m"
declare -r COL_MAGENTA=$ESC_SEQ"35;01m"
declare -r COL_CYAN=$ESC_SEQ"36;01m" 

# Retourne 0 si egale, 1 si sup, 2 si inf
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}



SOURCE="${BASH_SOURCE[0]}"
SOURCEDIR="$(cd -P "$(dirname "$SOURCE")/.." && pwd)"
INSTALLDIR=${1:-$HOME}

GIT_VERSION=$(git --version | awk '{print $3}')

DEBUG echo "SOURCE : ${SOURCE}"
DEBUG echo "SOURCEDIR : ${SOURCEDIR}"
DEBUG echo "INSTALLDIR : ${INSTALLDIR}"

vercomp 2.6.0 ${GIT_VERSION}
res=$?
if [ $res -eq 2 ]
then
	GIT_VER_260=true
	DEBUG echo "GIT_VER_260" 
fi

vercomp 1.8.0 ${GIT_VERSION}
res=$?
if [ $res -eq 2 ]
then
	GIT_VER_180=true
	DEBUG echo "GIT_VER_180" 1>&2
fi

printf "Rep install : %s\n" $INSTALLDIR
printf "Rep source  : %s\n" $SOURCEDIR

if [ "$1" == "-h" ] || [ "$1" == "-?" ] || [ "$1" == "--help" ]; then
    echo "$0 <dotfiles install dir>"
    echo "Existing dotfiles will be moved to <filename>.old"
    exit
fi

echo -e "\n${COL_BLUE}Local author${COL_RESET}"
echo -e "${COL_BLUE}============${COL_RESET}"

echo "User : " $(git config user.name)
echo "Mail : " $(git config user.email)

echo -en "\nDo you want config author ? [N/y]"
read -n 1 config_author

if [ "$config_author" == "Y" ] || [ "$config_author" == "y" ]; then
    echo -e "\nGit config settings"
    echo -n "Name: "
    read git_name
    echo -ne "\nEmail: "
    read git_email

    #cp $PWD/.gitconfig $INSTALLDIR/.gitconfig
    #sed -i "s/%%GITNAME%%/$git_name/" $INSTALLDIR/.gitconfig
    #sed -i "s/%%GITEMAIL%%/$git_email/" $INSTALLDIR/.gitconfig
	git config user.name "${git_name}"
	git config user.email "${git_email}"
fi



echo -e "\n\n${COL_BLUE}Global author${COL_RESET}"
echo -e "${COL_BLUE}=============${COL_RESET}"

echo "User : " $(git config --global user.name)
echo "Mail : " $(git config --global user.email)

echo -en "\nDo you want config author ? [N/y]"
read -n 1 config_author

if [ "$config_author" == "Y" ] || [ "$config_author" == "y" ]; then
    echo -e "\nGit config settings"
    echo -n "Name: "
    read git_name
    echo -ne "\nEmail: "
    read git_email

	git config --global user.name "${git_name}"
	git config --global user.email "${git_email}"
fi




echo -en "\nDo you want config alias ? [N/y]"
read -n 1 config_alias

if [ "$config_alias" == "Y" ] || [ "$config_alias" == "y" ]; then
    git config --global alias.auth 'shortlog -sne --all'
    git config --global alias.a  'add'
    git config --global alias.br 'branch'
    git config --global alias.ci 'commit'
    git config --global alias.cl 'clone'
    git config --global alias.co 'checkout'
    git config --global alias.cp 'cherry-pick'
    git config --global alias.d  'diff'
    git config --global alias.dc 'diff --cached'
    git config --global alias.diff 'diff --word-diff'
    git config --global alias.r  'reset'
    git config --global alias.st 'status'
    git config --global alias.start '!git init && git commit --allow-empty -m "Initial commit"'
    git config --global alias.unstage 'reset HEAD --'
fi

echo -en "\nDo you want config pager ? [N/y]"
read -n 1 config_pager

if [ "$config_pager" == "Y" ] || [ "$config_pager" == "y" ]; then
    git config --global --replace-all core.pager "\"$(which less)\" -FRXKS"
fi

echo -en "\nDo you want install hist ? [N/y]"
read -n 1 config_hist

if [ "$config_hist" == "Y" ] || [ "$config_hist" == "y" ]; then
    if [ -v GIT_VER_260 ]
    then
        git config --global alias.hist "log --graph --decorate --format=format:'%C(red)%h%C(reset) | %C(green)%ad%C(reset) | %C(magenta)%d%C(reset) %C(reset)%s %C(blue)[%aN]%C(reset)' --date=format:'%Y-%m-%d %H:%M:%S'"
    else
        git config --global alias.hist "log --graph --decorate --format=format:'%C(red)%h%C(reset) | %C(green)%ad%C(reset) | %C(magenta)%d%C(reset) %C(reset)%s %C(blue)[%aN]%C(reset)' --date=iso"
    fi
fi

# printf "\n"


echo -en "\nDo you want use notepad++ ? [N/y]"
read -n 1 config_nppp

if [ "$config_nppp" == "Y" ] || [ "$config_nppp" == "y" ]; then
    if [ -e 'c:\Program Files (x86)\Notepad++\notepad++.exe' ]; then
        echo "Editor : notepad++"
        if  [ -z "$CYGWIN" ]; then
            git config --global core.editor "'c:\Program Files (x86)\Notepad++\notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
        else
            git config --global core.editor "~/configunix_gitconfig/install/bin/npp.sh"
        fi
    else
        echo "Editor : vim"
        git config --global core.editor "\"$(which vim)\""
    fi
fi


echo -en "\nDo you config mergetools ? [N/y]"
read -n 1 config_mergetool

if [ "$config_mergetool" == "Y" ] || [ "$config_mergetool" == "y" ]; then
    echo "1. Télécharger le fichier https://iutamiens.sharepoint.com/sites/UtilisationGit/_layouts/15/guestaccess.aspx?guestaccesstoken=XxfDxy99Tl3CFEOiMyJ%2fY8VvXT3%2fGTQx724cKptanEQ%3d&docid=2_039f9732621d74e8783e8f51476ab02b6&rev=1"
    echo "2. Décompresser le fichier sur une clé USB."
    echo "3. Indiquer ci-dessous le répertoire contenant le fichier décompressé : "
    echo "    - Meld/Meld.exe"
    echo "    - KDiff3/kdiff3.exe"
    echo "    - Perforce/p4merge.exe"
    
    
    read -re path_mt
    path_mt=$(echo "/$path_mt" | sed -e 's/\\/\//g' -e 's/://')


    git config --global --remove-section difftool > /dev/null 2>&1
	git config --global --remove-section mergetool > /dev/null 2>&1
	git config --global --remove-section difftool.meld > /dev/null 2>&1
	git config --global --remove-section difftool.kdiff3 > /dev/null 2>&1
	git config --global --remove-section difftool.p4merge > /dev/null 2>&1

	git config --global merge.tool meld
	git config --global diff.tool  meld


	git config --global mergetool.prompt false
	git config --global mergetool.keepBackup false
	git config --global mergetool.keepTemporaries false

	git config --global difftool.prompt false
	git config --global difftool.keepBackup false
	git config --global difftool.keepTemporaries false


    path_meld="$path_mt/Meld/Meld.exe"
    if [[ -e "$path_meld" ]]
    then
        echo "Meld : $path_meld"
        git config --global mergetool.meld.path "$path_meld"
	    git config --global difftool.meld.path "$path_meld"
    else
        echo "$path_meld : Not Found"
    fi

    path_p4merge="$path_mt/Perforce/p4merge.exe"
    if [[ -e "$path_p4merge" ]]
    then
        echo "p4merge : $path_meld"
        git config --global mergetool.p4merge.path "$path_p4merge"
	    git config --global difftool.p4merge.path "$path_p4merge"
    else
        echo "$path_p4merge : Not Found"
    fi

    path_kdiff3="$path_mt/KDiff3/kdiff3.exe"
    if [[ -e "$path_kdiff3" ]]
    then
        echo "kdiff3 : $path_kdiff3"
        git config --global mergetool.kdiff3.path "$path_kdiff3"
	    git config --global difftool.kdiff3.path "$path_kdiff3"
    else
        echo "$path_kdiff3 : Not Found"
    fi
fi