#!/bin/bash

#################################################### MIS A JOUR LE 14/11/2026 #########################################################################################
# 
# v0.4.3 : 19/11/2026
#  - Rajout du script fonctionnel pour BingWallofTheDay
#  - Rajout de l'étiquette note pour l'application Wonderwall, non codée pour le moment
#
#
# v0.4.2 : 18/11/2026
#  - Rajout de Xboot dans la liste des install, sans avoir codé la fonction
#
#
# v0.4.1 : 17/11/2026
#  - Rajout de BalenaEtcher dans la liste des install, sans avoir codé la fonction
#
# v0.4.0 : 16/11/2026
#  - Modifications et simplifcation du bandeau de description de lancement du script
#  - Ajout de l'étiquette PyCharm, même si pas développé en commentaires
#
# v0.3.9 : 14/11/2026
#  - 1er Contrôles du fonctionnement du script sous ubuntu 26.04.1 Resolute 
#  - Rajout de la taille du journal 'journalctl'

# v0.3.8 : 15/10/2026
#  - Correction dossier VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER ligne 12075
#  - Ajout du script d'installation de l'application Tux_guitar
# 
# v0.2.2 : 2026-04-08
#  - Correction chemin playlist freebox tv dans fichier .desktop créé

# v0.2.1 : 2026-03-26
# v0.1.9 : 2026-03-22
#
# v0.1.4 : 2026-03-15
#   - Uniformisation des case, taille dossier
#   - Correction du script steam qui affichait 2 fois les dpkg 
#
# v0.1 : 2026-02-21-00h25
# 2026-02-21-00h25-Modification de l'installation du logiciel Handbrake qui était via apt suite à maj handbrake non fonctionnelle en apt
# En regardant le site internet offciel handbrake, la version officiel est dispo uniquement en flatpak avec la cmd sudo flatpak install handbrake-gtk donc ne pas utiliser la cmd apt sudo apt install handbrake 
# qui fonctionne mais ne met pas à jour handbrake.
########################################################################################################################################################################

############### VARIABLES GLOBALES ###############
##### VARIABLES GLOBALES NECESSAIRES POUR SCRIPT D'APPLI SOLO SEPARE #####
# Timer de durée du script
TIMER_SCRIPT_START=$(date +%s%3N)

# On configure le terminal pour qu'il s’arrête s'il rencontre une erreur
set -euo pipefail 			# (`-e`: exit on error, `-u`: undefined vars, `-o pipefail`: pipe errors)

# Variables des couleurs de texte
TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'
TEXT_BLUE='\e[0;36m'
TEXT_GREEN='\e[0;32m'

# Variables de type d'installation (APT, Flatpak, Snap, Dpkg)
TXT_SETUP_TYPE_APT="APT"
TXT_SETUP_TYPE_FLATPAK="Flatpak"
TXT_SETUP_TYPE_SNAP="Snap"
TXT_SETUP_TYPE_DPKG="DPKG"
TXT_SETUP_TYPE_DEB="DEB"
TXT_SETUP_TYPE_CURL="CURL"

# Récupération du nom d'utilisateur actuel (pas root)
REAL_USER="${SUDO_USER:-$USER}"

##### OPTIONS #####
# Options d'analyse
SHOW_ANALYSE_LINES=false

# Fonctions de recherche
Recherche_existence_fichier()
{
	local Bool_fichier_existe=false
	
	if [ -f $1 ] ; then
		if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $1 existe !\n"; fi
		Bool_fichier_existe=true
		return 0
	else
		if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $1 n'existe pas !\n"; fi
		Bool_fichier_existe=false
		return 1
	fi
	
	echo $Bool_fichier_existe
	
	#return $Bool_fichier_existe
}

Recherche_fichier()
{
	if [ -f "$1" ] ; then
		if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $1 existe !\n"; fi
		return 0
	else
		if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $1 n'existe pas !\n"; fi
		return 1
	fi
}

Recherche_dossier()
{
	if [ -d "$1" ] ; then
		if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $1 existe !\n"; fi		
		return 0
	else
		if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $1 n'existe pas !\n"; fi
		return 1
	fi
}

# Compter les lignes d'un fichier (gère les fichiers vides)
Search_for_file_and_Nb_lines_in_file() {
    	local file="$1"

    	if [ -f "$file" ]; then
        	wc -l < "$file" || echo "0"
    	else
        	echo "0"
    	fi
}

# Compter les lignes d'un fichier (gère les fichiers vides)
Nb_lines_in_file() {
    	local file="$1"
	sudo wc -l < "$file" || echo "0"
}


# Fonctions de recherche (FIN)

# TABLEAU DYNAMIQUE

# Début des variables globales pour le tableau
# Colonne suivante
TAB_SUBTITLE_EXISTE_COL_SIZE=8
TAB_SUBTITLE_TAILLE_COL_SIZE=8

# Sous-titre "Chemin du fichier ou dossier recherche"
TAB_SUBTITLE_CHEMIN_COL_SIZE=70


TAB_SUBTITLE_CHEMIN_WITHOUT_SPACES="Chemin du fichier ou dossier recherche"

TAB_SUBTITLE_CHEMIN_WITHOUT_SPACES_WIDTH=${#TAB_SUBTITLE_CHEMIN_WITHOUT_SPACES}

declare -i TAB_SUBTITLE_CHEMIN_SPACE_PREFIX=$(( (${TAB_SUBTITLE_CHEMIN_COL_SIZE} - ${TAB_SUBTITLE_CHEMIN_WITHOUT_SPACES_WIDTH}) / 2 ))

TAB_SUBTITLE_CHEMIN_PREFIX=""

for i in $(seq 1 $TAB_SUBTITLE_CHEMIN_SPACE_PREFIX); do
	TAB_SUBTITLE_CHEMIN_PREFIX="$TAB_SUBTITLE_CHEMIN_PREFIX "
done

TAB_SUBTITLE_CHEMIN=$TAB_SUBTITLE_CHEMIN_PREFIX$TAB_SUBTITLE_CHEMIN_WITHOUT_SPACES

# Sous-titre "Chemin du fichier ou dossier recherche" (FIN)

TAB_EXISTE_TAILLE_CHEMIN_SIZE=$(expr $TAB_SUBTITLE_EXISTE_COL_SIZE + $TAB_SUBTITLE_TAILLE_COL_SIZE + $TAB_SUBTITLE_CHEMIN_COL_SIZE )

if $SHOW_ANALYSE_LINES; then echo -e "TAB_EXISTE_TAILLE_CHEMIN_SIZE = $TAB_EXISTE_TAILLE_CHEMIN_SIZE"; fi

# TAB_SUBTITLE_CHEMIN_SPACE_WIDTH=

TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES="Fichiers et/ou dossiers recherches et detectes"
TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES_SIZE=${#TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES}

if [ $((TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES_SIZE % 2)) -eq 0 ]; then
	if $SHOW_ANALYSE_LINES; then echo "pair"; fi
else
	if $SHOW_ANALYSE_LINES; then echo "impair"; fi
	TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES_SIZE=$(expr ${TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES_SIZE} - 1)
fi

if $SHOW_ANALYSE_LINES; then echo -e "TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES_SIZE=$TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES_SIZE"; fi

declare -i TAB_TITLE_F_ET_D_RECHERCHES_SPACE_PREFIX=$(( (${TAB_EXISTE_TAILLE_CHEMIN_SIZE} - ${TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES_SIZE}) / 2 ))
# declare -i TAB_TITLE_F_ET_D_RECHERCHES_SPACE_PREFIX=$(( ( expr $TAB_SUBTITLE_CHEMIN_COL_SIZE - 32 ) / 2 ))
# TAB_TITLE_F_ET_D_RECHERCHES_SPACE_PREFIX=$(expr $TAB_TITLE_F_ET_D_RECHERCHES_SPACE_PREFIX % 2)

# echo -e "Longueur : ${TAB_TITLE_F_ET_D_RECHERCHES_SPACE_PREFIX}\n$TAB_TITLE_F_ET_D_RECHERCHES_SPACE_PREFIX"

TAB_TITLE_F_ET_D_RECHERCHES_PREFIX=""

for i in $(seq 1 $TAB_TITLE_F_ET_D_RECHERCHES_SPACE_PREFIX); do
	TAB_TITLE_F_ET_D_RECHERCHES_PREFIX="$TAB_TITLE_F_ET_D_RECHERCHES_PREFIX "
done

TAB_TITLE_F_ET_D_RECHERCHES=$TAB_TITLE_F_ET_D_RECHERCHES_PREFIX$TAB_TITLE_F_ET_D_RECHERCHES_WITHOUT_SPACES

# echo -e "Test :$TAB_TITLE_F_ET_D_RECHERCHES_PREFIX Fin"

TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE=$(expr $TAB_SUBTITLE_EXISTE_COL_SIZE + 1 + $TAB_SUBTITLE_TAILLE_COL_SIZE + 1 + $TAB_SUBTITLE_CHEMIN_COL_SIZE)
# Colonne suivante
TABLEAU_COMMENTAIRES_SIZE=120

TABLEAU_COMMENTAIRES_SIZE_MOINS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE - 1)
TABLEAU_COMMENTAIRES_SIZE_PLUS_2=$(expr $TABLEAU_COMMENTAIRES_SIZE + 2)

declare -i TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_SIZE_DIVISE_PAR_2=$(( (${TABLEAU_COMMENTAIRES_SIZE} / 2) - 16 ))		# 14 car 27 caractères dans le mot 'Commentaires'

TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_PREFIX=""

for i in $(seq 1 $TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_SIZE_DIVISE_PAR_2); do
	TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_PREFIX="${TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_PREFIX} "
	#echo -e "test"
done

TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITHOUT_SPACES="Informations supplementaires"
TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES=$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_PREFIX$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITHOUT_SPACES


declare -i TABLEAU_COMMENTAIRES_SIZE_DIVISE_PAR_2=$(( (${TABLEAU_COMMENTAIRES_SIZE} / 2) - 7 ))		# 6 car 12 caractères dans le mot 'Commentaires'

#echo -e $TABLEAU_COMMENTAIRES_SIZE_DIVISE_PAR_2

TABLEAU_COMMENTAIRES_PREFIX=""

for i in $(seq 1 $TABLEAU_COMMENTAIRES_SIZE_DIVISE_PAR_2); do
	TABLEAU_COMMENTAIRES_PREFIX="${TABLEAU_COMMENTAIRES_PREFIX} "
	#echo -e "test"
done


TABLEAU_COMMENTAIRES_WITHOUT_SPACES="Commentaires"
TABLEAU_COMMENTAIRES_WITH_SPACES=$TABLEAU_COMMENTAIRES_PREFIX$TABLEAU_COMMENTAIRES_WITHOUT_SPACES


# echo -e $TABLEAU_COMMENTAIRES_PREFIX$TABLEAU_COMMENTAIRES_WITHOUT_SPACES				# N'affiche pas les espaces
# echo -e "$TABLEAU_COMMENTAIRES_WITH_SPACES"								# Affiche les espaces


TABLEAU_BORDER_FIRST_LINE_PREFIX="+%-17s+%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s+%-${TABLEAU_COMMENTAIRES_SIZE}s+\n" 

TABLEAU_BORDER_FIRST_LINE_1_3=""
TABLEAU_BORDER_FIRST_LINE_1_3_CHAR="-"
TABLEAU_BORDER_FIRST_LINE_1_3_NB_CHAR_TO_SHOW=17
for i in $(seq 1 $TABLEAU_BORDER_FIRST_LINE_1_3_NB_CHAR_TO_SHOW); do
	if [ -z "$TABLEAU_BORDER_FIRST_LINE_1_3" ] ; then				# -z teste si la chaine est nulle (vide ou non définie)
		TABLEAU_BORDER_FIRST_LINE_1_3=$TABLEAU_BORDER_FIRST_LINE_1_3_CHAR
	else
		TABLEAU_BORDER_FIRST_LINE_1_3=$TABLEAU_BORDER_FIRST_LINE_1_3$TABLEAU_BORDER_FIRST_LINE_1_3_CHAR
	fi	
done

TABLEAU_BORDER_FIRST_LINE_2_3=""
TABLEAU_BORDER_FIRST_LINE_2_3_CHAR="-"
TABLEAU_BORDER_FIRST_LINE_2_3_NB_CHAR_TO_SHOW=$TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE
for i in $(seq 1 $TABLEAU_BORDER_FIRST_LINE_2_3_NB_CHAR_TO_SHOW); do
	if [ -z "$TABLEAU_BORDER_FIRST_LINE_2_3" ] ; then				# -z teste si la chaine est nulle (vide ou non définie)
		TABLEAU_BORDER_FIRST_LINE_2_3=$TABLEAU_BORDER_FIRST_LINE_2_3_CHAR
	else
		TABLEAU_BORDER_FIRST_LINE_2_3=$TABLEAU_BORDER_FIRST_LINE_2_3$TABLEAU_BORDER_FIRST_LINE_2_3_CHAR
	fi	
done

TABLEAU_BORDER_FIRST_LINE_3_3=""
TABLEAU_BORDER_FIRST_LINE_3_3_CHAR="-"
TABLEAU_BORDER_FIRST_LINE_3_3_NB_CHAR_TO_SHOW=$TABLEAU_COMMENTAIRES_SIZE
for i in $(seq 1 $TABLEAU_BORDER_FIRST_LINE_3_3_NB_CHAR_TO_SHOW); do
	if [ -z "$TABLEAU_BORDER_FIRST_LINE_3_3" ] ; then				# -z teste si la chaine est nulle (vide ou non définie)
		TABLEAU_BORDER_FIRST_LINE_3_3=$TABLEAU_BORDER_FIRST_LINE_3_3_CHAR
	else
		TABLEAU_BORDER_FIRST_LINE_3_3=$TABLEAU_BORDER_FIRST_LINE_3_3$TABLEAU_BORDER_FIRST_LINE_3_3_CHAR
	fi	
done

#TABLEAU_BORDER_FIRST_LINE_2_3="----------------------------------------------------------------------------"
#TABLEAU_BORDER_FIRST_LINE_3_3="------------------------------------------------------------"
TABLEAU_BORDER_SUBTITLE_LINE_PREFIX="|%-17s+%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s+%-${TABLEAU_COMMENTAIRES_SIZE}s|\n"

TABLEAU_BORDER_SUBTITLE_LINE_1_3=""
TABLEAU_BORDER_SUBTITLE_LINE_1_3_CHAR="-"
TABLEAU_BORDER_SUBTITLE_LINE_1_3_NB_CHAR_TO_SHOW=17
for i in $(seq 1 $TABLEAU_BORDER_SUBTITLE_LINE_1_3_NB_CHAR_TO_SHOW); do
	if [ -z "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" ] ; then				# -z teste si la chaine est nulle (vide ou non définie)
		TABLEAU_BORDER_SUBTITLE_LINE_1_3=$TABLEAU_BORDER_SUBTITLE_LINE_1_3_CHAR
	else
		TABLEAU_BORDER_SUBTITLE_LINE_1_3=$TABLEAU_BORDER_SUBTITLE_LINE_1_3$TABLEAU_BORDER_SUBTITLE_LINE_1_3_CHAR
	fi	
done

TABLEAU_BORDER_SUBTITLE_LINE_2_3=""
TABLEAU_BORDER_SUBTITLE_LINE_2_3_CHAR="-"
TABLEAU_BORDER_SUBTITLE_LINE_2_3_NB_CHAR_TO_SHOW=$TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE
for i in $(seq 1 $TABLEAU_BORDER_SUBTITLE_LINE_2_3_NB_CHAR_TO_SHOW); do
	if [ -z "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" ] ; then				# -z teste si la chaine est nulle (vide ou non définie)
		TABLEAU_BORDER_SUBTITLE_LINE_2_3=$TABLEAU_BORDER_SUBTITLE_LINE_2_3_CHAR
	else
		TABLEAU_BORDER_SUBTITLE_LINE_2_3=$TABLEAU_BORDER_SUBTITLE_LINE_2_3$TABLEAU_BORDER_SUBTITLE_LINE_2_3_CHAR
	fi	
done

TABLEAU_BORDER_SUBTITLE_LINE_3_3=""
TABLEAU_BORDER_SUBTITLE_LINE_3_3_CHAR="-"
TABLEAU_BORDER_SUBTITLE_LINE_3_3_NB_CHAR_TO_SHOW=$TABLEAU_COMMENTAIRES_SIZE
for i in $(seq 1 $TABLEAU_BORDER_SUBTITLE_LINE_3_3_NB_CHAR_TO_SHOW); do
	if [ -z "$TABLEAU_BORDER_SUBTITLE_LINE_3_3" ] ; then				# -z teste si la chaine est nulle (vide ou non définie)
		TABLEAU_BORDER_SUBTITLE_LINE_3_3=$TABLEAU_BORDER_SUBTITLE_LINE_3_3_CHAR
	else
		TABLEAU_BORDER_SUBTITLE_LINE_3_3=$TABLEAU_BORDER_SUBTITLE_LINE_3_3$TABLEAU_BORDER_SUBTITLE_LINE_3_3_CHAR
	fi	
done

# TABLEAU DYNAMIQUE

##### VARIABLES GLOBALES NECESSAIRES POUR SCRIPT D'APPLI SOLO SEPARE (FIN) #####

BASH_UBUNTU_25_10_CONFIGURATION_VERSION_SCRIPT="v0.4.1"
BASH_UBUNTU_25_10_CONFIGURATION_DATE_SCRIPT="14/11/2026"

# Actuellement ne fait que vérifier le swap avec swpon --show
INSTALL_SWAP=true

##### CHOIX DES APPLICATIONS A INSTALLER #####
INSTALL_ALL=false
INSTALL_BALENAETCHER=false 			# Pas codé pour le moment, accès au deb sur le git https://github.com/balena-io/etcher/releases/. Ce logiciel est utile pour installer ubuntu (24.04, 25.10, 26.04...) sur une clé usb
INSTALL_BINGWALLOFTHEDAY=true 		# Permet d'avoir les images de fonds d'écran windows sur linux
INSTALL_BLENDER=false
INSTALL_BRAVE=false
INSTALL_CENTRE_DE_MISSION=false
INSTALL_CLAMAV_DAEMON=false
INSTALL_CLAMUI=false
INSTALL_COMFYUI=false
INSTALL_CURL=false
INSTALL_FIREFOX=false
INSTALL_FREEBOX_TV=false
INSTALL_FREECAD=false
INSTALL_FWUP=false
INSTALL_GEDIT=false
INSTALL_GIMP=false
INSTALL_GITHUB_DESKTOP=false
INSTALL_GPARTED=false
INSTALL_GNOME_BOXES=false
INSTALL_GNOME_SUDOKU=false
INSTALL_GRAYLOG=false			# Outil de gestion de journalisation centralisé open-source et robuste
INSTALL_HANDBRAKE=false
INSTALL_HARDINFO=false
INSTALL_IPTABLES_PERSISTENT=false
INSTALL_KRITA=false
INSTALL_LIBREPCB=false
INSTALL_LOGCHECK=false			# Outil open-source de surveillance des journaux			A coder
INSTALL_LOGSTASH=false			# Pipeline de traitement de données open-source côté serveur		A coder
INSTALL_LOGWATCH=false			# Application de collecte et analyse de journaux			A coder
INSTALL_LUTRIS=false
INSTALL_NETFILTER_PERSISTENT=false
INSTALL_NOTEPAD_PLUS_PLUS=false
INSTALL_OBS_STUDIO=false
INSTALL_OLLAMA=false
INSTALL_OMXPLAYER=false		# Alternative à VLC qui utilise l'accélération graphique par défaut		A coder
INSTALL_OPENRGB=false		# Soft pour fixer la couleur d'équipements connectés (clavier, souris, ram...)
INSTALL_OPERA=false
INSTALL_PROTON_AUTH=false		# A faire, non développé
INSTALL_PROTON_MAIL=false
INSTALL_PROTON_PASS=false
INSTALL_PYCHARM=false			# A faire, non développé
INSTALL_QEMU_KVM=false
INSTALL_RASPBERRY_PI_IMAGER=false
INSTALL_RHYTHMBOX=false
INSTALL_SIGNAL_DESKTOP=false
INSTALL_STACER=false
INSTALL_STEAM=false
INSTALL_STELLARIUM=false
INSTALL_SWEEPER=false
INSTALL_TBOPLAYER=false		# Interface graphique alternative à omxplayerGUI pour omxplayer			A coder
INSTALL_TEMPLATE=false		# Template / modèle de rajout d'appli dans cette liste
INSTALL_THUNDERBIRD=false
INSTALL_TUXGUITAR=false
INSTALL_VIRTUALBOX=false
INSTALL_VISUAL_STUDIO_CODE=false
INSTALL_VLC=false
INSTALL_VLC_WRAPPER_DESKTOP_SHORTCUT=false
INSTALL_WHATSAPP=false
INSTALL_WIRESHARK=false
INSTALL_WONDERWALL=false			# Application évoluée de Bingwallpaperoftheday, non codée pour le moment
INSTALL_XBOOT=false 				# Non codé pour le moment. Permet de créer des clé usb multiboot assez facilement
##### CHOIX DES APPLICATIONS A INSTALLER (FIN) #####

##### CHOIX DES SCAN A FAIRE #####
SCAN_NVIDIA_INFOS=false
SCAN_PYTHON_INFOS=false
##### CHOIX DES SCAN A FAIRE (FIN) #####


##### OPTIONS (FIN) #####



############### FIN VARIABLES GLOBALES ###############


##### CONSOLE - TITRE DU SCRIPT #####

TITRE_TABLEAU_LONGUEUR=160
TITRE_TABLEAU_SPACE_EMPTY_LINE_LONGUEUR=150
TITRE_TABELAU_DASH_BORDURE_LONGUEUR=5


echo -e $TEXT_BLUE
# First line ###############
for ((i=0; i<TITRE_TABLEAU_LONGUEUR; i++)); do
    printf '#'
done
# printf '%.0s#' {0..$TITRE_TABLEAU_LONGUEUR}
printf "\n"

# Line 5x#		5x#
# printf '%.0s#' {0..4}
for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done

#printf '%.0s ' {0..149}
for ((i=0; i<TITRE_TABLEAU_SPACE_EMPTY_LINE_LONGUEUR; i++)); do
    printf ' '
done

for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done
printf "\n"

printf '%.0s#' {0..4}
printf "                    LANCEMENT DU SCRIPT - Script d'installation d'applications courantes pour Ubuntu. Développé par Olivosaure !                      "
printf '%.0s#' {0..4}
printf "\n"

printf '%.0s#' {0..4}
printf "								       Testé sur les versions Ubuntu :							   "
printf '%.0s#' {0..4}
printf "\n"

printf '%.0s#' {0..4}
printf "									26.04.1 LTS Resolute Raccoon							   "
printf '%.0s#' {0..4}
printf "\n"

printf '%.0s#' {0..4}
printf "									25.10 Questing Quokka								   "
printf '%.0s#' {0..4}
printf "\n"



# Line 5x#		5x#
# printf '%.0s#' {0..4}
for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done

#printf '%.0s ' {0..149}
for ((i=0; i<TITRE_TABLEAU_SPACE_EMPTY_LINE_LONGUEUR; i++)); do
    printf ' '
done

for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done
printf "\n"

printf '%.0s#' {0..4}
printf "                                                                         $BASH_UBUNTU_25_10_CONFIGURATION_VERSION_SCRIPT                                                                       "
printf '%.0s#' {0..4}
printf "\n"

# Line 5x#		5x#
# printf '%.0s#' {0..4}
for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done

#printf '%.0s ' {0..149}
for ((i=0; i<TITRE_TABLEAU_SPACE_EMPTY_LINE_LONGUEUR; i++)); do
    printf ' '
done

for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done
printf "\n"

printf '%.0s#' {0..4}
printf "                                                                  Mis à jour le $BASH_UBUNTU_25_10_CONFIGURATION_DATE_SCRIPT                                                            "
printf '%.0s#' {0..4}
printf "\n"



# Line 5x#		5x#
# printf '%.0s#' {0..4}
for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done

#printf '%.0s ' {0..149}
for ((i=0; i<TITRE_TABLEAU_SPACE_EMPTY_LINE_LONGUEUR; i++)); do
    printf ' '
done

for ((i=0; i<TITRE_TABELAU_DASH_BORDURE_LONGUEUR; i++)); do
    printf '#'
done
printf "\n"



# Last line, same as first
# Line 5x#		5x#
for ((i=0; i<TITRE_TABLEAU_LONGUEUR; i++)); do
    printf '#'
done
# printf '%.0s#' {0..$TITRE_TABLEAU_LONGUEUR}
printf "\n"

#printf '%.0s#' {0..159}
#printf "\n"

echo -e $TEXT_RESET

##### CONSOLE - TITRE DU SCRIPT (FIN) #####

############### VERIFICATION DU SYSTEME #################
echo -e "UBUNTU - Vérification de la version d'Ubuntu utilisée :\n"

# Affichage du numéro de version Ubuntu
echo -e "Numéro de version Ubuntu :"
sudo lsb_release -sr
echo -e ""

# Affichage ddes détails de la version Ubuntu
echo -e "Détails de la version Ubuntu :"
sudo lsb_release -a
echo -e ""

# Affichage de la taille actuelle du journal
echo -e "Taille du journal actuel du système (Valeur de base sur une vbox ubuntu 26.04 Resolute Raccoon updated : 121.1M) :"
sudo journalctl --disk-usage
# Exemple de valeur sur une vbox ubuntu 26.04.1 Resolute --> Archived and active journals take up 121.1M in the file system
echo -e ""

############### VERIFICATION DU SYSTEME (FIN) #################




if $INSTALL_IPTABLES_PERSISTENT || $INSTALL_ALL; then
############################## IPTABLES PERSISTENT ####################################
############### CONFIGURATION DU PARE-FEU IPTABLES ########################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Iptables persistent"

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^}-Installation du module manquant à Ubuntu 25.10 pour que le pare-feu IPTABLES soit permanent même après redémarrage"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
IPTABLES_PERSISTENT_VAR_LIB_DPKG_INFO_FILENAME="/var/lib/dpkg/info/iptables-persistent.config" # Pas testé
IPTABLES_PERSISTENT_USR_SHARE_FOLDER="/usr/share/doc/iptables-persistent"

if [ -d "$IPTABLES_PERSISTENT_USR_SHARE_FOLDER" ]; then
	echo -e "✅ Le dossier $IPTABLES_PERSISTENT_USR_SHARE_FOLDER existe !\n"

        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

        echo -e "Informations sur la version installée :\n"

        # Affichage de la version du paquet installé
        dpkg -l iptables-persistent

else
	echo -e "❌ Le dossier $IPTABLES_PERSISTENT_USR_SHARE_FOLDER n'existe pas !\n"

	echo -e "Installation de $TXT_APP_TO_INSTALL"

	# Ligne nécessaire avant l'installation 'apt install' pour répondre directement à la question save ipv4 par 'Yes' et automatiser le script
	echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | sudo debconf-set-selections
	
	# Ligne nécessaire avant l'installation 'apt install' pour répondre directement à la question save ipv6 par 'Yes' et automatiser le script
	echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | sudo debconf-set-selections 

	sudo apt-get -y install iptables-persistent

fi

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l installation du module manquant Ubuntu 25.10 pour rendre le pare-feu IPTABLES permanent même après redémarrage"
echo -e $TEXT_RESET

################
############################## IPTABLES PERSISTENT ####################################
fi # if $INSTALL_IPTABLES_PERSISTENT; then


if $INSTALL_NETFILTER_PERSISTENT || $INSTALL_ALL; then
############################## NETFILTER PERSISTENT ####################################
################
# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Netfilter persistent"

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Activation de la sauvegarde automatique des paramètres de pare-feu IPTABLES"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
NETFILTER_PERSISTENT_VAR_LIB_DPKG_INFO_FILENAME="/usr/sbin/netfilter-persistent" # Pas testé
NETFILTER_PERSISTENT_USR_SHARE_DOC_FOLDER="/usr/share/doc/netfilter-persistent"

if [ -d "$NETFILTER_PERSISTENT_USR_SHARE_DOC_FOLDER" ]; then
        echo -e "✅ Le dossier $NETFILTER_PERSISTENT_USR_SHARE_DOC_FOLDER existe !\n"

        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

        echo -e "Informations sur la version installée :\n"

        # Affichage de la version du paquet installé
        dpkg -l netfilter-persistent
        
        echo -e ""

        sudo netfilter-persistent save

else
        echo -e "❌ Le dossier $NETFILTER_PERSISTENT_USR_SHARE_DOC_FOLDER n'existe pas !\n"

        echo -e "Installation de $TXT_APP_TO_INSTALL"

        sudo netfilter-persistent save

fi

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'activation automatique des paramètres de pare-feu IPTABLES"
echo -e $TEXT_RESET
################# CONFIGURATION DU PARE-FEU IPTABLES (FIN) ########################
############################## NETFILTER PERSISTENT ####################################
fi # 


if $INSTALL_SWAP; then
############################## SWAP  ####################################

# Configuration et Vérification :
# sudo fallocate -l 4G /swapfile
# sudo chmod 600 /swapfile

# Formate la partition swap et affiche le UUID (nécessaire à écrire dans etc/fstab)
# sudo mkswap /swapfile

# echo -e "Activation avec une priorité de 10 (la priorité va de 0 et 32767 mais pas testé autre que 10 pour le moment) au lieu de -2 par défaut"
# sudo swapon --priority 10 /swapfile					ou sudo swapon --priority 100 /dev/nvme0n1p4

# Pour désactiver un swap (nécessaire avant de le modifier), il faut : 			sudo swapoff /swapfile			ou sudo swapoff /dev/nvme0n1p4

echo -e "Dossier de lancement du script :\n"

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "Le script est lancé depuis le dossier $SCRIPT_DIR !\n"

echo -e "Vérification de la présence d'un ou plusieurs fichier(s) swap lié au système (affiche la priorité également) :\n"
sudo swapon --show

echo -e ""

echo -e "Affichage de la liste des espaces swap utilisés par le noyau :\n"
cat /proc/swaps

echo -e ""

echo -e "Affichage de la valeur de swapiness actuelle du système avec la commande 'cat /proc/sys/vm/swappiness' :"
cat /proc/sys/vm/swappiness

echo -e ""

echo -e "Affichage détaillé de la ram et swap actuellement utilisés avec la commande 'free -h' :\n"

free -h

echo -e ""



echo -e "Pour modifier la swapiness (valeur comprise entre 0 et 100), utiliser la commande 'sudo sysctl vm.swappiness=80' pour un facteur de 80 par exemple, la valeur par défaut est 60) !\n"

echo -e "Pour modifier la swapiness déginitvement même après redémarrage, rajouter la ligne 'vm.swappiness=80' dans le fichier '/etc/sysctl.conf' et/ou '/etc/sysctl.d/99-swappiness.conf' et lancer la commande 'sudo sysctl --system' pour appliquer directement cette valeur !\n"

echo -e "❗ Lorsque l'on exécute la commande de vérification précédente 'sudo sysctl --system', la valeur 'vm.swappiness = XX' peut apparaitre 2 fois dans la liste sous Ubuntu25.10, elles correspondent à la valeur du fichier '/etc/sysctl.d/99-swappiness.conf' et la valeur du fichier '/etc/sysctl.conf' dans cet ordre !\n"


# sudo swapon /swapfile

# Pour que ce fichier soit reconnu au démarrage, ajoutez la ligne suivante dans le fichier /etc/fstab : 		/swapfile swap swap defaults 0 0
# ou /swapfile none swap sw,pri=100 0 0 pour une priorité de 100
# avec l'UUID en début de ligne comme UUID=b0bdac5f-8cbc-4a5c-8108-62d50edd30b5 /swapfile none swap sw,pri=100,nofail 0 0 
# Pour Ubuntu25.10, la priorité varie entre 0 et 200 (100 étant déja beaucoup normalement)
# nofail permet d'éviter les erreurs de démarrage si le point de montage swap n'est pas présent


# Pour vérifier la bonne syntaxe du fichier fstab, utiliser la commande 			sudo mount -o remount /				à tester	
# Cette commande force un nouveau chargement des options de montage de la racine. Si aucune erreur n'est retournée, la syntaxe de votre fstab est correcte, y compris l'option nofail.


# Pour vérifier le nom UUID du swap
# Commande pour lister tous les points de montage avec affichage de l'UUID									sudo blkid
# Commande pour lister tous les points de montage swap uniquement avec affichage de l'UUID									sudo blkid -t TYPE=swap



############################## SWAP (FIN) ####################################
fi # if $INSTALL_SWAP then



# Pour accéder aux paramètres de la carte audio
# sudo nano /etc/modprobe.d/alsa-base.conf


############################ STOCKAGE #############################

# For NTFS partitions: If the drive was last used on Windows with "Fast Startup" enabled, the partition is marked as dirty and unmountable in Linux. You can often fix this by running sudo ntfsfix -d /dev/sda2 to clear the dirty flag :


# sudo ntfsfix -d /dev/sda2

############################ STOCKAGE (FIN) #############################


############################ SNAP #############################

echo -e "Vérifications et affichage des warnings Snap :\n"

snap warnings

echo -e ""

############################ SNAP (FIN) #############################


############################ AFFICHAGE DES MINIATURES DANS NAUTILUS #############################

# sudo apt install ffmpegthumbnailer gstreamer1.0-libav

############################ AFFICHAGE DES MINIATURES DANS NAUTILUS (FIN) #############################


############################ DOSSIER PARTAGE #############################

# Ajouter la ligne suivante dans /etc/fstab
# /hostshare /home/olivosaure/KVM-Share 9p trans=virtio,version=9p2000.L,rw,user,_netdev,nofail 0 0

# 'user' donne les droits sur le dossier à l'utilisateur courant
# 'nofail' évite les erreurs de démarrage ubuntu si un pb est rencontré sur ce point de montage

############################ DOSSIER PARTAGE (FIN) #############################


############################ CONSEILS #############################

echo -e "💡 Conseil** : Testez vos scripts pour éviter les erreurs courantes					● https://www.shellcheck.net"
echo -e "💡 Liste des dépôts Ubuntu (.deb) sur le site d'archives Ubuntu						● https://fr.archive.ubuntu.com/ubuntu/pool/multiverse/"
echo -e "💡 Pour rechercher un paquet sur le site internet							● https://packages.ubuntu.com/"
echo -e "\n"

############################ CONSEILS (FIN) #############################



################# INSTALLATION DES LOGICIELS ########################


if $INSTALL_CURL || $INSTALL_ALL; then
############################## CURL ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Curl"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
CURL_USR_BIN_FILENAME="/usr/bin/curl"
CURL_USR_SHARE_DOC_FOLDER="/usr/share/doc/curl"
# Booléens associés
CURL_USR_BIN_FILENAME_FOUND=false
CURL_USR_SHARE_DOC_FOLDER_FOUND=false
# Tailles
TAILLE_CURL_USR_BIN_FILENAME=""
TAILLE_CURL_USR_SHARE_DOC_FOLDER=""

# Contrôle de fichier
if Recherche_fichier $CURL_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $CURL_USR_BIN_FILENAME existe !\n"; fi
	CURL_USR_BIN_FILENAME_FOUND=true
	TAILLE_CURL_USR_BIN_FILENAME=$(du -sh "$CURL_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $CURL_USR_BIN_FILENAME n'existe pas !\n"; fi
	CURL_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $CURL_USR_SHARE_DOC_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $CURL_USR_SHARE_DOC_FOLDER existe !\n"; fi
	CURL_USR_SHARE_DOC_FOLDER_FOUND=true
	TAILLE_CURL_USR_SHARE_DOC_FOLDER=$(du -sh "$CURL_USR_SHARE_DOC_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $CURL_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	CURL_USR_SHARE_DOC_FOLDER_FOUND=false
fi


declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CURL_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_CURL_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$CURL_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Executable"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CURL_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_CURL_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$CURL_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]="Contient le changelog et copyright"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $CURL_USR_BIN_FILENAME_FOUND && $CURL_USR_SHARE_DOC_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $CURL_USR_BIN_FILENAME_FOUND || ! $CURL_USR_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $CURL_USR_BIN_FILENAME_FOUND && ! $CURL_USR_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
	
	;;

	$TXT_SETUP_TYPE_SNAP)
	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## CURL (FIN) #################################### 
fi # if $INSTALL_CURL || $INSTALL_ALL; then





if $INSTALL_BINGWALLOFTHEDAY || $INSTALL_ALL; then
############################## MODELE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="BingWalloftheday"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=true

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
APPNAME_USR_BIN_FILENAME="/usr/bin/app_bin_template"
APPNAME_USR_SHARE_FOLDER="/usr/share/app_template"
BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER="/snap/bing-wall/35/usr/share/applications"
HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER="/home/testeur/snap/bing-wall/common/.cache/org.keshavnrj.ubuntu/BingWall"

# Booléens associés
APPNAME_USR_BIN_FILENAME_FOUND=false
APPNAME_USR_SHARE_FOLDER_FOUND=false
BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER_FOUND=false
HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER_FOUND=false

# Tailles (nécessaire si fichier et/ou dossier absent)
TAILLE_APPNAME_USR_BIN_FILENAME=""
TAILLE_APPNAME_USR_SHARE_FOLDER=""


# Contrôle de fichier
if Recherche_fichier $APPNAME_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $APPNAME_USR_BIN_FILENAME existe !\n"; fi
	APPNAME_USR_BIN_FILENAME_FOUND=true
	TAILLE_APPNAME_USR_BIN_FILENAME=$(du -sh "$APPNAME_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $APPNAME_USR_BIN_FILENAME n'existe pas !\n"; fi
	APPNAME_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $APPNAME_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $APPNAME_USR_SHARE_FOLDER existe !\n"; fi
	APPNAME_USR_SHARE_FOLDER_FOUND=true
	TAILLE_APPNAME_USR_SHARE_FOLDER=$(du -sh "$APPNAME_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $APPNAME_USR_SHARE_FOLDER n'existe pas !\n"; fi
	APPNAME_USR_SHARE_FOLDER_FOUND=false
fi

if Recherche_dossier $BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER existe !\n"; fi
	BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER_FOUND=true
	TAILLE_BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER=$(du -sh "$BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER n'existe pas !\n"; fi
	BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER_FOUND=false
fi

if Recherche_dossier $HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER existe !\n"; fi
	HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER_FOUND=true
	TAILLE_HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER=$(du -sh "$HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER n'existe pas !\n"; fi
	HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER_FOUND=false
fi


declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$APPNAME_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_APPNAME_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$APPNAME_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$APPNAME_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_APPNAME_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$APPNAME_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER
tableau[$tab_ind,chemin]=$BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER
tableau[$tab_ind,chemin]=$HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER
tableau[$tab_ind,commentaires]=""




if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""






case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $APPNAME_USR_BIN_FILENAME_FOUND && $APPNAME_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND || ! $APPNAME_USR_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND && ! $APPNAME_USR_SHARE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
	
	;;

	$TXT_SETUP_TYPE_SNAP)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER_FOUND && $HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"

			echo -e "Informations sur la version de $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP :\n"
			snap list bing-wall
			echo -e ""
			
			echo -e "Informations détaillées sur la version de $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP :\n"
			snap info --verbose bing-wall
			echo -e ""
			
			echo -e "Informations détaillées des dépendances sur la version de $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP :\n"
			grep default-provider /snap/bing-wall/current/meta/snap.yaml
			echo -e ""
			
			echo -e "Informations détaillées des connexions d'interfaces sur la version de $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP :\n"
			snap connections bing-wall
			echo -e ""
		fi	
	
		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $BINGWALL_SNAP_BINGWALL_USER_SHARE_APPLICATIONS_FOLDER_FOUND && ! $HOME_USER_SNAP_BINGWALL_COMMON_CACHE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TO_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
			
			sudo snap install bing-wall
		fi	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## MODELE (FIN) #################################### 
fi # if $INSTALL_BINGWALLOFTHEDAY || $INSTALL_ALL; then











if $INSTALL_OPERA || $INSTALL_ALL; then
############################## OPERA ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Opéra"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_DEB

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom de l'utilisateur actuel pour les chemins des dossiers utilisateurs
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

TXT_SUBFOLDER=" >"

# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux 
OPERA_LOCAL_DEB_FILENAME="opera-stable_130.0.5847.92_amd64.deb"				# Mise à jour le 8/04/2026
OPERA_LOCAL_DEB_FOLDER=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/DEB
OPERA_LOCAL_DEB_OPERA_STABLE_SUBFOLDER="Opera/Stable"					# Rajouté le 27/04/2026
OPERA_LOCAL_DEB_FILENAME_FULLPATH=$OPERA_LOCAL_DEB_FOLDER/$OPERA_LOCAL_DEB_OPERA_STABLE_SUBFOLDER/$OPERA_LOCAL_DEB_FILENAME

# Chemin des fichiers et/ou dossiers
OPERA_BIN_FILENAME="/usr/bin/opera"
OPERA_USR_SHARE_DOC_FOLDER="/usr/share/doc/opera-stable"
OPERA_APT_FILENAME="https://deb.opera.com/opera-stable/"
OPERA_VAR_CACHE_APT_ARCHIVES="/var/cache/apt/archives"
OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER="/usr/lib/x86_64-linux-gnu/opera-stable"
# Chemins utilisateur
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER="$HOME_USER/.config/opera/Default"
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME="$HOME_USER/.config/opera/Default/Bookmarks"
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME="$HOME_USER/.config/opera/Default/History"
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME="$HOME_USER/.config/opera/Default/Preferences"
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME="$HOME_USER/.config/opera/Default/Cookies"

# Initialisation des booléens
OPERA_BIN_FILENAME_FOUND=false
OPERA_USR_SHARE_DOC_FOLDER_FOUND=false
OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND=false
OPERA_HOME_USR_CACHE_FOLDER_FOUND=false
OPERA_HOME_USR_CONFIG_FOLDER_FOUND=false
# Booléens des chemins utilisateur
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER_FOUND=false
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME_FOUND=false
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME_FOUND=false
OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME_FOUND=false
# Tailles
TAILLE_OPERA_BIN_FILENAME=""
TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME=""
TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME=""
TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME=""
TAILLE_OPERA_USR_SHARE_DOC_FOLDER=""
TAILLE_OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER=""
TAILLE_OPERA_HOME_USR_CACHE_FOLDER=""
TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER=""



# Activer / désactiver débuguage si besoin
# SHOW_ANALYSE_LINES=false

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $OPERA_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $OPERA_BIN_FILENAME existe !\n"; fi
	OPERA_BIN_FILENAME_FOUND=true
	TAILLE_OPERA_BIN_FILENAME=$(du -sh "$OPERA_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $OPERA_BIN_FILENAME n'existe pas !\n"; fi
	OPERA_BIN_FILENAME_FOUND=false
fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME existe !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME_FOUND=true
	TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME=$(du -sh "$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME n'existe pas !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME_FOUND=false
fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME existe !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME_FOUND=true
	TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME=$(du -sh "$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME n'existe pas !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME_FOUND=false
fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME existe !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME_FOUND=true
	TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME=$(du -sh "$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME n'existe pas !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME_FOUND=false
fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME existe !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME_FOUND=true
	TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME=$(du -sh "$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME n'existe pas !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $OPERA_USR_SHARE_DOC_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OPERA_USR_SHARE_DOC_FOLDER existe !\n"; fi
	OPERA_USR_SHARE_DOC_FOLDER_FOUND=true
	TAILLE_OPERA_USR_SHARE_DOC_FOLDER=$(du -sh "$OPERA_USR_SHARE_DOC_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OPERA_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	OPERA_USR_SHARE_DOC_FOLDER_FOUND=false
fi


# Contrôle du dossier 
if Recherche_dossier $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER existe !\n"; fi
	OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND=true
	TAILLE_OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER=$(du -sh "$OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER n'existe pas !\n"; fi
	OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND=false
fi


# Contrôle d'un dossier utilisateur
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
OPERA_HOME_USR_CACHE_FOLDER="$USER_HOME/.cache/opera"

# Controle du dossier 
if Recherche_dossier $OPERA_HOME_USR_CACHE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OPERA_HOME_USR_CACHE_FOLDER existe !\n"; fi
	OPERA_HOME_USR_CACHE_FOLDER_FOUND=true
	TAILLE_OPERA_HOME_USR_CACHE_FOLDER=$(du -sh "$OPERA_HOME_USR_CACHE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OPERA_HOME_USR_CACHE_FOLDER n'existe pas !\n"; fi
	OPERA_HOME_USR_CACHE_FOLDER_FOUND=false
fi


OPERA_HOME_USR_CONFIG_FOLDER="$USER_HOME/.config/opera"


# Contrôle du dossier 
if Recherche_dossier $OPERA_HOME_USR_CONFIG_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OPERA_HOME_USR_CONFIG_FOLDER existe !\n"; fi
	OPERA_HOME_USR_CONFIG_FOLDER_FOUND=true
	TAILLE_OPERA_HOME_USR_CONFIG_FOLDER=$(du -sh "$OPERA_HOME_USR_CONFIG_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OPERA_HOME_USR_CONFIG_FOLDER n'existe pas !\n"; fi
	OPERA_HOME_USR_CONFIG_FOLDER_FOUND=false
fi


# Contrôle du dossier 
if Recherche_dossier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER existe !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER_FOUND=true
	TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER=$(du -sh "$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER n'existe pas !\n"; fi
	OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER_FOUND=false
fi


# Recherche de fichiers archives dans le système
fichiers=("$OPERA_VAR_CACHE_APT_ARCHIVES"/opera*)

if [ -e "${fichiers[0]}" ]; then
	# Calcul de la taille du fichier installé
	TAILLE_OPERA_VAR_CACHE_APT_ARCHIVES_FILENAME=$(du -sh "${fichiers[0]}" | cut -f1)

	if $SHOW_ANALYSE_LINES; then echo -e "Un fichier commençant par '$TXT_APP_TO_INSTALL' appelé $(basename ${fichiers[0]}) ($TAILLE_OPERA_VAR_CACHE_APT_ARCHIVES_FILENAME) existe dans $OPERA_VAR_CACHE_APT_ARCHIVES !\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "Aucun fichier commençant par '$TXT_APP_TO_INSTALL' dans $OPERA_VAR_CACHE_APT_ARCHIVES !\n"; fi
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la recherche des fichiers et/ou dossiers recherchés !\n"; fi


# Test temporaire
declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_BIN_FILENAME
tableau[$tab_ind,chemin]=$OPERA_BIN_FILENAME
tableau[$tab_ind,commentaires]="Lien vers l'application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$OPERA_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]="Dossier contenant le copyright et changelog.gz"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER
tableau[$tab_ind,chemin]=$OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER
tableau[$tab_ind,commentaires]="Dossier des librairies"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_HOME_USR_CACHE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_HOME_USR_CACHE_FOLDER
tableau[$tab_ind,chemin]=$OPERA_HOME_USR_CACHE_FOLDER
tableau[$tab_ind,commentaires]="Dossier cache utilisateur, apparait apres 1er lancement"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_HOME_USR_CONFIG_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_HOME_USR_CONFIG_FOLDER
tableau[$tab_ind,chemin]=$OPERA_HOME_USR_CONFIG_FOLDER
tableau[$tab_ind,commentaires]="Dossier config utilisateur, apparait apres 1er lancement"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_FOLDER"
tableau[$tab_ind,commentaires]="Dossier default config utilisateur contenant les favoris, historique et signatures"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_BOOKMARKS_FILENAME"
tableau[$tab_ind,commentaires]="Fichier des favoris du navigateur Opera"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_HISTORY_FILENAME"
tableau[$tab_ind,commentaires]="Fichier de l'historique du navigateur Opera"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_PREFERENCES_FILENAME"
tableau[$tab_ind,commentaires]="Fichier des preferences du navigateur Opera"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $OPERA_HOME_USER_CONFIG_OPERA_DEFAULT_COOKIES_FILENAME"
tableau[$tab_ind,commentaires]="Fichier des cookies du navigateur Opera"


if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Extraire les premiers indices et trouver le max
indices=($(printf '%s\n' "${!tableau[@]}" | cut -d',' -f1 | sort -n))

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=${indices[-1]}

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do

		# printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s| %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}" " ${tableau["$i,existe"]}" "  ${tableau["$i,taille"]}" " ${tableau["$i,chemin"]}" "${tableau["$i,commentaires"]}"
		#echo -e $TEXT_GREEN
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		#echo -e $TEXT_RESET
		
		#echo -e $TEXT_GREEN
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		
		
		#echo -e $TEXT_RESET
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"

		# echo -e "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s| %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}" " ${TEXT_GREEN}${tableau["$i,existe"]}${TEXT_RESET}" "  ${tableau["$i,taille"]}" " ${tableau["$i,chemin"]}" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""



case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_DEB)
		if $OPERA_BIN_FILENAME_FOUND && $OPERA_USR_SHARE_DOC_FOLDER_FOUND && $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet Opera installé
			# dpkg -l opera
			opera --version # car dpkg ne fournit aucune info de version

			# Saut de ligne console
			echo -e ""
			
			dpkg -l opera-stable
			
			echo -e ""
		fi	
	
		# S"il manque tous les fichiers et/ou dossiers recherchés
		if ! $OPERA_BIN_FILENAME_FOUND && ! $OPERA_USR_SHARE_DOC_FOLDER_FOUND && ! $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND ; then
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via un paquet local deb $OPERA_LOCAL_DEB_FILENAME :\n"
			
			echo -e "Pré-réponse (yes) avant installation pour automatiser l'ajout du dépot d'Opéra au système avec la commande 'echo "opera-stable opera-stable/add-deb-source boolean true" | sudo debconf-set-selections' :"
			
			echo "opera-stable opera-stable/add-deb-source boolean true" | sudo debconf-set-selections
			
			sudo dpkg -i $OPERA_LOCAL_DEB_FILENAME_FULLPATH
			
			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via un paquet local deb $OPERA_LOCAL_DEB_FILENAME :\n"
		fi
	;;

	$TXT_SETUP_TYPE_APT)
		# S"il manque que les fichiers et/ou dossiers utilisateurs
		if $OPERA_BIN_FILENAME_FOUND && $OPERA_USR_SHARE_DOC_FOLDER_FOUND && $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND && ! $OPERA_HOME_USR_CACHE_FOLDER_FOUND && ! $OPERA_HOME_USR_CONFIG_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est installée mais n'a jamais été lancée !\n"
		fi	
	
		if $OPERA_BIN_FILENAME_FOUND && $OPERA_USR_SHARE_DOC_FOLDER_FOUND && $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet Opera installé
			# dpkg -l opera
			opera --version # car dpkg ne fournit aucune info de version

			# Saut de ligne console
			echo -e ""
			
			dpkg -l opera-stable
			
			echo -e ""
		fi

		# S"il manque tous les fichiers et/ou dossiers recherchés
		if ! $OPERA_BIN_FILENAME_FOUND && ! $OPERA_USR_SHARE_DOC_FOLDER_FOUND && ! $OPERA_USR_LIB_X86_64_LINUX_GNU_FOLDER_FOUND && ! $OPERA_HOME_USR_CACHE_FOLDER_FOUND && ! $OPERA_HOME_USR_CONFIG_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			if grep OPERA_APT_FILENAME /etc/apt/sources.list.d/*.list; then
				echo -e "Le dépôt ppa de Opéra est déja présent dans la liste des apt\n"

				echo -e "Recherche d'une version déja installée :\n"

				# dpkg -l opera

			else
				echo -e "❌ Le dépôt ppa de Opéra n'est pas présent dans la liste des apt\n"

				echo -e "Récupération de la clé GPG"

				# Récupération de la clé GPG
				wget -qO- https://deb.opera.com/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/opera-browser.gpg > /dev/null
				# a tester 
				# sudo gpg --dearmor -o /usr/share/keyrings/opera.gpg https://deb.opera.com/archive.key
				# wget -qO - https://deb.opera.com/archive.key | sudo apt-key add -

				echo -e "Ajout du dépôt officiel d'Opera"

				# Ajout du dépôt pour les mises à jour automatique
				# sudo add-apt-repository "deb [arch=i386,amd64] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera.l
				echo "deb [signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera-stable.list
				# sudo sh -c 'echo "deb http://deb.opera.com/opera-stable/ stable non-free" >> /etc/apt/sources.list.d/opera.list'
				# sudo add-apt-repository -y 'deb https://deb.opera.com/opera-stable/ stable non-free'


				echo -e "Mise à jour système (sudo apt update) :\n"

				# Mise à jour de l'index des paquets avant installation
				sudo apt update

				echo -e "Installation d'Opera via APT\n"

				# Pour répondre de faon automatisée à la question de l'installation pour l'ajout du dépot	--> marche pas
				# echo "opera-stable opera-stable/upgrade boolean true" | sudo debconf-set-selections

				# Installation d Opera stable via apt
				sudo apt-get install -y opera-stable
			fi
		fi

	;;
	
	$TXT_SETUP_TYPE_SNAP)
	
	;;
	
	*)
	
	;;
esac


echo -e "Site officiel Opera des fichiers debs d'Opera										https://www.opera.com/fr/opera"
echo -e "Site officiel Opera des fichiers debs d'Opera GX									https://www.opera.com/fr/download#opera-gx"
echo -e ""


echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## OPERA ####################################
fi # if $INSTALL_OPERA; then

if $INSTALL_CLAMAV_DAEMON || $INSTALL_ALL; then
############################## MODELE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="ClamUI"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom de l'utilisateur actuel pour les chemins des dossiers utilisateurs
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
CLAMAV_USR_BIN_FILENAME="/usr/bin/app_bin_template"
CLAMAV_USR_SHARE_FOLDER="/usr/share/app_template"
# Chemins utilisateurs
CLAMAV_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER="$HOME_USER/.var/app/io.github.linx_systems.ClamUI/config/clamui"
CLAMAV_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER="/var/lib/flatpak/app/io.github.linx_systems.ClamUI"

CLAMAV_USR_BIN_FILENAME_FOUND=false
CLAMAV_USR_SHARE_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $CLAMAV_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $CLAMAV_USR_BIN_FILENAME existe !\n"; fi
	CLAMAV_USR_BIN_FILENAME_FOUND=true
	TAILLE_CLAMAV_USR_BIN_FILENAME=$(du -sh "$CLAMAV_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $CLAMAV_USR_BIN_FILENAME n'existe pas !\n"; fi
	CLAMAV_USR_BIN_FILENAME_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $CLAMAV_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $CLAMAV_USR_SHARE_FOLDER existe !\n"; fi
	CLAMAV_USR_SHARE_FOLDER_FOUND=true
	TAILLE_CLAMAV_USR_SHARE_FOLDER=$(du -sh "$CLAMAV_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $CLAMAV_USR_SHARE_FOLDER n'existe pas !\n"; fi
	CLAMAV_USR_SHARE_FOLDER_FOUND=false
fi



declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CLAM_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_CLAMUI_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$CLAMUI_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CLAMUI_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_CLAMUI_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$CLAMUI_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""



if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "                              Commentaires"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""






case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)

	
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $CLAMAV_USR_BIN_FILENAME_FOUND && $CLAMAV_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $CLAMAV_USR_BIN_FILENAME_FOUND || ! $CLAMAV_USR_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $CLAMAV_USR_BIN_FILENAME_FOUND && ! $CLAMAV_USR_SHARE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"

			sudo apt install clamav-daemon
			
			echo -e "Activation du daemon ClamAV avec la commande 'sudo systemctl enable clamav-daemon' :\n"
			
			sudo systemctl enable clamav-daemon
			
			echo -e "Lancement du daemon ClamAV avec la commande 'sudo systemctl start clamav-daemon' :\n"
			
			sudo systemctl start clamav-daemon
		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $CLAMAV_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER_FOUND && ! $CLAMAV_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL via $TXT_SETUP_TYPE_FLATPAK"
			
			
		fi	
	;;

	$TXT_SETUP_TYPE_SNAP)
	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## MODELE (FIN) #################################### 
fi # if $INSTALL_CLAMAV_DAEMON || $INSTALL_ALL; then


if $INSTALL_CLAMUI || $INSTALL_ALL; then
############################## MODELE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="ClamUI"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_FLATPAK

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom de l'utilisateur actuel pour les chemins des dossiers utilisateurs
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
CLAMUI_USR_BIN_FILENAME="/usr/bin/app_bin_template"
CLAMUI_USR_SHARE_FOLDER="/usr/share/app_template"
# Chemins utilisateurs
CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER="$HOME_USER/.var/app/io.github.linx_systems.ClamUI/config/clamui"
CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER="/var/lib/flatpak/app/io.github.linx_systems.ClamUI"

CLAMUI_USR_BIN_FILENAME_FOUND=false
CLAMUI_USR_SHARE_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $CLAMUI_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $CLAMUI_USR_BIN_FILENAME existe !\n"; fi
	CLAMUI_USR_BIN_FILENAME_FOUND=true
	TAILLE_CLAMUI_USR_BIN_FILENAME=$(du -sh "$CLAMUI_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $CLAMUI_USR_BIN_FILENAME n'existe pas !\n"; fi
	CLAMUI_USR_BIN_FILENAME_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $CLAMUI_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $CLAMUI_USR_SHARE_FOLDER existe !\n"; fi
	CLAMUI_USR_SHARE_FOLDER_FOUND=true
	TAILLE_CLAMUI_USR_SHARE_FOLDER=$(du -sh "$CLAMUI_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $CLAMUI_USR_SHARE_FOLDER n'existe pas !\n"; fi
	CLAMUI_USR_SHARE_FOLDER_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER existe !\n"; fi
	CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER_FOUND=true
	TAILLE_CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER=$(du -sh "$CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER n'existe pas !\n"; fi
	CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER existe !\n"; fi
	CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER_FOUND=true
	TAILLE_CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER=$(du -sh "$CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER n'existe pas !\n"; fi
	CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER_FOUND=false
fi

declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CLAM_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_CLAMUI_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$CLAMUI_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CLAMUI_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_CLAMUI_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$CLAMUI_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER
tableau[$tab_ind,chemin]=$CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER
tableau[$tab_ind,chemin]=$CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "                              Commentaires"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""



case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Contrôle et désinstallation d'une version existante via Flatpak
		if flatpak info io.github.linx_systems.ClamUI &> /dev/null; then
			echo -e "❌ L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Informations sur la version de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK"
			
			flatpak info io.github.linx_systems.ClamUI
			
			echo -e ""
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
			
			echo -e "Désinstallation de ClamUI via $TXT_SETUP_TYPE_FLATPAK en cours :\n"
			
			# Désinstallation Flatpak
			flatpak uninstall io.github.linx_systems.ClamUID
			
			echo -e "Suppression des données utilisateur de ClamUI"
			
			flatpak uninstall --delete-data io.github.linx_systems.ClamUID
			
			echo -e "Nettoyage des dépendances non utilisées de Flatpak :\n"
			
			flatpak uninstall --unused
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"			
		else
			echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK n'a été détectée !\n"
		fi	
	
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $CLAMUI_USR_BIN_FILENAME_FOUND && $CLAMUI_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $CLAMUI_USR_BIN_FILENAME_FOUND || ! $CLAMUI_USR_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $CLAMUI_USR_BIN_FILENAME_FOUND && ! $CLAMUI_USR_SHARE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
		# S'il manque tous les fichiers et/ou dossiers recherchés
		if $CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER_FOUND && $CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déjà installée via $TXT_SETUP_TYPE_FLATPAK !\n"
		
			echo -e "Informations sur la version installée :\n"
		
			flatpak info io.github.linx_systems.ClamUI
		
			echo -e ""
		fi
	
		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $CLAMUI_HOME_USER_VAR_APP_CLAMUI_CONFIG_CLAMUI_FOLDER_FOUND && ! $CLAMUI_VAR_LIB_FLATPAK_APP_CONFIG_CLAMUI_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL via $TXT_SETUP_TYPE_FLATPAK"

			flatpak -y install flathub io.github.linx_systems.ClamUI
		fi	
	;;

	$TXT_SETUP_TYPE_SNAP)
	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## MODELE (FIN) #################################### 
fi # if $INSTALL_CLAMUI || $INSTALL_ALL; then





if $INSTALL_VIRTUALBOX || $INSTALL_ALL; then
############################## VIRTUALBOX ####################################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="VirtualBox"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_DEB

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# DEB local
# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
VIRTUALBOX_LOCAL_DEB_FILENAME="virtualbox-7.2_7.2.6-172322~Ubuntu~questing_amd64.deb"
VIRTUALBOX_LOCAL_DEB_FOLDER="DEB"
VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$VIRTUALBOX_LOCAL_DEB_FOLDER
VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH=$VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH/$VIRTUALBOX_LOCAL_DEB_FILENAME

# Chemin du dossier apt pour contrôler sa présence
VIRTUALBOX_USR_BIN_FILENAME="/usr/bin/virtualbox"
VIRTUALBOX_USR_LIB_FOLDER="/usr/lib/virtualbox"
VIRTUALBOX_USR_SHARE_FOLDER="/usr/share/virtualbox"
# Booléens associés
VIRTUALBOX_DEB_FOLDER_FOUND=false
VIRTUALBOX_DEB_FILENAME_FOUND=false
VIRTUALBOX_EXISTING_APT_DPKG_FOUND=false
VIRTUALBOX_USR_BIN_FILENAME_FOUND=false
VIRTUALBOX_USR_LIB_FOLDER_FOUND=false
VIRTUALBOX_USR_SHARE_FOLDER_FOUND=false
VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH_FOUND=false
VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH_FOUND=false
# Tailles
TAILLE_VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH=""
TAILLE_VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH=""
TAILLE_VIRTUALBOX_USR_BIN_FILENAME=""
TAILLE_VIRTUALBOX_USR_LIB_FOLDER=""
TAILLE_VIRTUALBOX_USR_SHARE_FOLDER=""



# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH existe !\n"; fi
	VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH_FOUND=true
	TAILLE_VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH=$(du -sh "$VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH n'existe pas !\n"; fi
	VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH_FOUND=false
fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $VIRTUALBOX_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $VIRTUALBOX_USR_BIN_FILENAME existe !\n"; fi
	VIRTUALBOX_USR_BIN_FILENAME_FOUND=true
	TAILLE_VIRTUALBOX_USR_BIN_FILENAME=$(du -sh "$VIRTUALBOX_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $VIRTUALBOX_USR_BIN_FILENAME n'existe pas !\n"; fi
	VIRTUALBOX_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH existe !\n"; fi
	VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH_FOUND=true
	TAILLE_VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH=$(du -sh "$VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH n'existe pas !\n"; fi
	VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $VIRTUALBOX_USR_LIB_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VIRTUALBOX_USR_LIB_FOLDER existe !\n"; fi
	VIRTUALBOX_USR_LIB_FOLDER_FOUND=true
	TAILLE_VIRTUALBOX_USR_LIB_FOLDER=$(du -sh "$VIRTUALBOX_USR_LIB_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VIRTUALBOX_USR_LIB_FOLDER n'existe pas !\n"; fi
	VIRTUALBOX_USR_LIB_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $VIRTUALBOX_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VIRTUALBOX_USR_SHARE_FOLDER existe !\n"; fi
	VIRTUALBOX_USR_SHARE_FOLDER_FOUND=true
	TAILLE_VIRTUALBOX_USR_SHARE_FOLDER=$(du -sh "$VIRTUALBOX_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VIRTUALBOX_USR_SHARE_FOLDER n'existe pas !\n"; fi
	VIRTUALBOX_USR_SHARE_FOLDER_FOUND=false
fi	
		
if dpkg -l virtualbox 2> /dev/null | grep -q "^ii" ; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Un paquet dpkg de l'application TXT_APP_TO_INSTALL est déja présent !\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Aucun paquet dpkg de l'application TXT_APP_TO_INSTALL n'est présent !\n"; fi
fi

# Contrôle d'une version existante de VirtualBox via APT
if dpkg -l | grep virtualbox 2> /dev/null | grep -q "^ii" ; then
	if $SHOW_ANALYSE_LINES; then echo -e "Un paquet dpkg virtualbox est présent !\n"; fi
			
	VIRTUALBOX_EXISTING_APT_DPKG_FOUND=true
else
	if $SHOW_ANALYSE_LINES; then echo -e "Aucun paquet dpkg virtualbox n'a été détecté !\n"; fi
fi

# Test temporaire
declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH_FOUND
tableau[$tab_ind,taille]=$TAILLE_VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH
tableau[$tab_ind,chemin]=$VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH
tableau[$tab_ind,commentaires]="Dossier local des fichiers DEB"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH_FOUND
tableau[$tab_ind,taille]=$TAILLE_VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH
tableau[$tab_ind,chemin]=$VIRTUALBOX_LOCAL_DEB_FILENAME				# On affiche que le nom du fichier sinon ca dépasse dans le tableau
tableau[$tab_ind,commentaires]="Fichier local DEB d'installation via dpkg"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VIRTUALBOX_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_VIRTUALBOX_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$VIRTUALBOX_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Lien vers l'application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VIRTUALBOX_USR_LIB_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_VIRTUALBOX_USR_LIB_FOLDER
tableau[$tab_ind,chemin]=$VIRTUALBOX_USR_LIB_FOLDER
tableau[$tab_ind,commentaires]="Dossier des librairies"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VIRTUALBOX_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_VIRTUALBOX_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$VIRTUALBOX_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Extraire les premiers indices et trouver le max
indices=($(printf '%s\n' "${!tableau[@]}" | cut -d',' -f1 | sort -n))

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi


TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do

		# printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s| %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}" " ${tableau["$i,existe"]}" "  ${tableau["$i,taille"]}" " ${tableau["$i,chemin"]}" "${tableau["$i,commentaires"]}"
		#echo -e $TEXT_GREEN
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		#echo -e $TEXT_RESET
		
		#echo -e $TEXT_GREEN
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		
		
		#echo -e $TEXT_RESET
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"

		# echo -e "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s| %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}" " ${TEXT_GREEN}${tableau["$i,existe"]}${TEXT_RESET}" "  ${tableau["$i,taille"]}" " ${tableau["$i,chemin"]}" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_DEB)              
                if $VIRTUALBOX_USR_LIB_FOLDER_FOUND && $VIRTUALBOX_USR_SHARE_FOLDER_FOUND && $VIRTUALBOX_EXISTING_APT_DPKG_FOUND; then
			echo -e "Tous les fichiers et/ou dossiers recherchés ont été trouvés !\n"
			
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			dpkg -l virtualbox

			echo -e ""

			
                fi

                #echo -e "$VIRTUALBOX_USR_SHARE_FOLDER_FOUND"
                # echo -e "$VIRTUALBOX_DEB_FOLDER_FOUND"                
                # echo -e "$VIRTUALBOX_DEB_FILENAME_FOUND"
                
                if ! $VIRTUALBOX_USR_SHARE_FOLDER_FOUND && $VIRTUALBOX_LOCAL_DEB_FOLDER_FULLPATH_FOUND; then
                	echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via un fichier local $VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH :\n"
                	
                	sudo dpkg -i $VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH
                	
                	echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via un fichier local $VIRTUALBOX_LOCAL_DEB_FILENAME_FULLPATH !\n"
                fi
                
                echo -e "Début de l'ajout de l'utilisateur actuel '$REAL_USER' au groupe 'vboxusers' :\n"
                	
                sudo usermod -aG vboxusers $REAL_USER
                
                echo -e "Affichage des utilisateurs du groupe 'vboxusers' :\n"
                
                getent group vboxusers
                
                echo -e ""
                	
                echo -e "Fin de l'ajout de l'utilisateur actuel '$REAL_USER' au groupe 'vboxusers' !\n"                 

	;;
	# DEB - Fin setup type DEB

	$TXT_SETUP_TYPE_APT)               
                if $VIRTUALBOX_USR_LIB_FOLDER_FOUND && $VIRTUALBOX_USR_SHARE_FOLDER_FOUND && $VIRTUALBOX_EXISTING_APT_DPKG_FOUND; then
			echo -e "Tous les dossiers recherchés ont été trouvés !\n"
			
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			dpkg -l virtualbox

			echo -e ""

		        # Calcul de la taille du dossier installé
		        TAILLE_VIRTUALBOX_USR_LIB_FOLDER=$(du -sh "$VIRTUALBOX_USR_LIB_FOLDER" | cut -f1)

		        # Affichage console de la taille du dossier installé
		        echo -e "La taille du dossier $VIRTUALBOX_USR_LIB_FOLDER est : $TAILLE_VIRTUALBOX_USR_LIB_FOLDER\n"			
                fi
                
                if ! $VIRTUALBOX_USR_LIB_FOLDER_FOUND && ! $VIRTUALBOX_USR_SHARE_FOLDER_FOUND; then
                	VIRTUALBOX_DEB_FILENAME="virtualbox-7.2_7.2.6-172322~Ubuntu~questing_amd64.deb"
                
                	echo -e "Début de l'installation de $TXT_APP_TO_INSTALL en cours via $TXT_SETUP_TYPE_APT :\n"
                	
                	# sudo apt install virtualbox-7.2
                	sudo apt install -y virtualbox
                	
                	sudo dpkg --configure -a
                	
                	sudo apt --fixbroken install
                	
                	echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL en cours via $TXT_SETUP_TYPE_APT :\n"
                	
                	
             	
                fi
                
                echo -e "Début de l'ajout de l'utilisateur actuel '$REAL_USER' au groupe 'vboxusers' :\n"
                	
                sudo usermod -aG vboxusers $REAL_USER
                
                echo -e "Affichage des utilisateurs du groupe 'vboxusers' :\n"
                
                getent group vboxusers
                
                echo -e ""
                	
                echo -e "Fin de l'ajout de l'utilisateur actuel '$REAL_USER' au groupe 'vboxusers' !\n"   

	;;
	# APT - Fin setup type APT

	*)

	;;
esac

echo -e "Commandes intéressantes :\n"

echo -e "Si le groupe vboxusers n'existe pas, commande pour le créer						sudo groupadd vboxusers 2>/dev/null || true"
echo -e "Pour vérifier l'existence du groupe 'vboxusers' au système en affichant la liste des groupes		getent group"

echo -e "Site internet des debs des fichiers virtualbox			 					https://fr.archive.ubuntu.com/ubuntu/pool/multiverse/v/virtualbox/"


echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## VIRTUALBOX ####################################
fi # if $INSTALL_VIRTUALBOX; then


if $INSTALL_LUTRIS || $INSTALL_ALL; then
############################## LUTRIS ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Lutris"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_DEB

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom de l'utilisateur actuel pour les chemins des dossiers utilisateurs
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")

# Variables d'installation à partir d'un fichier local .deb
# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux 
LUTRIS_LOCAL_SCRIPT_DEB_FOLDER=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/"DEB"
LUTRIS_LOCAL_SCRIPT_DEB_FILENAME="lutris_0.5.22_all.deb"
LUTRIS_LOCAL_SCRIPT_DEB_FILEPATH=$LUTRIS_LOCAL_SCRIPT_DEB_FOLDER/$LUTRIS_LOCAL_SCRIPT_DEB_FILENAME
# Booléens
LUTRIS_LOCAL_SCRIPT_DEB_FILEPATH_FOUND=false
LUTRIS_DPKG_ALREADY_INSTALLED_LUTRIS_FOUND=false

# Chemins recherchés pour vérifier si déja installé via deb
LUTRIS_USR_SHARE_FOLDER="/usr/share/lutris"
LUTRIS_USR_SHARE_DOC_FOLDER="/usr/share/doc/lutris"
# Booléens
LUTRIS_USR_SHARE_FOLDER_FOUND=false
LUTRIS_USR_SHARE_FOLDER_DOC_FOUND=false
# Variables d'installation à partir d'un fichier local .deb (FIN)

# Variables d'installation Flatpak
# En mode system
LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER="/var/lib/flatpak/app/net.lutris.Lutris"
# En mode user
FLATPAK_LUTRIS_APP="net.lutris.Lutris"
LUTRIS_HOME_USER_FLATPAK_APP_FOLDER="$HOME_USER_FOLDER/.var/app/$FLATPAK_LUTRIS_APP"
# Initialisation des booléens
LUTRIS_VIA_FLATPAK_ALREADY_INSTALLED=false
LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND=false
# Tailles
TAILLE_LUTRIS_USR_SHARE_FOLDER=""
TAILLE_LUTRIS_USR_SHARE_DOC_FOLDER=""
TAILLE_LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER=""
TAILLE_LUTRIS_HOME_USER_FLATPAK_APP_FOLDER=""


# Variables d'installation Flatpak (FIN)



# Vérification d'une installation existante
if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante :\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_DEB :\n"; fi

# Recherche de fichiers / dossiers existants
if $SHOW_ANALYSE_LINES; then echo -e "Recherche d'un dossier $LUTRIS_USR_SHARE_FOLDER :\n"; fi

# Contrôle du dossier 
if Recherche_dossier $LUTRIS_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $LUTRIS_USR_SHARE_FOLDER existe !\n"; fi
	LUTRIS_USR_SHARE_FOLDER_FOUND=true
	TAILLE_LUTRIS_USR_SHARE_FOLDER=$(du -sh "$LUTRIS_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $LUTRIS_USR_SHARE_FOLDER n'existe pas !\n"; fi
	LUTRIS_USR_SHARE_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $LUTRIS_USR_SHARE_DOC_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $LUTRIS_USR_SHARE_DOC_FOLDER existe !\n"; fi
	LUTRIS_USR_SHARE_DOC_FOLDER_FOUND=true
	TAILLE_LUTRIS_USR_SHARE_DOC_FOLDER=$(du -sh "$LUTRIS_USR_SHARE_DOC_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $LUTRIS_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	LUTRIS_USR_SHARE_DOC_FOLDER_FOUND=false
fi


if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_DEB !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK :\n"; fi

# Recherche de fichiers / dossiers existants
if $SHOW_ANALYSE_LINES; then echo -e "Recherche d'un dossier $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER :\n"; fi

# Contrôle du dossier 
if Recherche_dossier $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER existe !\n"; fi
	LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=true
	TAILLE_LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER=$(du -sh "$LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER n'existe pas !\n"; fi
	LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Recherche d'un dossier $FLATPAK_LUTRIS_FOLDER :\n"; fi

# Controle du dossier 
if Recherche_dossier $LUTRIS_HOME_USER_FLATPAK_APP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $LUTRIS_HOME_USER_FLATPAK_APP_FOLDER existe !\n"; fi
	LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND=true
	TAILLE_LUTRIS_HOME_USER_FLATPAK_APP_FOLDER=$(du -sh "$LUTRIS_HOME_USER_FLATPAK_APP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $LLUTRIS_HOME_USER_FLATPAK_APP_FOLDER n'existe pas !\n"; fi
	LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND=false
fi

if flatpak list --app | grep -q net.lutris.Lutris; then
	if $SHOW_ANALYSE_LINES; then echo -e "il existe déja une version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"; fi
    	LUTRIS_VIA_FLATPAK_ALREADY_INSTALLED=true
else
	if $SHOW_ANALYSE_LINES; then echo -e "il n'existe pas de version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"; fi
    	LUTRIS_VIA_FLATPAK_ALREADY_INSTALLED=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK !\n"; fi

# Vérification d'une installation existante (FIN)

# Test temporaire
declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$LUTRIS_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_LUTRIS_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$LUTRIS_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install via DEB ou APT"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$LUTRIS_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_LUTRIS_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$LUTRIS_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install via DEB ou APT"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install via Flatpak en mode systeme"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_LUTRIS_HOME_USER_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$LUTRIS_HOME_USER_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install via Flatpak en mode user"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_DEB)
		echo -e "Début de la procédure d'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB :\n"
	
		# Si une installation exisante via Flatpak existe en mode 'system' ou 'user', la désinstaller
		if $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND || $LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
			echo -e "il existe déja une version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
						
			echo -e "Désinstallation totale de Flatpak via la commande 'flatpak uninstall net.lutris.Lutris' :\n"
			
			flatpak uninstall net.lutris.Lutris			
			
			echo -e "Désinstallation totale de Flatpak via la commande 'flatpak uninstall --delete-data --assumeyes net.lutris.Lutris' :\n"
			
			flatpak uninstall --delete-data --assumeyes net.lutris.Lutris
			
			echo -e "\n✅ Désinstallation totale de Flatpak via la commande 'flatpak uninstall --delete-data --assumeyes net.lutris.Lutris' terminée !\n"
			
			echo -e "Désinstallation des fichiers inutilisés de Flatpak via la commande 'flatpak uninstall --unused' :\n"
			
			flatpak uninstall --unused
			
			echo -e "\n✅ Désinstallation des fichiers inutilisés de Flatpak via la commande 'flatpak uninstall --unused' terminée !\n"
			
			echo -e "Nettoyage des fichiers orphelins de Flatpak :\n"
			
			flatpak uninstall --orphaned
			
			echo -e "\n✅ Nettoyage des fichiers orphelins de Flatpak terminé !\n"
			
			echo -e "Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
		fi
	

                if [ -d "$LUTRIS_LOCAL_SCRIPT_DEB_FOLDER" ]; then
                	echo -e "✅ Le dossier local à côté du script est présent !\n"
                else
                	echo -e "❌ Le dossier local à côté du script n'est pas présent !\n"
                fi
                
                if [ -f "$LUTRIS_LOCAL_SCRIPT_DEB_FILEPATH" ]; then
                	echo -e "✅ Le fichier local d'installation de $TXT_APP_TO_INSTALL appelé $LUTRIS_LOCAL_SCRIPT_DEB_FILENAME est présent !\n"
                	
                	LUTRIS_LOCAL_SCRIPT_DEB_FILEPATH_FOUND=true
                else
                	echo -e "❌ Le fichier local d'installation de $TXT_APP_TO_INSTALL appelé $LUTRIS_LOCAL_SCRIPT_DEB_FILENAME n'est pas présent !\n"
                fi
                
                
                # Contrôle d'une version déja installée via deb avec la commande dpkg
		if dpkg -l lutris >/dev/null 2>&1; then
		    	echo -e "✅ Lutris est déja installé via DEB ou APT !\n"
		    	
		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet installé
		        dpkg -l lutris

			echo -e ""    	
		    	
		    	LUTRIS_DPKG_ALREADY_INSTALLED_LUTRIS_FOUND=true
		else		
		    	echo -e "❌ Lutris n'est pas installé !\n"
		    	
		    	LUTRIS_DPKG_ALREADY_INSTALLED_LUTRIS_FOUND=false
		fi
		
		# Si déja installé 
		if $LUTRIS_DPKG_ALREADY_INSTALLED_LUTRIS_FOUND; then
			echo -e "Aucune installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT n'a été effectuée !\n"
		fi
		
		# Si le fichier local .deb est présent et que Lutris n'est pas installé
		if $LUTRIS_LOCAL_SCRIPT_DEB_FILEPATH_FOUND && ! $LUTRIS_DPKG_ALREADY_INSTALLED_LUTRIS_FOUND; then
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB :\n"
			
			echo -e "Installation via dpkg :\n"
			
			sudo dpkg -i $LUTRIS_LOCAL_SCRIPT_DEB_FILEPATH
			
			echo -e "Résolution des problèmes de dépendances nécessaires pour $TXT_APP_TO_INSTALL :\n"
			
			sudo apt -y install -f
			
			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB :\n"
			
			
		fi
		
		echo -e "Fin de la procédure d'installation de $TXT_APP_TO_INSTALL VIA $TXT_SETUP_TYPE_DEB !\n"
	;;

	$TXT_SETUP_TYPE_FLATPAK) # Procédure officielle : https://flathub.org/fr/apps/net.lutris.Lutris
		# Si une installation existante via APT, la désinstaller
		if $LUTRIS_USR_SHARE_FOLDER_FOUND; then
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
			
			echo -e "Désinstallation totale de $TXT_APP_TO_INSTALL via la commande 'sudo apt -y remove lutris' :\n"
			
			sudo apt -y remove lutris
			
			echo -e "\n✅ Désinstallation totale de $TXT_APP_TO_INSTALL via la commande 'sudo apt -y remove lutris' terminée !\n"
			
			echo -e "Désinstallation des fichiers inutilisés de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall --unused' :\n"
			
			sudo apt -y purge lutris
			
			echo -e "\n✅ Désinstallation des fichiers inutilisés de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall --unused' terminée !\n"
			
			echo -e "Nettoyage du système via la commande 'sudo apt -y autoremove' :\n"
			
			sudo apt -y autoremove
			
			echo -e "\n✅ Nettoyage du système via la commande 'sudo apt -y autoremove' terminé !\n"
			
			echo -e "Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"		
		
		fi
		


		# Si 1 des 2 dossiers dossier flatpak existe, il existe une installation de Lutris via Flatpak, soit en mode system (dossier var lib) soit en mode user (.var/app)
		# if [[ -n "$LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND" ]] ; then		# Le '-n' signifie : « Si la variable contient quelque chose (pas vide), alors... »
		if $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND || $LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
			echo -e "Contrôle de l'intérieur du dossier flatpak $TXT_APP_TO_INSTALL $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER :\n"

                        echo -e "Fin du contrôle de l'intérieur du dossier flatpak $TXT_APP_TO_INSTALL $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER :\n"

                        echo -e "Vérification de la présence de flatpak :\n"

                        # if [ dpkg flatpak -eq 0 ] ; then
                                # echo -e "Flatpak est présent pour installer $TXT_APP_TO_INSTALL !"
                        # else
                                # echo -e "Flatpak n'est pas présent pour installer $TXT_APP_TO_INSTALL"
                        # fi

			# Vérification de la présence de Flatpak (commande recommandée)
			# if $(command) exécute la commande et teste son code de sortie.
			# Si flatpak --version réussit (code de sortie 0), l’instruction if est vraie.
			# Si elle échoue (commande non trouvée), le code de sortie est 1 → if est faux.
			if flatpak --version >/dev/null 2>&1; then
				echo -e "✅ Flatpak est installé : $(flatpak --version) !\n"
			else
				echo -e "❌ Flatpak n'est pas installé !\n"
				
				echo -e "Début de l'installation de Flatpak (nécessaire pour installer $TXT_APP_TO_INSTALL) :\n"
				
				sudo apt install -y flatpak
				
				echo -e "✅ Fin de l'installation de Flatpak (nécessaire pour installer $TXT_APP_TO_INSTALL) !\n"
				
				echo -e "Ajout du dépôt Flathub nécessaire pour installer $TXT_APP_TO_INSTALL :\n"
				
				# Ajouter Flathub après installation
				flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
			fi

			if $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND; then
				echo -e "L'application $TXT_APP_TO_INSTALL est déja installée en mode 'system' !\n"
			fi

			if $LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
				echo -e "L'application $TXT_APP_TO_INSTALL est déja installée en mode 'user' !\n"
			fi

                        echo -e "Informations sur la version installée :\n"

                        # Affichage de la version du paquet Lutris installé via Flatpak
                        flatpak list --app | grep net.lutris.Lutris

                        echo -e ""

                        # Calcul de la taille du dossier installé
                        TAILLE_LUTRIS_HOME_USER_FLATPAK_APP_FOLDER=$(du -sh "$LUTRIS_HOME_USER_FLATPAK_APP_FOLDER" | cut -f1)

                        # Affichage console de la taille du dossier installé
                        echo -e "La taille du dossier $LUTRIS_HOME_USER_FLATPAK_APP_FOLDER est : $TAILLE_LUTRIS_HOME_USER_FLATPAK_APP_FOLDER\n"


		fi

		# Si aucun des dossiers n'a été trouvé
		if ! $LUTRIS_VAR_LIB_FLATPAK_APP_FOLDER_FOUND && ! $LUTRIS_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
			echo -e "Aucun des dossiers n'a été trouvé !\n"

                        echo -e "Installation de Lutris en mode system (user / system), user pose pb !\n"

                        flatpak install -y --system flathub net.lutris.Lutris       # https://flathub.org/fr/apps/net.lutris.Lutris (v0.5.22 le 10/03/2026)

		fi

	;;

	$TXT_SETUP_TYPE_DEB)

		# Affichage de la version installée
		dpkg -l lutris

		# sudo dpkg -i lutris_0.5.18_all.deb

	;;
	# DEB - Fin setup type DEB

	*)

	;;
esac

echo -e "Liens utiles et informations supplémentaires sur Lutris :\n"

echo -e "Lien Flathub de Lutris officiel : 						https://flathub.org/fr/apps/net.lutris.Lutris"
echo -e "Lien des dépôts Github de Lutris (deb zip tar.gz) : 				https://github.com/lutris/lutris/releases"
echo -e "Lien Github de Lutris desktop client : 						https://github.com/lutris/lutris"
echo -e ""
echo -e "Commandes APT :"
echo -e "- Désinstallation simple : 												sudo apt remove lutris"
echo -e "- Désinstallation automatisée :												sudo apt -y remove lutris"
echo -e "- Purge simple :													sudo apt purge lutris"
echo -e "- Purge automatisée :													sudo apt -y purge lutris"
echo -e "- Nettoyage système simple :												sudo apt autoremove"
echo -e "- Nettoyage système automatisée :											sudo apt -y autoremove"
echo -e ""
echo -e "Commandes Flatpak :"
echo -e "La version flatpak est actuellement la v0.5.22 le 18/03/2026 !"
echo -e ""
echo -e "Pour le désinstaller, utiliser la commande : 										flatpak uninstall net.lutris.Lutris"
echo -e "Pour le désinstaller, utiliser la commande en supprimant toutes les données et jeux : 					flatpak uninstall --delete-data net.lutris.Lutris"
echo -e "Pour le désinstaller, utiliser la commande en supprimant toutes les données et jeux (automatisée) : 			flatpak uninstall --delete-data --assumeyes net.lutris.Lutris"
echo -e "Pour supprimer également les dépôts ou extensions inutilisées :								flatpak uninstall --unused"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## LUTRIS ####################################
fi # if $INSTALL_LUTRIS; then


if $INSTALL_HANDBRAKE || $INSTALL_ALL; then
############################## HANDBRAKE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Handbrake"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom de l'utilisateur actuel pour les chemins des dossiers utilisateurs
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")


# Variables d'installation APT
HANDBRAKE_USR_BIN_FILENAME="/usr/bin/handbrake"
HANDBRAKE_USR_SHARE_FOLDER="/usr/share/doc/handbrake"
HANDBRAKE_USR_SHARE_APPLICATIONS_FOLDER="/usr/share/applications"
HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME="fr.handbrake.ghb.desktop"
HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH=$HANDBRAKE_USR_SHARE_APPLICATIONS_FOLDER/$HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME
# Variables d'installation APT (FIN)
# Variables d'installation Flatpak
# En mode system
HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER="/var/lib/flatpak/app/fr.handbrake.ghb"
# En mode user
FLATPAK_HANDBRAKE_APP="fr.handbrake.ghb"
HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER="$HOME_USER_FOLDER/.var/app/$FLATPAK_HANDBRAKE_APP"
# Variables d'installation Flatpak (FIN)
# Booléens associées
HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH_FOUND=false
HANDBRAKE_USR_BIN_FILENAME_FOUND=false
HANDBRAKE_USR_SHARE_FOLDER_FOUND=false
# Booléens Flatpak
HANDBRAKE_VIA_FLATPAK_ALREADY_INSTALLED=false
HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER_FOUND=false

# Variables d'installation Flatpak (FIN)




# Vérification d'une installation existante
if $SHOW_ANALYSE_LINES; then echo -e "Début de la vérification d'une installation existante via $TXT_SETUP_TYPE_APT :\n"; fi

# Recherche de fichiers / dossiers existants
if $SHOW_ANALYSE_LINES; then echo -e "Début de la recherche d'un fichier $HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH :\n"; fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH existe !\n"; fi
	HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH_FOUND=true
	TAILLE_HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH=$(du -sh "$HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH n'existe pas !\n"; fi
	HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la recherche d'un fichier $HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Début de la recherche d'un dossier $HANDBRAKE_USR_BIN_FILENAME :\n"; fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $HANDBRAKE_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $HANDBRAKE_USR_BIN_FILENAME existe !\n"; fi
	HANDBRAKE_USR_BIN_FILENAME_FOUND=true
	TAILLE_HANDBRAKE_USR_BIN_FILENAME=$(du -sh "$HANDBRAKE_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $HANDBRAKE_USR_BIN_FILENAME n'existe pas !\n"; fi
	HANDBRAKE_USR_BIN_FILENAME_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la recherche d'un dossier $HANDBRAKE_USR_BIN_FILENAME !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Début de de la recherche d'un dossier $HANDBRAKE_USR_SHARE_FOLDER :\n"; fi

# Controle du dossier 
if Recherche_dossier $HANDBRAKE_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HANDBRAKE_USR_SHARE_FOLDER existe !\n"; fi
	HANDBRAKE_USR_SHARE_FOLDER_FOUND=true
	TAILLE_HANDBRAKE_USR_SHARE_FOLDER=$(du -sh "$HANDBRAKE_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HANDBRAKE_USR_SHARE_FOLDER n'existe pas !\n"; fi
	HANDBRAKE_USR_SHARE_FOLDER_FOUND=false
fi


if $SHOW_ANALYSE_LINES; then echo -e "Fin de de la recherche d'un dossier $HANDBRAKE_USR_SHARE_FOLDER !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_APT !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK :\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Début de la recherche d'un dossier $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER :\n"; fi

# Controle du dossier 
if Recherche_dossier $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER existe !\n"; fi
	HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=true
	TAILLE_HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER=$(du -sh "$HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER n'existe pas !\n"; fi
	HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la recherche d'un dossier $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Début de la recherche d'un dossier $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER :\n"; fi

# Controle du dossier 
if Recherche_dossier $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER existe !\n"; fi
	HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER_FOUND=true
	TAILLE_HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER=$(du -sh "$HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER n'existe pas !\n"; fi
	HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la recherche d'un dossier $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK !\n"; fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH_FOUND
tableau[$tab_ind,taille]=$TAILLE_HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH
tableau[$tab_ind,chemin]=$HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH
tableau[$tab_ind,commentaires]="Dossier DEB ou APT"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HANDBRAKE_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_HANDBRAKE_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$HANDBRAKE_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Fichier DEB ou APT"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HANDBRAKE_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HANDBRAKE_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$HANDBRAKE_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]="Dossier DEB ou APT"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]="Dossier Flatpak"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]="Dossier Flatpak"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


# Installation selon le type demandé
case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK :\n"
		
		if $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER_FOUND && $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
			if flatpak list --app | grep -q fr.handbrake.ghb; then
				echo -e "❌ Il existe déja une version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"    	
			    	HANDBRAKE_VIA_FLATPAK_ALREADY_INSTALLED=true
			    	
			    	# COde de désisntallation
			else
				echo -e "✅ Il n'existe pas de version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"    	
			    	HANDBRAKE_VIA_FLATPAK_ALREADY_INSTALLED=false
			fi		
		fi
	
		echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK !\n"
	
                echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE :\n"
		
		# Analyse des fichiers et/ou dossiers recherchés
		if $HANDBRAKE_USR_BIN_FILENAME_FOUND && $HANDBRAKE_USR_SHARE_FOLDER_FOUND && $HANDBRAKE_USR_SHARE_APPLICATIONS_FILENAME_FULLPATH_FOUND ; then
		        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet Handbrake installé
		        dpkg -l handbrake

			echo -e ""

	                # Calcul de la taille du dossier installé
	                TAILLE_HANDBRAKE_USR_SHARE_FOLDER=$(du -sh "$HANDBRAKE_USR_SHARE_FOLDER" | cut -f1)

	                # Affichage console de la taille du dossier installé
	                echo -e "La taille du dossier $HANDBRAKE_USR_SHARE_FOLDER est : $TAILLE_HANDBRAKE_USR_SHARE_FOLDER\n"
	                
	                echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE !\n"
		fi
		
		if ! $HANDBRAKE_USR_BIN_FILENAME_FOUND || ! $HANDBRAKE_USR_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		
		fi
		
		if ! $HANDBRAKE_USR_BIN_FILENAME_FOUND && ! $HANDBRAKE_USR_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée !\n"
			
			echo -e "Installation de l'application $TXT_APP_TO_INSTALL"
			
			sudo apt -y install handbrake
		
		fi

	;;
	# APT - Fin du setup type APT

	$TXT_SETUP_TYPE_FLATPAK)
		# Si le dossier Flatpak existe en mode system ou user	
		if $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER_FOUND || $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"
		
			# Affichage de la version du paquet Handbrake installé via Flatpak
			# flatpak run --command=HandBrakeCLI fr.handbrake.ghb --version
			flatpak list --app | grep fr.handbrake.ghb

			echo -e ""

		        # Calcul de la taille du dossier installé
		        TAILLE_HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER=$(du -sh "$HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER" | cut -f1)

		        # Affichage console de la taille du dossier installé
		        echo -e "La taille du dossier $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER est : $TAILLE_HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER\n"

		        echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE !\n"
		fi
	
		# Si aucun des dossiers n'a été trouvé
		if ! $HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER_FOUND && ! $HANDBRAKE_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
		        echo -e "Vérification de la présence de Flatpak :\n"

		        if ! command -v flatpak &> /dev/null ; then
		                echo -e "❌ Flatpak n'est pas installé\n"

		                echo -e "Ajout du dépôt Flathub nécessaire pour installer $TXT_APP_TO_INSTALL"

		                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

		                echo -e "Installation de Flatpak en cours nécessaire pour installer $TXT_APP_TO_INSTALL"

		                sudo apt install -y flatpak
		        else
		                echo -e "✅ Flatpak est installé : $(flatpak --version) !\n"

		        fi			
		
		        echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE :\n"

			USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")

			FLATPAK_HANDBRAKE_APP="fr.handbrake.ghb"
			FLATPAK_HANDBRAKE_FOLDER="$USER_HOME/.var/app/$FLATPAK_HANDBRAKE_APP"
			
			# Chemins des dossiers Handbrake
			HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER="/var/lib/flatpak/app/fr.handbrake.ghb"

			if [ -d "$HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER" ]; then
				echo -e "✅ Le dossier '$HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER' existe !\n"



			else
				echo -e "❌ Le dossier '$HANDBRAKE_VAR_LIB_FLATPAK_APP_FOLDER' n'existe pas !\n"

				# Commande d'ajout du dépot d'Handbrake via Flatpak
				flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
				
				echo -e "Vérification de la présence de flatpak :"
				
				if ! command -v flatpak &> /dev/null; then
					echo -e "Flatpak n'est pas installé !\n"
				else
					echo -e "Flatpak est installé : $(flatpak --version) !\n"
				fi
				
				echo -e "Installation de Handbrake via Flatpak en mode system (pas user) :\n"
				
				flatpak --system install -y flathub fr.handbrake.ghb

				echo -e "Installation terminée !\n"
			fi
		fi
	;;
	# FLATPAK - Fin du setup type Flatpak

	*)
		echo -e "Aucune installation n'a été effectuée !\n" 
	;;
esac

echo -e "Informations supplémentaires sur Handbrake :\n"
echo -e "Lien du site internet officiel : 					https://handbrake.fr"
echo -e "Lien du Github : 							https://github.com/HandBrake/HandBrake/releases" # Au 10 mars 2026, la version Github est v1.11.0 alors que flathub est v1.10.2
echo -e "Lien de la page Wikipédia : 						https://fr.wikipedia.org/wiki/HandBrake"
echo -e ""
echo -e "Pour le désinstaller							sudo apt remove handrake"
echo -e "Ou le désinstaller (automatisée)					sudo apt -y remove handbrake"
echo -e "Pour nettoyer les fichiers restants après désinstallation		sudo apt purge handbrake"
echo -e "Pour nettoyage système							sudo apt autoremove"
echo -e "Ou nettoyage système (automatisée)					sudo apt -y autoremove"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## HANDBRAKE ####################################
fi # if $INSTALL_HANDBRAKE; then


if $INSTALL_HARDINFO || $INSTALL_ALL; then
############################## HARDINFO ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Hardinfo"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Variables d'installation à partir d'un fichier local .deb
# Chemins du fichier local .deb si installation
HARDINFO_LOCAL_SCRIPT_DEB_FOLDER="DEB_files"
HARDINFO_LOCAL_SCRIPT_DEB_FILENAME="hardinfo2_2.2.15-Ubuntu-25.10_amd64.deb"
HARDINFO_LOCAL_SCRIPT_DEB_FILEPATH=$HARDINFO_LOCAL_SCRIPT_DEB_FOLDER/$HARDINFO_LOCAL_SCRIPT_DEB_FILENAME
# Booléens
HARDINFO_LOCAL_SCRIPT_DEB_FILEPATH_FOUND=false
HARDINFO_DPKG_ALREADY_INSTALLED=false

# Chemins recherchés pour vérifier si déja installé via deb
HARDINFO_USR_BIN_FILENAME="/usr/bin/hardinfo2"
HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME="/usr/share/applications/hardinfo2.desktop"
HARDINFO_USR_SHARE_FOLDER="/usr/share/doc/hardinfo"
HARDINFO_USR_SHARE_HARDINFO2_FOLDER="/usr/share/doc/hardinfo2"
HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER="/usr/lib/x86_64-linux-gnu/hardinfo2"
HARDINFO_RUN_HARDINFO2_FOLDER="/run/hardinfo2"
# Booléens
HARDINFO_USR_SHARE_FOLDER_FOUND=false
HARDINFO_USR_BIN_FILENAME_FOUND=false
HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER_FOUND=false
HARDINFO_RUN_HARDINFO2_FOLDER_FOUND=false
HARDINFO_USR_SHARE_HARDINFO2_FOLDER_FOUND=false

# Variables d'installation Flatpak
HARDINFO_FLATPAK_ALREADY_INSTALLED=false





# Vérification d'une installation existante
if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante :\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_APT ou $TXT_SETUP_TYPE_DEB :\n"; fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $HARDINFO_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $HARDINFO_USR_BIN_FILENAME existe !\n"; fi
	HARDINFO_USR_BIN_FILENAME_FOUND=true
	TAILLE_HARDINFO_USR_BIN_FILENAME=$(du -sh "$HARDINFO_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $HARDINFO_USR_BIN_FILENAME n'existe pas !\n"; fi
	HARDINFO_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME existe !\n"; fi
	HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME_FOUND=true
	TAILLE_HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME=$(du -sh "$HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME n'existe pas !\n"; fi
	HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $HARDINFO_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HARDINFO_USR_SHARE_FOLDER existe !\n"; fi
	HARDINFO_USR_SHARE_FOLDER_FOUND=true
	TAILLE_HARDINFO_USR_SHARE_FOLDER=$(du -sh "$HARDINFO_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HARDINFO_USR_SHARE_FOLDER n'existe pas !\n"; fi
	HARDINFO_USR_SHARE_FOLDER_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $HARDINFO_USR_SHARE_HARDINFO2_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HARDINFO_USR_SHARE_HARDINFO2_FOLDER existe !\n"; fi
	HARDINFO_USR_SHARE_HARDINFO2_FOLDER_FOUND=true
	TAILLE_HARDINFO_USR_SHARE_HARDINFO2_FOLDER=$(du -sh "$HARDINFO_USR_SHARE_HARDINFO2_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HARDINFO_USR_SHARE_HARDINFO2_FOLDER n'existe pas !\n"; fi
	HARDINFO_USR_SHARE_HARDINFO2_FOLDER_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER existe !\n"; fi
	HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER_FOUND=true
	TAILLE_HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER=$(du -sh "$HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER n'existe pas !\n"; fi
	HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $HARDINFO_RUN_HARDINFO2_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $HARDINFO_RUN_HARDINFO2_FOLDER existe !\n"; fi
	HARDINFO_RUN_HARDINFO2_FOLDER_FOUND=true
	TAILLE_HARDINFO_RUN_HARDINFO2_FOLDER=$(du -sh "$HARDINFO_RUN_HARDINFO2_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $HARDINFO_RUN_HARDINFO2_FOLDER n'existe pas !\n"; fi
	HARDINFO_RUN_HARDINFO2_FOLDER_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_APT ou $TXT_SETUP_TYPE_DEB !\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK :\n"; fi

if flatpak --version >/dev/null 2>&1; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Flatpak est installé : $(flatpak --version) !\n"; fi
	
	if flatpak list --app | grep -q hardinfo; then
		if $SHOW_ANALYSE_LINES; then echo -e "Il existe déja une version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"; fi
	    	
	    	HARDINFO_FLATPAK_ALREADY_INSTALLED=true
	else
		if $SHOW_ANALYSE_LINES; then echo -e "Il n'existe pas de version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"; fi
	    	
	    	HARDINFO_FLATPAK_ALREADY_INSTALLED=false
	fi	
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Flatpak n'est pas installé !\n"; fi
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK !\n"; fi

# Vérification d'une installation existante (FIN)


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HARDINFO_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_HARDINFO_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$HARDINFO_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME
tableau[$tab_ind,chemin]=$HARDINFO_USR_SHARE_APPS_DESKTOP_FILENAME
tableau[$tab_ind,commentaires]="Fichier .destop pour le dock"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HARDINFO_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HARDINFO_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$HARDINFO_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]="Contient le copyright et changelog Hardinfo"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HARDINFO_USR_SHARE_HARDINFO2_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HARDINFO_USR_SHARE_HARDINFO2_FOLDER
tableau[$tab_ind,chemin]=$HARDINFO_USR_SHARE_HARDINFO2_FOLDER
tableau[$tab_ind,commentaires]="Contient le copyright et changelog Hardinfo2"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER
tableau[$tab_ind,chemin]=$HARDINFO_USR_LIB_X86_64_HARDINFO2_FOLDER
tableau[$tab_ind,commentaires]="Contient des fichiers modules .so"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$HARDINFO_RUN_HARDINFO2_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_HARDINFO_RUN_HARDINFO2_FOLDER
tableau[$tab_ind,chemin]=$HARDINFO_RUN_HARDINFO2_FOLDER
tableau[$tab_ind,commentaires]="Contient des fichiers txt de config"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


# Installation selon le type demandé
case $TXT_SETUP_TYPE in
        "$TXT_SETUP_TYPE_DEB")
		if [ -d "$HARDINFO_LOCAL_SCRIPT_DEB_FOLDER" ]; then
			echo -e "✅ Le dossier local à côté du script est présent !\n"
		else
			echo -e "❌ Le dossier local à côté du script n'est pas présent !\n"
		fi
				
		if [ -f "$HARDINFO_LOCAL_SCRIPT_DEB_FILEPATH" ]; then
			echo -e "✅ Le fichier local d'installation de $TXT_APP_TO_INSTALL appelé $HARDINFO_LOCAL_SCRIPT_DEB_FILENAME est présent !\n"
					
			HARDINFO_LOCAL_SCRIPT_DEB_FILEPATH_FOUND=true
		else
			echo -e "❌ Le fichier local d'installation de $TXT_APP_TO_INSTALL appelé $HARDINFO_LOCAL_SCRIPT_DEB_FILENAME n'est pas présent !\n"
		fi
                
                # Contrôle d'une version déja installée via deb avec la commande dpkg
		if dpkg -l hardinfo >/dev/null 2>&1; then
			echo -e "✅ $TXT_APP_TO_INSTALL a été détecté via la commande 'dpkg -l lutris' !\n"
		
		    	echo -e "✅ $TXT_APP_TO_INSTALL est déja installé dans le système APT !\n"
		    	
		    	HARDINFO_DPKG_ALREADY_INSTALLED=true
		else
			echo -e "❌ $TXT_APP_TO_INSTALL n'a pas été détecté via la commande 'dpkg -l lutris' !\n"
		
		    	echo -e "❌ $TXT_APP_TO_INSTALL n'est pas installé !\n"
		    	
		    	HARDINFO_DPKG_ALREADY_INSTALLED=false
		fi
		
		# Si le fichier local .deb est présent et que Hardinfo n'est pas installé
		if $HARDINFO_LOCAL_SCRIPT_DEB_FILEPATH_FOUND && ! $HARDINFO_DPKG_ALREADY_INSTALLED; then
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB :\n"
			
			echo -e "Installation via dpkg :\n"
			
			sudo dpkg -i $HARDINFO_LOCAL_SCRIPT_DEB_FILEPATH
			
			# echo -e "Résolution des problèmes de dépendances nécessaires pour $TXT_APP_TO_INSTALL :\n"
			
			# sudo apt -y install -f
			
			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB :\n"
			
			
		fi 		
        ;;

        "$TXT_SETUP_TYPE_APT")
        	# Si le fichier existe déja, on affiche les informations de la version
        	if $HARDINFO_USR_BIN_FILENAME_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet installé
			dpkg -l hardinfo

			# Saut de ligne après infos de version
			echo -e ""

			# Calcul de la taille du dossier installé
			TAILLE_HARDINFO_USR_SHARE_FOLDER=$(du -sh "$HARDINFO_USR_SHARE_FOLDER" | cut -f1)

			# Affichage console de la taille du dossier installé
			echo -e "La taille du dossier $HARDINFO_USR_SHARE_FOLDER est : $TAILLE_HARDINFO_USR_SHARE_FOLDER\n"        	
        	fi
        
        	# Si le fichier de l'appli n'existe pas, on l'installe
		if ! $HARDINFO_USR_BIN_FILENAME_FOUND; then
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
			
			sudo apt -y install --no-install-recommends hardinfo		# le --no-install répondra non à la question de l'installation de l'addon iperf3 lors de l'install d'hardinfo
			
			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
		fi
	;;
	# APT - Fin setup type

	*)
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## HARDINFO ####################################
fi # if $INSTALL_HARDINFO; then


if $INSTALL_STACER || $INSTALL_ALL; then
############################## STACER ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Stacer"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt de Stacer pour contrôler sa présence
STACER_USR_BIN_FILENAME="/usr/bin/stacer"
STACER_USR_SHARE_FOLDER="/usr/share/doc/stacer"



# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $STACER_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $STACER_USR_BIN_FILENAME existe !\n"; fi
	STACER_USR_BIN_FILENAME_FOUND=true
	TAILLE_STACER_USR_BIN_FILENAME=$(du -sh "$STACER_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $STACER_USR_BIN_FILENAME n'existe pas !\n"; fi
	STACER_USR_BIN_FILENAME_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $STACER_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STACER_USR_SHARE_FOLDER existe !\n"; fi
	STACER_USR_SHARE_FOLDER_FOUND=true
	TAILLE_STACER_USR_SHARE_FOLDER=$(du -sh "$STACER_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STACER_USR_SHARE_FOLDER n'existe pas !\n"; fi
	STACER_USR_SHARE_FOLDER_FOUND=false
fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STACER_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_STACER_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$STACER_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STACER_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_STACER_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$STACER_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""



case $TXT_SETUP_TYPE in
	"$TXT_SETUP_TYPE_APT")
		if $STACER_USR_SHARE_FOLDER_FOUND && $STACER_USR_BIN_FILENAME_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet installé
			dpkg -l stacer

			echo -e ""
		fi
		
		if ! $STACER_USR_SHARE_FOLDER_FOUND && ! $STACER_USR_BIN_FILENAME_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			
			sudo apt install -y stacer		
		fi
	;;
	# APT - Fin Setup type APT

        "$TXT_SETUP_TYPE_FLATPAK")

        ;;

	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## STACER ####################################
fi # if $INSTALL_STACER; then


if $INSTALL_SWEEPER || $INSTALL_ALL; then
############################## SWEEPER ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Sweeper"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
SWEEPER_USR_BIN_FILENAME="/usr/bin/sweeper"
SWEEPER_USR_SHARE_FOLDER="/usr/share/doc/sweeper"
# Booléens
SWEEPER_USR_BIN_FILENAME_FOUND=false
SWEEPER_USR_SHARE_FOLDER_FOUND=false
# Tailles
TAILLE_SWEEPER_USR_BIN_FILENAME=""
TAILLE_SWEEPER_USR_SHARE_FOLDER=""


# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $SWEEPER_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $SWEEPER_USR_BIN_FILENAME existe !\n"; fi
	SWEEPER_USR_BIN_FILENAME_FOUND=true
	TAILLE_SWEEPER_USR_BIN_FILENAME=$(du -sh "$SWEEPER_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $SWEEPER_USR_BIN_FILENAME n'existe pas !\n"; fi
	SWEEPER_USR_BIN_FILENAME_FOUND=false
fi


# Controle du dossier 
if Recherche_dossier $SWEEPER_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $SWEEPER_USR_SHARE_FOLDER existe !\n"; fi
	SWEEPER_USR_SHARE_FOLDER_FOUND=true
	TAILLE_SWEEPER_USR_SHARE_FOLDER=$(du -sh "$SWEEPER_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $SWEEPER_USR_SHARE_FOLDER n'existe pas !\n"; fi
	SWEEPER_USR_SHARE_FOLDER_FOUND=false
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$SWEEPER_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_SWEEPER_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$SWEEPER_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$SWEEPER_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_SWEEPER_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$SWEEPER_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	"$TXT_SETUP_TYPE_APT")
		if $SWEEPER_USR_SHARE_FOLDER_FOUND && $SWEEPER_USR_BIN_FILENAME_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"
			
			# Affichage de la version du paquet installé
			dpkg -l sweeper
			
			echo -e ""
		fi
		
		if ! $SWEEPER_USR_SHARE_FOLDER_FOUND && ! $SWEEPER_USR_BIN_FILENAME_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			
			sudo apt install -y sweeper		
		fi		
	;;
	
	*)
	
	;;
esac



echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## SWEEPER ####################################
fi # if $INSTALL_SWEEPER; then

if $INSTALL_GEDIT || $INSTALL_ALL; then
############################## GEDIT ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Gedit"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom de l'utilisateur actuel pour les chemins des dossiers utilisateurs
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")

# Variables d'installation APT
# Chemin des dossier APT pour contrôler leur présence
GEDIT_USR_BIN_FILENAME="/usr/bin/gedit"
GEDIT_USR_SHARE_FOLDER="/usr/share/gedit"
# Booléens associés
GEDIT_USR_BIN_FILENAME_FOUND=false
GEDIT_USR_SHARE_FOLDER_FOUND=true
# Variables d'installation APT (FIN)

# Variables d'installation Flatpak
# En mode system
GEDIT_VAR_LIB_FLATPAK_APP_FOLDER="/var/lib/flatpak/app/org.gnome.gedit"
# En mode user
FLATPAK_GEDIT_APP="org.gnome.gedit"
GEDIT_HOME_USER_FLATPAK_APP_FOLDER="$HOME_USER_FOLDER/.var/app/$FLATPAK_GEDIT_APP"
# Initialisation des booléens
GEDIT_VIA_FLATPAK_ALREADY_INSTALLED=false
GEDIT_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
GEDIT_HOME_USER_FLATPAK_APP_FOLDER_FOUND=false
# Variables d'installation Flatpak (FIN)
# Tailles
TAILLE_GEDIT_USR_BIN_FILENAME=""
TAILLE_GEDIT_USR_SHARE_FOLDER=""
TAILLE_GEDIT_VAR_LIB_FLATPAK_APP_FOLDER=""




if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante :\n"; fi

if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_APT :\n"; fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $GEDIT_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $GEDIT_USR_BIN_FILENAME existe !\n"; fi
	GEDIT_USR_BIN_FILENAME_FOUND=true
	TAILLE_GEDIT_USR_BIN_FILENAME=$(du -sh "$GEDIT_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $GEDIT_USR_BIN_FILENAME n'existe pas !\n"; fi
	GEDIT_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $GEDIT_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GEDIT_USR_SHARE_FOLDER existe !\n"; fi
	GEDIT_USR_SHARE_FOLDER_FOUND=true
	TAILLE_GEDIT_USR_SHARE_FOLDER=$(du -sh "$GEDIT_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GEDIT_USR_SHARE_FOLDER n'existe pas !\n"; fi
	GEDIT_USR_SHARE_FOLDER_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_APT !\n"; fi


if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK :\n"; fi

# Recherche de fichiers / dossiers existants
if $SHOW_ANALYSE_LINES; then echo -e "Recherche d'un dossier $GEDIT_VAR_LIB_FLATPAK_APP_FOLDER :\n"; fi

# Contrôle du dossier 
if Recherche_dossier $GEDIT_VAR_LIB_FLATPAK_APP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GEDIT_VAR_LIB_FLATPAK_APP_FOLDER existe !\n"; fi
	GEDIT_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=true
	TAILLE_GEDIT_VAR_LIB_FLATPAK_APP_FOLDER=$(du -sh "$GEDIT_VAR_LIB_FLATPAK_APP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GEDIT_VAR_LIB_FLATPAK_APP_FOLDER n'existe pas !\n"; fi
	GEDIT_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Recherche d'un dossier $FLATPAK_LUTRIS_FOLDER :\n"; fi

if [ -d "$GEDIT_HOME_USER_FLATPAK_APP_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier '$GEDIT_HOME_USER_FLATPAK_APP_FOLDER' existe !\n"; fi

	GEDIT_HOME_USER_FLATPAK_APP_FOLDER_FOUND=true
		
        if $SHOW_ANALYSE_LINES; then echo -e "Informations sur la version installée via FLatpak :\n"; fi

        # Affichage de la version du paquet Lutris installé via Flatpak
        flatpak list --app | grep net.lutris.Lutris

        echo -e ""
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier '$GEDIT_HOME_USER_FLATPAK_APP_FOLDER' n'existe pas !\n"; fi

	GEDIT_HOME_USER_FLATPAK_APP_FOLDER_FOUND=false
fi

if flatpak list --app | grep -q net.lutris.Lutris; then
	if $SHOW_ANALYSE_LINES; then echo -e "Il existe déja une version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"; fi
    	
    	GEDIT_VIA_FLATPAK_ALREADY_INSTALLED=true
else
	if $SHOW_ANALYSE_LINES; then echo -e "Il n'existe pas de version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"; fi
    	
    	GEDIT_VIA_FLATPAK_ALREADY_INSTALLED=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Fin de la vérification d'une installation existante via $TXT_SETUP_TYPE_FLATPAK !\n"; fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GEDIT_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_GEDIT_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$GEDIT_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GEDIT_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GEDIT_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$GEDIT_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GEDIT_VAR_LIB_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GEDIT_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$GEDIT_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GEDIT_HOME_USER_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GEDIT_HOME_USER_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$GEDIT_HOME_USER_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""



case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# On est en APT, si une installation exisante via Flatpak existe en mode 'system' ou 'user', la désinstaller
		if $GEDIT_VAR_LIB_FLATPAK_APP_FOLDER_FOUND || $GEDIT_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
			echo -e "il existe déja une version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
						
			echo -e "Désinstallation de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall $FLATPAK_GEDIT_APP' :\n"
			
			flatpak uninstall $FLATPAK_GEDIT_APP
			
			echo -e "\n✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall $FLATPAK_GEDIT_APP' :\n"			
			
			echo -e "Désinstallation totale de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall --delete-data --assumeyes $FLATPAK_GEDIT_APP' :\n"
			
			flatpak uninstall --delete-data --assumeyes $FLATPAK_GEDIT_APP
			
			echo -e "\n✅ Désinstallation totale de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall --delete-data --assumeyes $FLATPAK_GEDIT_APP' terminée !\n"
			
			echo -e "Désinstallation des fichiers inutilisés de Flatpak via la commande 'flatpak uninstall --unused' :\n"
			
			flatpak uninstall --unused
			
			echo -e "\n✅ Désinstallation des fichiers inutilisés de Flatpak via la commande 'flatpak uninstall --unused' terminée !\n"
						
			echo -e "Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
		fi	
	
	
		
		
		if $GEDIT_USR_BIN_FILENAME_FOUND && $GEDIT_USR_SHARE_FOLDER_FOUND ; then
		        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet installé
		        dpkg -l gedit			
		fi
		
		if ! $GEDIT_USR_BIN_FILENAME_FOUND && ! $GEDIT_USR_SHARE_FOLDER_FOUND ; then
		        echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !"
		        
		        echo -e "Début de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
		        
		        sudo apt install -y gedit
		        
		        echo -e "Fin de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
		fi	
	;;
	# APT - Fin setup type APT

	$TXT_SETUP_TYPE_FLATPAK)
		# On est en Flatpak, si une installation exisante via APT existe en mode 'system' ou 'user', la désinstaller
		if $GEDIT_USR_SHARE_FOLDER_FOUND || $GEDIT_USR_BIN_FILENAME_FOUND; then	
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
			
			echo -e "Désinstallation totale de $TXT_APP_TO_INSTALL via la commande 'sudo apt -y remove lutris' :\n"
			
			sudo apt -y remove gedit
			
			echo -e "\n✅ Désinstallation totale de $TXT_APP_TO_INSTALL via la commande 'sudo apt -y remove lutris' terminée !\n"
			
			echo -e "Désinstallation des fichiers inutilisés de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall --unused' :\n"
			
			sudo apt -y purge gedit
			
			echo -e "\n✅ Désinstallation des fichiers inutilisés de $TXT_APP_TO_INSTALL via la commande 'flatpak uninstall --unused' terminée !\n"
			
			echo -e "Nettoyage du système via la commande 'sudo apt -y autoremove' :\n"
			
			sudo apt -y autoremove
			
			echo -e "\n✅ Nettoyage du système via la commande 'sudo apt -y autoremove' terminé !\n"
			
			echo -e "Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"				
		fi
	
		echo -e "Début de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
			flatpak install flathub org.gnome.gedit	
			
		# Si aucun des dossiers Flatpak n'a été trouvé
		if ! $GEDIT_VAR_LIB_FLATPAK_APP_FOLDER_FOUND && ! $GEDIT_HOME_USER_FLATPAK_APP_FOLDER_FOUND; then
			echo -e "Aucun des dossiers n'a été trouvé !\n"

                        echo -e "Installation de Lutris en mode system (user / system), user pose pb !\n"

                        flatpak install -y --system flathub gedit

			echo -e ""
		fi
		
		echo -e "Fin de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
	;;
	# FLATPAK - Fin setup type FLATPAK
	
	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## GEDIT ####################################
fi # if $INSTALL_GEDIT; then

if $INSTALL_NOTEPAD_PLUS_PLUS || $INSTALL_ALL; then
############################## NOTEPAD++ ####################################
#################
# Installation via apt indisponible pour Notepad++ donc via snap

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Notepad++"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME="/snap/bin/notepad-plus-plus"
NOTEPAD_PLUS_PLUS_SNAP_FOLDER="/snap/notepad-plus-plus"
NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER="/var/snap/notepad-plus-plus"
NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER="/dev/shm/snap.notepad-plus-plus"
NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER="/run/user/1000/snap.notepad-plus-plus"
# Booléens associés
NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME_FOUND=false
NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND=false
NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER_FOUND=false
NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER_FOUND=false
NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER_FOUND=false
# Tailles
TAILLE_NOTEPAD_PLUS_PLUS_SNAP_FOLDER=""
TAILLE_NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER=""
TAILLE_NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER=""
TAILLE_NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER=""


# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME existe !\n"; fi
	
	NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME_FOUND=true
else
	if $SHOW_ANALYSE_LINES; then echo -e "Le fichier $NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME n'existe pas !\n"; fi
fi
		
if [ -d "$NOTEPAD_PLUS_PLUS_SNAP_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $NOTEPAD_PLUS_PLUS_SNAP_FOLDER existe !\n"; fi
	
	NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND=true
		        
	# Calcul de la taille du dossier installé
	TAILLE_NOTEPAD_PLUS_PLUS_SNAP_FOLDER=$(du -sh "$NOTEPAD_PLUS_PLUS_SNAP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $NOTEPAD_PLUS_PLUS_SNAP_FOLDER est : $TAILLE_NOTEPAD_PLUS_PLUS_SNAP_FOLDER\n"; fi		        
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $NOTEPAD_PLUS_PLUS_SNAP_FOLDER n'existe pas !\n"; fi
	
	NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND=false
fi		
		
if [ -d "$NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER existe !\n"; fi
	
	NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER_FOUND=true
		        
	# Calcul de la taille du dossier installé
	TAILLE_NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER=$(du -sh "$NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER est : $TAILLE_NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER\n"; fi		        
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER n'existe pas !\n"; fi
	
	NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER_FOUND=false
fi
		
if [ -d "$NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER existe !\n"; fi
	
	NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER_FOUND=true
		        
	# Calcul de la taille du dossier installé
	TAILLE_NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER=$(du -sh "$NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER est : $TAILLE_NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER\n"; fi			        
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER n'existe pas !\n"; fi
	
	NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER_FOUND=false
fi
		
if [ -d "$NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER existe !\n"; fi
	
	NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER_FOUND=true
		        
	# Calcul de la taille du dossier installé
	TAILLE_NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER=$(du -sh "$NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER est : $TAILLE_NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER\n"; fi			        
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER n'existe pas !\n"; fi
	NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER_FOUND=false
fi



declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME
tableau[$tab_ind,chemin]=$NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_NOTEPAD_PLUS_PLUS_SNAP_FOLDER
tableau[$tab_ind,chemin]=$NOTEPAD_PLUS_PLUS_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER
tableau[$tab_ind,chemin]=$NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER
tableau[$tab_ind,chemin]=$NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER
tableau[$tab_ind,chemin]=$NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_SNAP)
		# Analyse des fichiers et dossiers recherchés 
		echo -e "Analyse des résultats des fichiers et dossiers recherchés :\n"
		
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME_FOUND && $NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND && $NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER_FOUND && $NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER_FOUND && $NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER_FOUND; then
		        echo -e "Tous les fichiers et/ou dossiers recherchés ont été trouvés !\n"
		        
		        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet FWUPD installé
		        snap list | grep notepad-plus-plus		
		fi
		
		if $NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME_FOUND && $NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND && $NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER_FOUND && $NOTEPAD_PLUS_PLUS_DEV_SHM_SNAP_FOLDER_FOUND && ! $NOTEPAD_PLUS_PLUS_RUN_USER_1000_SNAP_FOLDER_FOUND; then
		        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP mais n'a jamais été lancée !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet FWUPD installé
		        snap list | grep notepad-plus-plus				
		fi
		
		# S'il manque un fichier et/ou dossier recherché
		if ! $NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME_FOUND || ! $NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND ; then		
			echo -e "Il manque un fichier ou un dossier à l'installation"
			
			echo -e "Installation corrompue ! Suite pas codée !\n"
		fi
		
		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $NOTEPAD_PLUS_PLUS_SNAP_BIN_FILENAME_FOUND && ! $NOTEPAD_PLUS_PLUS_SNAP_FOLDER_FOUND && ! $NOTEPAD_PLUS_PLUS_VAR_SNAP_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée !\n"
			
			echo -e "Début de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
		        
		        sudo snap install notepad-plus-plus
		        
		        echo -e "Fin de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
		fi	
	;;
	# SNAP - Fin setup type SNAP

	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## NOTEPAD++ ####################################
fi # if $INSTALL_NOTEPAD_PLUS_PLUS; then


if $INSTALL_CENTRE_DE_MISSION || $INSTALL_ALL; then
############################## CENTRE DE MISSION ####################################
#################
# Installation via apt indisponible pour Mission Center donc via snap

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Centre de mission"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET



# Chemin du dossier apt pour contrôler sa présence
MISSION_CENTER_SNAP_BIN_FILENAME="/snap/bin/mission-center"
MISSION_CENTER_SNAP_FOLDER="/snap/mission-center"
# Booléens		
MISSION_CENTER_SNAP_BIN_FILENAME_FOUND=false
MISSION_CENTER_SNAP_FOLDER_FOUND=false
# Tailles
TAILLE_MISSION_CENTER_SNAP_BIN_FILENAME=""
TAILLE_MISSION_CENTER_SNAP_FOLDER=""


# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$MISSION_CENTER_SNAP_BIN_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $MISSION_CENTER_SNAP_BIN_FILENAME existe !\n"; fi
        MISSION_CENTER_SNAP_BIN_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_MISSION_CENTER_SNAP_BIN_FILENAME=$(du -sh "$MISSION_CENTER_SNAP_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $MISSION_CENTER_SNAP_BIN_FILENAME est : $TAILLE_MISSION_CENTER_SNAP_BIN_FILENAME\n"; fi	
else
        if $SHOW_ANALYSE_LINES; then echo -e "Le fichier $MISSION_CENTER_SNAP_BIN_FILENAME n'existe pas !\n"; fi        
        MISSION_CENTER_SNAP_BIN_FILENAME_FOUND=false
fi
		
if [ -d "$MISSION_CENTER_SNAP_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $MISSION_CENTER_SNAP_FOLDER existe !\n"; fi
        MISSION_CENTER_SNAP_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_MISSION_CENTER_SNAP_FOLDER=$(du -sh "$MISSION_CENTER_SNAP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $MISSION_CENTER_SNAP_FOLDER est : $TAILLE_MISSION_CENTER_SNAP_FOLDER\n"; fi	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $MISSION_CENTER_SNAP_FOLDER n'existe pas !\n"; fi
        MISSION_CENTER_SNAP_FOLDER_FOUND=false
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$MISSION_CENTER_SNAP_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_MISSION_CENTER_SNAP_BIN_FILENAME
tableau[$tab_ind,chemin]=$MISSION_CENTER_SNAP_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$MISSION_CENTER_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_MISSION_CENTER_SNAP_FOLDER
tableau[$tab_ind,chemin]=$MISSION_CENTER_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_SNAP)	
		if $MISSION_CENTER_SNAP_BIN_FILENAME_FOUND && $MISSION_CENTER_SNAP_FOLDER_FOUND ; then
		        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet FWUPD installé
		        snap list | grep mission-center
		        
		        echo -e ""
		fi
		
		if ! $MISSION_CENTER_SNAP_BIN_FILENAME_FOUND && ! $MISSION_CENTER_SNAP_FOLDER_FOUND ; then
		        echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

		        echo -e "Début de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
		        
		        sudo snap install mission-center
		        
		        echo -e "Fin de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
		fi		
	;;
	# SNAP - Fin setup type SNAP

	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## CENTRE DE MISSION ####################################
fi # if $INSTALL_CENTRE_DE_MISSION; then


if $INSTALL_GITHUB_DESKTOP || $INSTALL_ALL; then
############################## GITHUB DESKTOP ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Github Desktop"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_DEB

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom de l'utilisateur actuel pour les chemins des dossiers utilisateurs
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")

# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux 
GITHUB_DESKTOP_LOCAL_SCRIPT_DEB_SUBFOLDER="DEB"
GITHUB_DESKTOP_LOCAL_SCRIPT_DEB_FILENAME="GitHubDesktop-linux-amd64-3.4.13-linux1.deb"
GITHUB_DESKTOP_LOCAL_SCRIPT_DEB_FILEPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$GITHUB_DESKTOP_LOCAL_SCRIPT_DEB_SUBFOLDER/$GITHUB_DESKTOP_LOCAL_SCRIPT_DEB_FILENAME
# Booléens DEB
GITHUB_DESKTOP_LOCAL_SCRIPT_DEB_FILEPATH_FOUND=false
GITHUB_DESKTOP_DPKG_ALREADY_INSTALLED_GITHUB_DESKTOP_FOUND=false
# Variables d'installation à partir d'un fichier local .deb (FIN)

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
GITHUB_DESKTOP_USR_BIN_FILENAME="/usr/bin/github-desktop"								# Lien vers l'application
GITHUB_DESKTOP_USR_LIB_FOLDER="/usr/lib/github-desktop"									# Dossier contenant l'exécutable
GITHUB_DESKTOP_USR_LIB_APPFILENAME="/usr/lib/github-desktop/github-desktop"						# Exécutable
GITHUB_DESKTOP_USR_SHARE_FOLDER="/usr/share/doc/github-desktop"								# Dossier contenant le copyright GitHub
GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME="/usr/share/applications/github-desktop.desktop"				# Raccourci dock
GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024="/usr/share/icons/hicolor/1024x1024/apps/github-desktop.png"		# Icône 1024x1024
# Dossiers utilisateurs
# Récupération du répertoire utilisateur, dépend du nom d'utilisateur
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")
# Dossiers utilisateurs avec le vrai nom d'utilisateur
# Dossier des repos perso
GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER=$HOME_USER_FOLDER/"Documents/GitHub"				# Dossier des repos par défaut
# Dossiers cachés
GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER=$HOME_USER_FOLDER/".config/GitHub Desktop"
# Booléens associés
GITHUB_DESKTOP_USR_LIB_APPFILENAME_FOUND=false
GITHUB_DESKTOP_USR_BIN_FILENAME_FOUND=false
GITHUB_DESKTOP_USR_LIB_FOLDER_FOUND=false
GITHUB_DESKTOP_USR_SHARE_FOLDER_FOUND=false
GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME_FOUND=false
GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024_FOUND=false
# Booléens utilisateurs
GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER_FOUND=false
GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER_FOUND=false

# Contrôle de la présence des fichiers existants
if [ -f "$GITHUB_DESKTOP_USR_LIB_APPFILENAME" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $GITHUB_DESKTOP_USR_LIB_APPFILENAME existe !\n"; fi
        GITHUB_DESKTOP_USR_LIB_APPFILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_USR_LIB_APPFILENAME=$(du -sh "$GITHUB_DESKTOP_USR_LIB_APPFILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_USR_LIB_APPFILENAME est : $TAILLE_GITHUB_DESKTOP_USR_LIB_APPFILENAME\n"; fi	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $GITHUB_DESKTOP_USR_LIB_APPFILENAME n'existe pas !\n"; fi        
        GITHUB_DESKTOP_USR_LIB_APPFILENAME_FOUND=false
fi



if [ -f "$GITHUB_DESKTOP_USR_BIN_FILENAME" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $GITHUB_DESKTOP_USR_BIN_FILENAME existe !\n"; fi
        GITHUB_DESKTOP_USR_BIN_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_USR_BIN_FILENAME=$(du -sh "$GITHUB_DESKTOP_USR_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_USR_BIN_FILENAME est : $TAILLE_GITHUB_DESKTOP_USR_BIN_FILENAME\n"; fi  	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $GITHUB_DESKTOP_USR_BIN_FILENAME n'existe pas !\n"; fi        
        GITHUB_DESKTOP_USR_BIN_FILENAME_FOUND=false
fi

if [ -f "$GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME existe !\n"; fi
        GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME=$(du -sh "$GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME est : $TAILLE_GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME\n"; fi 	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME n'existe pas !\n"; fi        
        GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME_FOUND=false
fi

if [ -f "$GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024 existe !\n"; fi
        GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024=$(du -sh "$GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024 est : $TAILLE_GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024\n"; fi  	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024 n'existe pas !\n"; fi        
        GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024_FOUND=false
fi
# Contrôle de la présence des fichiers existants (FIN)

# Contrôle de la présence des dossiers existants
if [ -d "$GITHUB_DESKTOP_USR_LIB_FOLDER" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GITHUB_DESKTOP_USR_LIB_FOLDER existe !\n"; fi
        GITHUB_DESKTOP_USR_LIB_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_USR_LIB_FOLDER=$(du -sh "$GITHUB_DESKTOP_USR_LIB_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_USR_LIB_FOLDER est : $TAILLE_GITHUB_DESKTOP_USR_LIB_FOLDER\n"; fi 	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GITHUB_DESKTOP_USR_LIB_FOLDER n'existe pas !\n"; fi       
        GITHUB_DESKTOP_USR_LIB_FOLDER_FOUND=false
fi

if [ -d "$GITHUB_DESKTOP_USR_SHARE_FOLDER" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GITHUB_DESKTOP_USR_SHARE_FOLDER existe !\n"; fi
        GITHUB_DESKTOP_USR_SHARE_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_USR_SHARE_FOLDER=$(du -sh "$GITHUB_DESKTOP_USR_SHARE_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_USR_SHARE_FOLDER est : $TAILLE_GITHUB_DESKTOP_USR_SHARE_FOLDER\n"; fi  	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GITHUB_DESKTOP_USR_SHARE_FOLDER n'existe pas !\n"; fi
	GITHUB_DESKTOP_USR_SHARE_FOLDER_FOUND=false
fi

if [ -d "$GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER existe !\n"; fi
        GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER=$(du -sh "$GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER est : $TAILLE_GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER\n"; fi  	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER n'existe pas !\n"; fi
	GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER_FOUND=false
fi

if [ -d "$GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER" ] ; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER existe !\n"; fi
        GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER=$(du -sh "$GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER est : $TAILLE_GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER\n"; fi  	        
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER n'existe pas !\n"; fi
	GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER_FOUND=false
fi
# Contrôle de la présence des dossiers existants (FIN)

# Contrôle de la présence du paquet DPKG
if dpkg -l github-desktop &> /dev/null ; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le paquet dpkg de 'Github Desktop' a été détecté !\n"; fi
	GITHUB_DESKTOP_DPKG_ALREADY_INSTALLED_GITHUB_DESKTOP_FOUND=true
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le paquet dpkg de 'Github Desktop' n'a pas été détecté !\n"; fi
	GITHUB_DESKTOP_DPKG_ALREADY_INSTALLED_GITHUB_DESKTOP_FOUND=false
fi

# Test temporaire
declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_USR_LIB_APPFILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_USR_LIB_APPFILENAME
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_USR_LIB_APPFILENAME
tableau[$tab_ind,commentaires]="Executable"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_USR_LIB_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_USR_LIB_FOLDER
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_USR_LIB_FOLDER
tableau[$tab_ind,commentaires]="Libraires"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Lien vers l'application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]="Dossier contenant le fichier copyright"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_HOME_USER_CONFIG_GITHUB_FOLDER
tableau[$tab_ind,commentaires]="Dossier cache de configuration"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER
tableau[$tab_ind,commentaires]="Dossier par defaut des repos perso"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_USR_SHARE_APPS_DESKTOP_FILENAME
tableau[$tab_ind,commentaires]="Fichier raccourci dock .desktop"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024_FOUND
tableau[$tab_ind,taille]=$TAILLE_GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024
tableau[$tab_ind,chemin]=$GITHUB_DESKTOP_USR_SHARE_ICONS_HICOLOR_1024
tableau[$tab_ind,commentaires]="Icone 1024x1024 de l'application"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_DEB)
		if $GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER_FOUND; then
			echo -e "Le dossier par défaut '$GITHUB_DESKTOP_HOME_USER_DOCUMENTS_GITHUB_FOLDER' des repos perso de Github Desktop a été trouvé !\n"
		fi
	
		if $GITHUB_DESKTOP_USR_BIN_FILENAME_FOUND && $GITHUB_DESKTOP_USR_LIB_FOLDER_FOUND && $GITHUB_DESKTOP_USR_SHARE_FOLDER_FOUND && $GITHUB_DESKTOP_DPKG_ALREADY_INSTALLED_GITHUB_DESKTOP_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT ou $TXT_SETUP_TYPE_DEB !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet installé
			dpkg -l github-desktop		
		fi
	
		if ! $GITHUB_DESKTOP_USR_BIN_FILENAME_FOUND && ! $GITHUB_DESKTOP_USR_LIB_FOLDER_FOUND && ! $GITHUB_DESKTOP_USR_SHARE_FOLDER_FOUND && ! $GITHUB_DESKTOP_DPKG_ALREADY_INSTALLED_GITHUB_DESKTOP_FOUND; then
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB :\n"
			
			sudo dpkg -i $GITHUB_DESKTOP_LOCAL_SCRIPT_DEB_FILEPATH
			
			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB !\n"		
		fi
	;;

	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $GITHUB_DESKTOP_USR_BIN_FILENAME_FOUND && $GITHUB_DESKTOP_USR_LIB_FOLDER_FOUND && $GITHUB_DESKTOP_USR_SHARE_FOLDER_FOUND && $GITHUB_DESKTOP_DPKG_ALREADY_INSTALLED_GITHUB_DESKTOP_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT ou $TXT_SETUP_TYPE_DEB !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet installé
			dpkg -l github-desktop		
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $APPNAME_BIN_FILENAME_FOUND || ! $APPNAME_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $APPNAME_BIN_FILENAME_FOUND && ! $APPNAME_SHARE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi	
	;;
	
	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## GITHUB DESKTOP (FIN) #################################### 
fi # if $INSTALL_GITHUB_DESKTOP || $INSTALL_ALL; then





if $INSTALL_VLC || $INSTALL_ALL; then
############################## VLC ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="VLC"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
# Chemins DEB ou APT
VLC_BIN_FILENAME="/usr/bin/vlc"
VLC_SHARE_FOLDER="/usr/share/vlc"
# Chemins SNAP
VLC_SNAP_VLC_FOLDER="/snap/vlc"
# Chemins Flatpak
VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER="/var/lib/flatpak/app/org.videolan.VLC"
VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER="/var/lib/flatpak/runtime/org.videolan.VLC.Locale"
		
# Initialisation des booléens
# Booléens DEB ou APT
VLC_BIN_FILENAME_FOUND=false
VLC_SHARE_FOLDER_FOUND=false
# Booléens SNAP
VLC_SNAP_VLC_FOLDER_FOUND=false
# Booléens Flatpak
VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER_FOUND=false
VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER_FOUND=false
# Tailles
TAILLE_VLC_BIN_FILENAME=""
TAILLE_VLC_SHARE_FOLDER=""
TAILLE_VLC_SNAP_VLC_FOLDER=""
TAILLE_VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER=""
TAILLE_VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER=""


# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$VLC_BIN_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $VLC_BIN_FILENAME existe !\n"; fi
	VLC_BIN_FILENAME_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_VLC_BIN_FILENAME=$(du -sh "$VLC_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $VLC_BIN_FILENAME est : $TAILLE_VLC_BIN_FILENAME\n"; fi 		
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $VLC_BIN_FILENAME n'existe pas !\n"; fi
	VLC_BIN_FILENAME_FOUND=false
fi
		
if [ -d "$VLC_SHARE_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VLC_SHARE_FOLDER existe !\n"; fi	                
        VLC_SHARE_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_VLC_SHARE_FOLDER=$(du -sh "$VLC_SHARE_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $VLC_SHARE_FOLDER est : $TAILLE_VLC_SHARE_FOLDER\n"; fi  
else	        
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VLC_SHARE_FOLDER n'existe pas !\n"; fi
        VLC_SHARE_FOLDER_FOUND=false
fi		

if [ -d "$VLC_SNAP_VLC_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VLC_SNAP_VLC_FOLDER existe !\n"; fi	                
        VLC_SNAP_VLC_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_VLC_SNAP_VLC_FOLDER=$(du -sh "$VLC_SNAP_VLC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $VLC_SNAP_VLC_FOLDER est : $TAILLE_VLC_SNAP_VLC_FOLDER\n"; fi  
else	        
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VLC_SNAP_VLC_FOLDER n'existe pas !\n"; fi
        VLC_SNAP_VLC_FOLDER_FOUND=false
fi

if [ -d "$VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER existe !\n"; fi	                
        VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER=$(du -sh "$VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER est : $TAILLE_VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER\n"; fi  
else	        
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER n'existe pas !\n"; fi
        VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER_FOUND=false
fi

if [ -d "$VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER existe !\n"; fi	                
        VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER=$(du -sh "$VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER est : $TAILLE_VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER\n"; fi  
else	        
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER n'existe pas !\n"; fi
        VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER_FOUND=false
fi

# Test temporaire
declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VLC_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_VLC_BIN_FILENAME
tableau[$tab_ind,chemin]=$VLC_BIN_FILENAME
tableau[$tab_ind,commentaires]="Dossier d'install via DEB ou APT"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VLC_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_VLC_SHARE_FOLDER
tableau[$tab_ind,chemin]=$VLC_SHARE_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install via DEB ou APT"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VLC_SNAP_VLC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_VLC_SNAP_VLC_FOLDER
tableau[$tab_ind,chemin]=$VLC_SNAP_VLC_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install Snap"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER
tableau[$tab_ind,chemin]=$VLC_VAR_LIB_FLATPAK_APP_VLC_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install Flatpak"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER
tableau[$tab_ind,chemin]=$VLC_VAR_LIB_FLATPAK_RUNTIME_VLC_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'install Flatpak du runtime"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Extraire les premiers indices et trouver le max
# indices=($(printf '%s\n' "${!tableau[@]}" | cut -d',' -f1 | sort -n))

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""



case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)

		# Contrôle d'une version existante et désinstallation de VLC via flatpak
		VLC_FLATPAK_APP_ID="org.videolan.VLC"

		if flatpak info "$VLC_FLATPAK_APP_ID" &>/dev/null; then

			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
			
			flatpak uninstall -y org.videolan.VLC
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"			
		else
			echo -e "✅ Il n'existe pas version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
		fi		

		# Contrôle d'une version existante et désinstallation de VLC via Snap	
		VLC_SNAP_APP_ID="vlc"

		if snap list | grep -q "vlc"; then
			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP !\n"
		
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
		
			sudo snap remove vlc
			
			echo -e ""
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"
		else
			echo -e "✅ Il n'existe pas version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP !\n"
		fi
		# Fin du contrôle d'une version existante et désinstallation de VLC via Snap


		
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $VLC_BIN_FILENAME_FOUND && $VLC_SHARE_FOLDER_FOUND ; then
			
			# Contrôle de la bonne installation de VLC via APT en scrutant le 'ii' du paquet dpkg
			if dpkg -l vlc 2> /dev/null | grep -q "^ii" ; then
				echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"

				echo -e "Informations sur la version installée :\n"

				# Affichage de la version du paquet installé
				dpkg -l vlc
				
				echo -e ""				
			else
				echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée !\n"
				
				echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
				
				sudo apt install vlc -y
				
				echo -e ""
				
				echo -e "✅ Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
			fi
			

		fi
		
		# Si aucun des fichiers et/ou dossiers recherchés ont été trouvés
		if ! $VLC_BIN_FILENAME_FOUND && ! $VLC_SHARE_FOLDER_FOUND ; then
		        echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
				
			sudo apt install vlc -y
			
			echo -e ""
				
			echo -e "✅ Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
		fi		

	;;
	# APT - Fin setup type APT
	
	$TXT_SETUP_TYPE_FLATPAK)
		# Contrôle et désinstallation d'une version existante via APT
		if dpkg -l vlc 2> /dev/null | grep -q "^ii" ; then
			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
			
			echo -e "Début de la désinstallation de VLC via $TXT_SETUP_TYPE_APT : \n"
			
			sudo apt -y remove vlc
			
			sudo apt -y purge vlc
			
			sudo apt autoremove
			
			echo -e ""
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
		else
			echo -e "✅ Il n'existe pas de version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
		fi	
	
		# Contrôle d'une version existante et désinstallation de VLC via Snap	
		VLC_SNAP_APP_ID="vlc"

		if snap list | grep -q "vlc"; then
			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP !\n"
		
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
		
			sudo snap remove vlc
			
			echo -e ""
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"
		else
			echo -e "✅ Il n'existe pas version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_SNAP !\n"
		fi
		# Fin du contrôle d'une version existante et désinstallation de VLC via Snap	

		# Contrôle d'une version existante de VLC via flatpak
		VLC_FLATPAK_APP_ID="org.videolan.VLC"

		if flatpak info "$VLC_FLATPAK_APP_ID" &>/dev/null; then

			echo -e "✅ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
			
			flatpak info "$VLC_FLATPAK_APP_ID"
			
			echo -e ""
					
		else
			echo -e "❌ Il n'existe pas de version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
			
			flatpak -y install flathub org.videolan.VLC
			
			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"
		fi	
	;;
	
	$TXT_SETUP_TYPE_SNAP)
		# Contrôle et désinstallation d'une version existante via APT
		if dpkg -l vlc 2> /dev/null | grep -q "^ii" ; then
			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
			
			echo -e "Début de la désinstallation de VLC via $TXT_SETUP_TYPE_APT : \n"
			
			sudo apt -y remove vlc
			
			sudo apt -y purge vlc
			
			sudo apt autoremove
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
		else
			echo -e "✅ Il n'existe pas de version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
		fi
		
		# Contrôle d'une version existante de VLC via flatpak
		VLC_FLATPAK_APP_ID="org.videolan.VLC"

		if flatpak info "$VLC_FLATPAK_APP_ID" &>/dev/null; then

			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"
			
			flatpak uninstall -y org.videolan.VLC
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"			
		else
			echo -e "✅ Il n'existe pas de version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
		fi
		
		# Contrôle d'une version existante et installation de VLC via Snap
		if snap list | grep -q "vlc"; then
			echo -e "✅ $TXT_APP_TO_INSTALL est déjà installé via Snap !\n"
			
			echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
			
			snap info vlc
			
			echo -e ""
		else
			echo "$TXT_APP_TO_INSTALL n'est pas installé via Snap."
			
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
			
			sudo snap install vlc
			
			echo -e "✅ Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"
		fi
	
		
	;;

	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## VLC ####################################
fi # if $INSTALL_VLC; then


if $INSTALL_GIMP || $INSTALL_ALL; then
############################## GIMP ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Gimp"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
GIMP_USR_BIN_FILENAME="/usr/bin/gimp"
GIMP_USR_SHARE_FOLDER="/usr/share/gimp"
GIMP_USR_SHARE_DOC_FOLDER="/usr/share/doc/gimp"
GIMP_ETC_FOLDER="/etc/gimp"
		
# Initialisation des booléens
GIMP_USR_BIN_FILENAME_FOUND=false
GIMP_USR_SHARE_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$GIMP_USR_BIN_FILENAME" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $GIMP_USR_BIN_FILENAME existe !\n"; fi		
	GIMP_USR_BIN_FILENAME_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_GIMP_USR_BIN_FILENAME=$(du -sh "$GIMP_USR_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GIMP_USR_BIN_FILENAME est : $TAILLE_GIMP_USR_BIN_FILENAME\n"; fi  	
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $GIMP_USR_BIN_FILENAME n'existe pas !\n"; fi	
	GIMP_USR_BIN_FILENAME_FOUND=false
fi
		
if [ -d "$GIMP_USR_SHARE_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GIMP_USR_SHARE_FOLDER existe !\n"; fi	
	GIMP_USR_SHARE_FOLDER_FOUND=true

	# Calcul de la taille du dossier installé
	TAILLE_GIMP_USR_SHARE_FOLDER=$(du -sh "$GIMP_USR_SHARE_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GIMP_USR_SHARE_FOLDER est : $TAILLE_GIMP_USR_SHARE_FOLDER\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GIMP_USR_SHARE_FOLDER n'existe pas !\n"; fi	
	GIMP_USR_SHARE_FOLDER_FOUND=false
fi

if [ -d "$GIMP_USR_SHARE_DOC_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GIMP_USR_SHARE_DOC_FOLDER existe !\n"; fi	
	GIMP_USR_SHARE_DOC_FOLDER_FOUND=true

	# Calcul de la taille du dossier installé
	TAILLE_GIMP_USR_SHARE_DOC_FOLDER=$(du -sh "$GIMP_USR_SHARE_DOC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GIMP_USR_SHARE_DOC_FOLDER est : $TAILLE_GIMP_USR_SHARE_DOC_FOLDER\n"; fi  	
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GIMP_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi	
	GIMP_USR_SHARE_DOC_FOLDER_FOUND=false
fi

if [ -d "$GIMP_ETC_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $GIMP_ETC_FOLDER existe !\n"; fi	
	GIMP_ETC_FOLDER_FOUND=true

	# Calcul de la taille du dossier installé
	TAILLE_GIMP_ETC_FOLDER=$(du -sh "$GIMP_ETC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $GIMP_ETC_FOLDER est : $TAILLE_GIMP_ETC_FOLDER\n"; fi  	
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $GIMP_ETC_FOLDER n'existe pas !\n"; fi	
	GIMP_ETC_FOLDER_FOUND=false
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GIMP_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_GIMP_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$GIMP_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GIMP_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GIMP_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$GIMP_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GIMP_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GIMP_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$GIMP_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$GIMP_ETC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_GIMP_ETC_FOLDER
tableau[$tab_ind,chemin]=$GIMP_ETC_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers  ont été trouvés	
		if $GIMP_USR_BIN_FILENAME_FOUND && $GIMP_USR_SHARE_FOLDER_FOUND && $GIMP_USR_SHARE_DOC_FOLDER_FOUND && $GIMP_ETC_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet installé
			dpkg -l gimp
			
			echo -e ""
		fi
		
		# Si aucun des fichiers et/ou dossiers  ont été trouvés
		if ! $GIMP_USR_BIN_FILENAME_FOUND && ! $GIMP_USR_SHARE_FOLDER_FOUND && ! $GIMP_USR_SHARE_DOC_FOLDER_FOUND && ! $GIMP_ETC_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			
			sudo apt install -y gimp
		fi		
	;;
	
	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## GIMP ####################################
fi # if $INSTALL_GIMP; then

if $INSTALL_FREECAD || $INSTALL_ALL; then
############################## FREECAD ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="FreeCAD"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
FREECAD_USR_BIN_FILENAME="/usr/bin/freecad"
FREECAD_USR_SHARE_FOLDER="/usr/share/freecad"
# Booléens associés
FREECAD_USR_BIN_FILENAME_FOUND=false
FREECAD_USR_SHARE_FOLDER_FOUND=false

if [ -d "$FREECAD_USR_SHARE_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $FREECAD_USR_SHARE_FOLDER existe !\n"; fi
	FREECAD_USR_SHARE_FOLDER_FOUND=true

	# Calcul de la taille du dossier installé
	TAILLE_FREECAD_USR_SHARE_FOLDER=$(du -sh "$FREECAD_USR_SHARE_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $FREECAD_USR_SHARE_FOLDER est : $TAILLE_FREECAD_USR_SHARE_FOLDER\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $FREECAD_USR_SHARE_FOLDER n'existe pas !\n"; fi
	FREECAD_USR_SHARE_FOLDER_FOUND=false
fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$FREECAD_USR_BIN_FILENAME" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $FREECAD_USR_BIN_FILENAME existe !\n"; fi
	FREECAD_USR_BIN_FILENAME_FOUND=true
	
	# Calcul de la taille du fichier/dossier installé
	TAILLE_FREECAD_USR_BIN_FILENAME=$(du -sh "$FREECAD_USR_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du fichier/dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $FREECAD_USR_BIN_FILENAME est : $TAILLE_FREECAD_USR_BIN_FILENAME\n"; fi	
else
	if $SHOW_ANALYSE_LINES; then echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"; fi
	FREECAD_USR_BIN_FILENAME_FOUND=false
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FREECAD_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_FREECAD_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$FREECAD_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FREECAD_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_FREECAD_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$FREECAD_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		if $FREECAD_USR_BIN_FILENAME_FOUND && $FREECAD_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet FreeCAD installé
			dpkg -l freecad		
		fi

		if ! $FREECAD_USR_BIN_FILENAME_FOUND && ! $FREECAD_USR_SHARE_FOLDER_FOUND; then
		        echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

		        echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
		        
		        sudo apt install -y freecad		
		fi
	;;
	# APT - Fin setup type APT

	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## FREECAD ####################################
fi # if $INSTALL_FREECAD; then


if $INSTALL_LIBREPCB || $INSTALL_ALL; then
############################## LIBREPCB ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="LibrePCB"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt de LibrePCB pour contrôler sa présence
LIBREPCB_USR_BIN_FILENAME="/usr/bin/librepcb"
LIBREPCB_USR_SHARE_FOLDER="/usr/share/librepcb"
LIBREPCB_USR_SHARE_DOC_FOLDER="/usr/share/doc/librepcb"
# Booléens associés
LIBREPCB_USR_BIN_FILENAME_FOUND=false
LIBREPCB_USR_SHARE_FOLDER_FOUND=false
LIBREPCB_USR_SHARE_DOC_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants LibrePCB
if [ -f "$LIBREPCB_USR_BIN_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $LIBREPCB_USR_BIN_FILENAME existe !\n"; fi
        LIBREPCB_USR_BIN_FILENAME_FOUND=true
        
	# Calcul de la taille du fichier installé
	TAILLE_LIBREPCB_USR_BIN_FILENAME=$(du -sh "$LIBREPCB_USR_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $LIBREPCB_USR_BIN_FILENAME est : $TAILLE_LIBREPCB_USR_BIN_FILENAME\n"; fi        
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $LIBREPCB_USR_BIN_FILENAME n'existe pas !\n"; fi
	LIBREPCB_USR_BIN_FILENAME_FOUND=false
fi

if [ -d "$LIBREPCB_USR_SHARE_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $LIBREPCB_USR_SHARE_FOLDER existe !\n"; fi
	LIBREPCB_USR_SHARE_FOLDER_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_LIBREPCB_USR_SHARE_FOLDER=$(du -sh "$LIBREPCB_USR_SHARE_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $LIBREPCB_USR_SHARE_FOLDER est : $TAILLE_LIBREPCB_USR_SHARE_FOLDER\n"; fi     	
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $LIBREPCB_USR_SHARE_FOLDER n'existe pas !\n"; fi
	LIBREPCB_USR_SHARE_FOLDER_FOUND=false
fi

if [ -d "$LIBREPCB_USR_SHARE_DOC_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $LIBREPCB_USR_SHARE_DOC_FOLDER existe !\n"; fi
	LIBREPCB_USR_SHARE_DOC_FOLDER_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_LIBREPCB_USR_SHARE_DOC_FOLDER=$(du -sh "$LIBREPCB_USR_SHARE_DOC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $LIBREPCB_USR_SHARE_DOC_FOLDER est : $TAILLE_LIBREPCB_USR_SHARE_DOC_FOLDER\n"; fi     	
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $LIBREPCB_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	LIBREPCB_USR_SHARE_DOC_FOLDER_FOUND=false
fi

# Test temporaire
declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$LIBREPCB_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_LIBREPCB_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$LIBREPCB_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$LIBREPCB_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_LIBREPCB_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$LIBREPCB_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]="Dossier des librairies"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$LIBREPCB_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_LIBREPCB_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$LIBREPCB_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]="Dossier du copyright et changelog"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Extraire les premiers indices et trouver le max
# indices=($(printf '%s\n' "${!tableau[@]}" | cut -d',' -f1 | sort -n))

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		if $LIBREPCB_USR_BIN_FILENAME_FOUND && $LIBREPCB_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet LibrePCB installé
			dpkg -l librepcb		
		fi
		
		if ! $LIBREPCB_USR_BIN_FILENAME_FOUND && ! $LIBREPCB_USR_SHARE_FOLDER_FOUND; then
		        echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

		        echo -e "Installation de l'application LibrePCB"
		        sudo apt install -y librepcb		
		fi
	;;
	# APT Fin setup type APT

	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## LIBREPCB ####################################
fi # if $INSTALL_LIBREPCB; then



if $INSTALL_KRITA || $INSTALL_ALL; then
############################## KRITA ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Krita"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt de LibrePCB pour contrôler sa présence
KRITA_USR_BIN_FILENAME="/usr/bin/krita"
KRITA_USR_SHARE_FOLDER="/usr/share/krita"
KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER="/usr/lib/x86_64-linux-gnu/kritaplugins"
# Booléens associés
KRITA_USR_BIN_FILENAME_FOUND=false
KRITA_USR_SHARE_FOLDER_FOUND=false
KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER_FOUND=false

# Chemins snap
KRITA_SNAP_BIN_FILENAME="/snap/bin/krita"
KRITA_SNAP_KRITA_FOLDER="/snap/krita"
# Booléens associés
KRITA_SNAP_BIN_FILENAME_FOUND=false
KRITA_SNAP_KRITA_FOLDER_FOUND=false

# Chemins Flatpak
KRITA_VAR_LIB_FLATPAK_APP_FOLDER="/var/lib/flatpak/app/org.kde.krita"
# Booléens associés
KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false

# Chemins des fichiers et/ou dossiers utilisateurs
# Récupération du répertoire utilisateur, dépend du nom d'utilisateur
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")
# Dossiers utilisateur
KRITA_APP_NAME="krita"
KRITA_HOME_USER_CACHE_KRITA_FOLDER="$HOME_USER_FOLDER/.cache/$KRITA_APP_NAME"
# Tailles
TAILLE_KRITA_USR_BIN_FILENAME=""
TAILLE_KRITA_USR_SHARE_FOLDER=""
TAILLE_KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER=""
TAILLE_KRITA_SNAP_BIN_FILENAME=""
TAILLE_KRITA_SNAP_KRITA_FOLDER=""
TAILLE_KRITA_HOME_USER_CACHE_KRITA_FOLDER=""


# Contrôle de la présence de fichiers et/ou dossiers existants LibrePCB
if [ -f "$KRITA_USR_BIN_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $KRITA_USR_BIN_FILENAME existe !\n"; fi
        KRITA_USR_BIN_FILENAME_FOUND=true
        
	# Calcul de la taille du fichier installé
	TAILLE_KRITA_USR_BIN_FILENAME=$(du -sh "$KRITA_USR_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $KRITA_USR_BIN_FILENAME est : $TAILLE_KRITA_USR_BIN_FILENAME\n"; fi            
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $KRITA_USR_BIN_FILENAME n'existe pas !\n"; fi
	KRITA_USR_BIN_FILENAME_FOUND=false
fi

if [ -d "$KRITA_USR_SHARE_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $KRITA_USR_SHARE_FOLDER existe !\n"; fi
	KRITA_USR_SHARE_FOLDER_FOUND=true
	
	# Calcul de la taille du fichier installé
	TAILLE_KRITA_USR_SHARE_FOLDER=$(du -sh "$KRITA_USR_SHARE_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $KRITA_USR_SHARE_FOLDER est : $TAILLE_KRITA_USR_SHARE_FOLDER\n"; fi    	
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $KRITA_USR_SHARE_FOLDER n'existe pas !\n"; fi
	KRITA_USR_SHARE_FOLDER_FOUND=false
fi

if [ -d $KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER existe !\n"; fi
	KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER_FOUND=true
	
	# Calcul de la taille du fichier installé
	TAILLE_KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER=$(du -sh "$KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER est : $TAILLE_KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER\n"; fi    	
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER n'existe pas !\n"; fi
	KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER_FOUND=false
fi


# SNAP
if [ -f "$KRITA_SNAP_BIN_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $KRITA_SNAP_BIN_FILENAME existe !\n"; fi
	KRITA_SNAP_BIN_FILENAME_FOUND=true
	
	# Calcul de la taille du fichier installé
	TAILLE_KRITA_SNAP_BIN_FILENAME=$(du -sh "$KRITA_SNAP_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $KRITA_SNAP_BIN_FILENAME est : $TAILLE_KRITA_SNAP_BIN_FILENAME\n"; fi    	
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $KRITA_SNAP_BIN_FILENAME n'existe pas !\n"; fi
	KRITA_SNAP_BIN_FILENAME_FOUND=false
fi

if [ -d "$KRITA_SNAP_KRITA_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $KRITA_SNAP_KRITA_FOLDER existe !\n"; fi
	KRITA_SNAP_KRITA_FOLDER_FOUND=true
	
	# Calcul de la taille du fichier installé
	TAILLE_KRITA_SNAP_KRITA_FOLDER=$(du -sh "$KRITA_SNAP_KRITA_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $KRITA_SNAP_KRITA_FOLDER est : $TAILLE_KRITA_SNAP_KRITA_FOLDER\n"; fi    	
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $KRITA_SNAP_KRITA_FOLDER n'existe pas !\n"; fi
	KRITA_SNAP_KRITA_FOLDER_FOUND=false
fi

if [ -d "$KRITA_HOME_USER_CACHE_KRITA_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $KRITA_HOME_USER_CACHE_KRITA_FOLDER existe !\n"; fi
	KRITA_HOME_USER_CACHE_KRITA_FOLDER_FOUND=true
	
	# Calcul de la taille du fichier installé
	TAILLE_KRITA_HOME_USER_CACHE_KRITA_FOLDER=$(du -sh "$KRITA_HOME_USER_CACHE_KRITA_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $KRITA_HOME_USER_CACHE_KRITA_FOLDER est : $TAILLE_KRITA_HOME_USER_CACHE_KRITA_FOLDER\n"; fi    	
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $KRITA_HOME_USER_CACHE_KRITA_FOLDER n'existe pas !\n"; fi
	KRITA_HOME_USER_CACHE_KRITA_FOLDER_FOUND=false
fi

# SNAP (FIN)

# FLATPAK
if [ -d $KRITA_VAR_LIB_FLATPAK_APP_FOLDER ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $KRITA_VAR_LIB_FLATPAK_APP_FOLDER existe !\n"; fi
	KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=true

	# Calcul de la taille du fichier installé
	TAILLE_KRITA_VAR_LIB_FLATPAK_APP_FOLDER=$(du -sh "$KRITA_VAR_LIB_FLATPAK_APP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $KRITA_VAR_LIB_FLATPAK_APP_FOLDER est : $TAILLE_KRITA_VAR_LIB_FLATPAK_APP_FOLDER\n"; fi   	
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $KRITA_VAR_LIB_FLATPAK_APP_FOLDER n'existe pas !\n"; fi
	KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
fi

# FLATPAK (FIN)

# Test temporaire
declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$KRITA_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_KRITA_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$KRITA_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$KRITA_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_KRITA_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$KRITA_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER
tableau[$tab_ind,chemin]=$KRITA_USR_LIB_X86_64_LINUX_GNU_KRITAPLUGINS_FOLDER
tableau[$tab_ind,commentaires]="Dossier APT des plugins Krita"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$KRITA_SNAP_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_KRITA_SNAP_BIN_FILENAME
tableau[$tab_ind,chemin]=$KRITA_SNAP_BIN_FILENAME
tableau[$tab_ind,commentaires]="Lien vers l'application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$KRITA_SNAP_KRITA_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_KRITA_SNAP_KRITA_FOLDER
tableau[$tab_ind,chemin]=$KRITA_SNAP_KRITA_FOLDER
tableau[$tab_ind,commentaires]="Dossier snap principal"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$KRITA_HOME_USER_CACHE_KRITA_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_KRITA_HOME_USER_CACHE_KRITA_FOLDER
tableau[$tab_ind,chemin]=$KRITA_HOME_USER_CACHE_KRITA_FOLDER
tableau[$tab_ind,commentaires]="Dossier utilisateur cache"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_KRITA_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$KRITA_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]=""


if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Extraire les premiers indices et trouver le max
# indices=($(printf '%s\n' "${!tableau[@]}" | cut -d',' -f1 | sort -n))

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Vérification et désinstallation d'une version existante via SNAP
		if $KRITA_SNAP_KRITA_FOLDER_FOUND && $KRITA_SNAP_KRITA_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"

			# Désinstallation d'une version existante de Krita via APT (pour éviter un doublon avec l'installation de Krita)
			echo -e "Début de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_SNAP :\n"
			
			echo -e "Suppression de $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_SNAP (sans supprimer les fichiers de configuratiuon) :\n"
			
			yes | sudo snap remove krita
			
			echo -e ""
			
			echo -e "Suppression de Krita et de tous les fichiers de configuration :\n"
			
			yes | sudo snap purge krita
			
			echo -e ""
			
			echo -e "Nettoyage des dépendances inutiles de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			sudo apt-get autoremove -y
			
			echo -e ""
			
			echo -e "Fin de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT\n"
		fi
		
		# Vérification et désinstallation d'une version existante via Flatpak (supprime aussi les données personnelles)
		if $KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND; then
			# flatpak uninstall --delete-data -y org.kde.krita
			
			yes | flatpak uninstall -y --delete-data org.kde.krita	# Pour automatiser
		fi
	
		# Vérification d'une version existante via APT
		if $KRITA_USR_BIN_FILENAME_FOUND && $KRITA_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet FWUPD installé
			dpkg -l krita
			
			echo -e ""
		fi
		
		# Installation via APT
		if ! $KRITA_USR_BIN_FILENAME_FOUND && ! $KRITA_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			sudo apt install -y krita	
		fi
	;;
	# APT Fin setup type APT

	$TXT_SETUP_TYPE_SNAP)
		# Vérification et désinstallation d'une version existante via APT
		if $KRITA_USR_BIN_FILENAME_FOUND && $KRITA_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"

			# Désinstallation d'une version existante de Krita via APT (pour éviter un doublon avec l'installation de Krita)
			echo -e "Début de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			echo -e "Suppression de $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT (sans supprimer les fichiers de configuratiuon) :\n"
			
			sudo apt-get remove -y krita
			
			echo -e ""
			
			echo -e "Suppression de Krita et de tous les fichiers de configuration :\n"
			
			sudo apt-get purge -y krita
			
			echo -e ""
			
			echo -e "Nettoyage des dépendances inutiles de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			sudo apt-get autoremove -y
			
			echo -e ""
			
			echo -e "Fin de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT\n"
		fi
		# Vérification et désinstallation d'une version existante via APT (FIN)
		
		# Vérification et désinstallation d'une version existante via Flatpak (supprime aussi les données personnelles)
		if $KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND; then
			# flatpak uninstall --delete-data -y org.kde.krita
			
			yes | flatpak uninstall -y --delete-data org.kde.krita	# Pour automatiser
		fi		
		
		# Vérification et désinstallation d'une version existante via APT
		if $KRITA_SNAP_KRITA_FOLDER_FOUND && $KRITA_SNAP_KRITA_FOLDER_FOUND; then
			if snap list krita > /dev/null 2>&1; then
		    		echo -e "$TXT_APP_TO_INSTALL est déja installé via Snap !\n"

				echo -e "Informations sur la version installée via Snap :\n"

		    		snap list krita
		    		
		    		# snap info krita --> Donne trop d'infos 
		    		
		    		echo -e ""	
			fi	
		fi
		
		# Installation SNAP
		if ! $KRITA_SNAP_KRITA_FOLDER_FOUND && ! $KRITA_SNAP_KRITA_FOLDER_FOUND; then
			sudo snap install krita
		fi
	;;
	# SNAP Fin setup type SNAP

	$TXT_SETUP_TYPE_FLATPAK)
		# Vérification et désinstallation d'une version existante via APT
		if $KRITA_USR_BIN_FILENAME_FOUND && $KRITA_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"

			# Désinstallation d'une version existante de Krita via APT (pour éviter un doublon avec l'installation de Krita)
			echo -e "Début de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			echo -e "Suppression de $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT (sans supprimer les fichiers de configuration) :\n"
			
			sudo apt-get -y remove krita
			
			echo -e ""
			
			echo -e "Suppression de Krita et de tous les fichiers de configuration :\n"
			
			sudo apt-get -y purge krita
			
			echo -e ""
			
			echo -e "Nettoyage des dépendances inutiles de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			sudo apt-get autoremove -y
			
			echo -e ""
			
			echo -e "Fin de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT\n"
		fi

		# Vérification et désinstallation d'une version existante via SNAP
		if $KRITA_SNAP_KRITA_FOLDER_FOUND && $KRITA_SNAP_KRITA_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"

			# Désinstallation d'une version existante de Krita via APT (pour éviter un doublon avec l'installation de Krita)
			echo -e "Début de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_SNAP :\n"
			
			echo -e "Suppression de $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT (sans supprimer les fichiers de configuratiuon) :\n"
			
			yes | sudo snap remove krita
			
			echo -e ""
			
			echo -e "Suppression de Krita et de tous les fichiers de configuration :\n"
			
			yes | sudo snap purge krita
			
			echo -e ""
			
			echo -e "Nettoyage des dépendances inutiles de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			sudo apt-get -y autoremove
			
			echo -e ""
			
			echo -e "Fin de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT\n"
		fi

		if $KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND; then
			# Contrôle d'une version déja installée via le gestionnaire de paquet Flatpak
			if flatpak list | grep -q org.kde.krita ; then
				echo -e "$TXT_APP_TO_INSTALL est déja installé via Flatpak !\n"

				echo -e "Informations sur la version installée via Flatpak :\n"

				# Afficher la version via flatpak
				flatpak list --app | grep org.kde.krita

				# Saut de ligne console
				echo -e ""
			else
				echo -e "$TXT_APP_TO_INSTALL via Flatpak n'est pas installé !\n"
			fi		
		fi
		
		if ! $KRITA_VAR_LIB_FLATPAK_APP_FOLDER_FOUND; then
			# Installation de Krita via Flatpak
			flatpak -y install flathub org.kde.krita		
		fi
	;;
	# FLATPAK Fin setup type Flatpak


	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## KRITA ####################################
fi # if $INSTALL_KRITA; then

if $INSTALL_BLENDER || $INSTALL_ALL; then
############################## BLENDER ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Blender"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt de Blender pour contrôler sa présence
BLENDER_USR_BIN_FILENAME="/usr/bin/blender"
BLENDER_USR_SHARE_FOLDER="/usr/share/blender"
# Booléens associés
BLENDER_USR_BIN_FILENAME_FOUND=false
BLENDER_USR_SHARE_FOLDER_FOUND=false


# Contrôle de fichier
if Recherche_fichier $BLENDER_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $BLENDER_BIN_FILENAME existe !\n"; fi
	BLENDER_BIN_FILENAME_FOUND=true
	TAILLE_BLENDER_BIN_FILENAME=$(du -sh "$BLENDER_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $BLENDER_BIN_FILENAME n'existe pas !\n"; fi
	BLENDER_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $BLENDER_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $BLENDER_USR_SHARE_FOLDER existe !\n"; fi
	BLENDER_USR_SHARE_FOLDER_FOUND=true
	TAILLE_BLENDER_USR_SHARE_FOLDER=$(du -sh "$BLENDER_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $BLENDER_USR_SHARE_FOLDER n'existe pas !\n"; fi
	BLENDER_USR_SHARE_FOLDER_FOUND=false
fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BLENDER_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_BLENDER_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$BLENDER_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BLENDER_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_BLENDER_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$BLENDER_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi


TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		if $BLENDER_USR_BIN_FILENAME_FOUND && $BLENDER_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet FWUPD installé
			dpkg -l blender	
		fi
		
		if ! $BLENDER_USR_BIN_FILENAME_FOUND && ! $BLENDER_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			sudo apt install -y blender	
		fi
	;;
	# APT Fin setup type APT

	*)

	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## BLENDER ####################################
fi # if $INSTALL_BLENDER; then


if $INSTALL_FWUP || $INSTALL_ALL; then
############################## FIRMWARE UPDATER ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Firmware-Updater FWUPD"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemins d es fichiers / dossiers pour contrôler leur présence
FWUPD_BIN_FILENAME="/usr/bin/fwupdmgr"
FWUPD_SHARE_FOLDER="/usr/share/fwupd"
# Booléens associés
FWUPD_BIN_FILENAME_FOUND=false
FWUPD_SHARE_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants
echo -e "Recherche en cours de version déjà installée :\n"

if [ -f "$FWUPD_BIN_FILENAME" ]; then
        echo -e "✅ Le fichier $FWUPD_BIN_FILENAME existe !\n"
        FWUPD_BIN_FILENAME_FOUND=true
else
        echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"
        FWUPD_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $FWUPD_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $FWUPD_SHARE_FOLDER existe !\n"; fi
	FWUPD_SHARE_FOLDER_FOUND=true
	TAILLE_FWUPD_SHARE_FOLDER=$(du -sh "$FWUPD_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $FWUPD_SHARE_FOLDER n'existe pas !\n"; fi
	FWUPD_SHARE_FOLDER_FOUND=false
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FWUPD_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_FWUPD_BIN_FILENAME
tableau[$tab_ind,chemin]=$FWUPD_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FWUPD_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_FWUPD_SHARE_FOLDER
tableau[$tab_ind,chemin]=$FWUPD_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi


TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		if $FWUPD_BIN_FILENAME_FOUND && $FWUPD_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet FWUPD installé
			sudo dpkg -l fwupd
		fi
		
		if ! $FWUPD_BIN_FILENAME_FOUND && ! $FWUPD_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			# Installation de Firmware-Updater
			sudo apt install fwupd -y

			# Actualisation des métadonnées des mises à jour
			sudo fwupdmgr refresh

			# Vérification des mies à jour dispo
			sudo fwupdmgr get-updates

			# Mis à jour de l'application Firmware-Updater
			sudo fwupdmgr update
		fi
	;;
	# APT Fin setup type APT

	*)

	;;
esac


echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## FIRMWARE UPDATER ####################################
fi # if $INSTALL_FWUP; then

if $INSTALL_FIREFOX || $INSTALL_ALL; then
############################## FIREFOX ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Firefox"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier pour contrôler sa présence
FIREFOX_USR_LIB_FILENAME="/usr/lib/firefox/firefox"
FIREFOX_SNAP_BIN_FILENAME="/snap/bin/firefox"
FIREFOX_USR_SHARE_DOC_FOLDER="/usr/share/doc/firefox"
FIREFOX_SNAP_FOLDER="/snap/firefox"
FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER="/run/user/1000/snap.firefox"
FIREFOX_ETC_APT_SOURCES_D_LIST_FILENAME="mozillateam-ubuntu-ppa-questing.sources"
FIREFOX_ETC_APT_SOURCES_D_LIST_FOLDER="/etc/apt/sources.list.d/"
# Booléens associés
FIREFOX_USR_LIB_FILENAME_FOUND=false
FIREFOX_SNAP_BIN_FILENAME_FOUND=false
FIREFOX_USR_SHARE_DOC_FOLDER_FOUND=false
FIREFOX_SNAP_FOLDER_FOUND=false

# Chemins des fichiers et/ou dossiers utilisateurs
# Récupération du répertoire utilisateur, dépend du nom d'utilisateur
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")
# Dossiers utilisateur
FIREFOX_SNAP_APP_NAME="firefox"
FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER="$HOME_USER_FOLDER/snap/$FIREFOX_SNAP_APP_NAME"
# Booléens associés
FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER_FOUND=false


# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f $FIREFOX_USR_LIB_FILENAME ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $FIREFOX_USR_LIB_FILENAME existe !\n"; fi
        FIREFOX_USR_LIB_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_FIREFOX_USR_LIB_FILENAME=$(du -sh "$FIREFOX_USR_LIB_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $FIREFOX_USR_LIB_FILENAME est : $TAILLE_FIREFOX_USR_LIB_FILENAME\n"; fi  
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $FIREFOX_USR_LIB_FILENAME n'existe pas !\n"; fi
        FIREFOX_USR_LIB_FILENAME_FOUND=false
fi

if [ -f $FIREFOX_SNAP_BIN_FILENAME ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $FIREFOX_SNAP_BIN_FILENAME existe !\n"; fi
        FIREFOX_SNAP_BIN_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_FIREFOX_SNAP_BIN_FILENAME=$(du -sh "$FIREFOX_SNAP_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $FIREFOX_SNAP_BIN_FILENAME est : $TAILLE_FIREFOX_SNAP_BIN_FILENAMEE\n"; fi  
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $FIREFOX_SNAP_BIN_FILENAME n'existe pas !\n"; fi
        FIREFOX_SNAP_BIN_FILENAME_FOUND=false
fi

if [ -d $FIREFOX_USR_SHARE_DOC_FOLDER ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $FIREFOX_USR_SHARE_DOC_FOLDER existe !\n"; fi
	FIREFOX_USR_SHARE_DOC_FOLDER_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_FIREFOX_USR_SHARE_DOC_FOLDER=$(du -sh "$FIREFOX_USR_SHARE_DOC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $FIREFOX_USR_SHARE_DOC_FOLDER est : $TAILLE_FIREFOX_USR_SHARE_DOC_FOLDER\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $FIREFOX_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	FIREFOX_USR_SHARE_DOC_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $FIREFOX_SNAP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $FIREFOX_SNAP_FOLDER existe !\n"; fi
	FIREFOX_SNAP_FOLDER_FOUND=true
	TAILLE_FIREFOX_SNAP_FOLDER=$(du -sh "$FIREFOX_SNAP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $FIREFOX_SNAP_FOLDER n'existe pas !\n"; fi
	FIREFOX_SNAP_FOLDER_FOUND=false
fi

if [ -d $FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $FFIREFOX_RUN_USER_1000_SNAP_APP_FOLDER existe !\n"; fi
	FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER=$(du -sh "$FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER est : $TAILLE_FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER n'existe pas !\n"; fi
	FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER_FOUND=false
fi

if [ -d $FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER existe !\n"; fi
	FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER=$(du -sh "$FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER est : $TAILLE_FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER n'existe pas !\n"; fi
	FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER_FOUND=false
fi

# Contrôle du paquet etc apt
if grep -q $FIREFOX_ETC_APT_SOURCES_D_LIST_FILENAME $FIREFOX_ETC_APT_SOURCES_D_LIST_FOLDER*.list 2>/dev/null; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $FIREFOX_ETC_APT_SOURCES_D_LIST_FOLDER$FIREFOX_ETC_APT_SOURCES_D_LIST_FILENAME existe !\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $FIREFOX_ETC_APT_SOURCES_D_LIST_FOLDER$FIREFOX_ETC_APT_SOURCES_D_LIST_FILENAME n'existe pas !\n"; fi
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FIREFOX_USR_LIB_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_FIREFOX_USR_LIB_FILENAME
tableau[$tab_ind,chemin]=$FIREFOX_USR_LIB_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FIREFOX_SNAP_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_FIREFOX_SNAP_BIN_FILENAME
tableau[$tab_ind,chemin]=$FIREFOX_SNAP_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FIREFOX_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_FIREFOX_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$FIREFOX_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FIREFOX_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_FIREFOX_SNAP_FOLDER
tableau[$tab_ind,chemin]=$FIREFOX_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER
tableau[$tab_ind,chemin]=$FIREFOX_RUN_USER_1000_SNAP_APP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER
tableau[$tab_ind,chemin]=$FIREFOX_HOME_USER_SNAP_FIREFOX_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si au moins un dossier a été trouvé
		if $FIREFOX_SNAP_BIN_FILENAME_FOUND && $FIREFOX_USR_SHARE_DOC_FOLDER_FOUND && $FIREFOX_SNAP_FOLDER_FOUND; then
			echo -e "L'application est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet Firefox installé
			sudo dpkg -l firefox

			echo -e ""
		fi		
	
		# Si aucun des dossiers n'a été trouvé 
		if ! $FIREFOX_USR_SHARE_DOC_FOLDER_FOUND && ! $FIREFOX_SNAP_FOLDER_FOUND; then
			echo -e "Les dossiers '$FIREFOX_USR_SHARE_DOC_FOLDER_FOUND' et '$FIREFOX_SNAP_FOLDER_FOUND' n'ont pas été trouvés ! L'application n'est pas installée via $TXT_SETUP_TYPE_SNAP !\n"
		
			echo -e "Ajout du dépôt officiel de mozilla :\n"
		
			# Ajout du dépôt apt
			sudo add-apt-repository ppa:mozillateam/ppa -y

			echo -e "Mise à jour du système avant installation :"

			# Mise à jour de l'index des paquets
			sudo apt update
			
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"

			# Installation de Firefox via apt
			sudo apt install -y firefox
			
			echo -e ""
			
			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !"
		fi
	;;
	# APT - Fin setup type APT
	
	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## FIREFOX ####################################
fi # if $INSTALL_FIREFOX; then


if $INSTALL_OBS_STUDIO || $INSTALL_ALL; then
############################## OBS STUDIO ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="OBS Studio"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel OBS Studio via apt"
echo -e $TEXT_RESET

# Chemin des fichiers et/ou dossiers OBS Studio pour contrôler sa présence
OBS_STUDIO_USR_BIN_FILENAME="/usr/bin/obs"
OBS_STUDIO_USR_SHARE_FOLDER="/usr/share/obs/obs-studio/"
OBS_STUDIO_USR_SHARE_DOC_FOLDER="/usr/share/doc/obs-studio"
# Booléens associés
OBS_STUDIO_USR_BIN_FILENAME_FOUND=false
OBS_STUDIO_USR_SHARE_FOLDER_FOUND=false
OBS_STUDIO_USR_SHARE_DOC_FOLDER_FOUND=false


# Contrôle de la présence de fichiers et/ou dossiers existants
if $SHOW_ANALYSE_LINES; then echo -e "Recherche en cours de version déja installée :\n"; fi

# Contrôle de la présence de fichiers et/ou dossiers existants
if Recherche_fichier $OBS_STUDIO_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $OBS_STUDIO_USR_BIN_FILENAME existe !\n"; fi
	OBS_STUDIO_USR_BIN_FILENAME_FOUND=true
	TAILLE_OBS_STUDIO_USR_BIN_FILENAME=$(du -sh "$OBS_STUDIO_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $OBS_STUDIO_USR_BIN_FILENAME n'existe pas !\n"; fi
	OBS_STUDIO_USR_BIN_FILENAME_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $OBS_STUDIO_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OBS_STUDIO_USR_SHARE_FOLDER existe !\n"; fi
	OBS_STUDIO_USR_SHARE_FOLDER_FOUND=true
	TAILLE_OBS_STUDIO_USR_SHARE_FOLDER=$(du -sh "$OBS_STUDIO_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OBS_STUDIO_USR_SHARE_FOLDER n'existe pas !\n"; fi
	OBS_STUDIO_USR_SHARE_FOLDER_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $OBS_STUDIO_USR_SHARE_DOC_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OBS_STUDIO_USR_SHARE_DOC_FOLDER existe !\n"; fi
	OBS_STUDIO_USR_SHARE_DOC_FOLDER_FOUND=true
	TAILLE_OBS_STUDIO_USR_SHARE_DOC_FOLDER=$(du -sh "$OBS_STUDIO_USR_SHARE_DOC_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OBS_STUDIO_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	OBS_STUDIO_USR_SHARE_DOC_FOLDER_FOUND=false
fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OBS_STUDIO_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_OBS_STUDIO_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$OBS_STUDIO_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OBS_STUDIO_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OBS_STUDIO_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$OBS_STUDIO_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OBS_STUDIO_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OBS_STUDIO_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$OBS_STUDIO_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi



TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Analyse des résultats des fichiers et/ou dossiers recherchés
		if $OBS_STUDIO_USR_BIN_FILENAME_FOUND && $OBS_STUDIO_USR_SHARE_FOLDER_FOUND && $OBS_STUDIO_USR_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet Firefox installé
			sudo dpkg -l obs-studio
		fi

		if ! $OBS_STUDIO_USR_BIN_FILENAME_FOUND || ! $OBS_STUDIO_USR_SHARE_FOLDER_FOUND || ! $OBS_STUDIO_USR_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "L'application n'est pas correctement installée, il manque un dossier !\n"
		fi

		if ! $OBS_STUDIO_USR_BIN_FILENAME_FOUND && ! $OBS_STUDIO_USR_SHARE_FOLDER_FOUND && ! $OBS_STUDIO_USR_SHARE_DOC_FOLDER_FOUND ; then
			# Mise à jour de l'index des paquets
			sudo apt update

			# Installation de OBS-Studio via apt
			sudo apt install -y obs-studio
		fi	
	;;
	
	*)
	
	;;
esac



echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel OBS Studio via apt"
echo -e $TEXT_RESET

#################
############################## OBS STUDIO ####################################
fi # if $INSTALL_OBS_STUDIO; then


if $INSTALL_SIGNAL_DESKTOP || $INSTALL_ALL; then
############################## SIGNAL DESKTOP ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Signal-Desktop"

# Type d installation (apt, Flatpak, snap) : D après le site officiel https://doc.ubuntu-fr.org/signal, la version officielle de Signal est sur Flatpak et non pas apt
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE\n"
echo -e $TEXT_RESET

# Chemin du dossier apt de pour contrôler sa présence
SIGNAL_BIN_FILENAME="/usr/bin/signal-desktop"
SIGNAL_SHARE_FOLDER="/usr/share/doc/signal-desktop"
SIGNAL_ETC_ALT_FILENAME="/opt/Signal/signal-desktop"
SIGNAL_VAR_CACHE_APT_ARCHIVES="/var/cache/apt/archives"
SIGNAL_ETC_APT_SOURCES_FILENAME="signal-desktop.sources"
SIGNAL_SNAP_FOLDER="/snap/signal-desktop"

SIGNAL_BIN_FILENAME_FOUND=false
SIGNAL_SNAP_FOLDER_FOUND=false
SIGNAL_SHARE_FOLDER_FOUND=false

# Contrôle du fichier
if Recherche_fichier $SIGNAL_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $SIGNAL_BIN_FILENAME existe !\n"; fi
	SIGNAL_BIN_FILENAME_FOUND=true
	TAILLE_SIGNAL_BIN_FILENAME=$(du -sh "$SIGNAL_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $SIGNAL_BIN_FILENAME n'existe pas !\n"; fi
	SIGNAL_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $SIGNAL_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $SIGNAL_SHARE_FOLDER existe !\n"; fi
	SIGNAL_SHARE_FOLDER_FOUND=true
	TAILLE_SIGNAL_SHARE_FOLDER=$(du -sh "$SIGNAL_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $SIGNAL_SHARE_FOLDER n'existe pas !\n"; fi
	SIGNAL_SHARE_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $SIGNAL_SNAP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $SIGNAL_SNAP_FOLDER existe !\n"; fi
	SIGNAL_SNAP_FOLDER_FOUND=true
	TAILLE_SIGNAL_SNAP_FOLDER=$(du -sh "$SIGNAL_SNAP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $SIGNAL_SNAP_FOLDER n'existe pas !\n"; fi
	SIGNAL_SNAP_FOLDER_FOUND=false
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$SIGNAL_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_SIGNAL_BIN_FILENAME
tableau[$tab_ind,chemin]=$SIGNAL_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$SIGNAL_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_SIGNAL_SHARE_FOLDER
tableau[$tab_ind,chemin]=$SIGNAL_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$SIGNAL_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_SIGNAL_SNAP_FOLDER
tableau[$tab_ind,chemin]=$SIGNAL_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi



TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""





case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# APT - Début setup type APT

		echo -e "Type d'installation choisie par défaut : APT\n"

		# Analyse des fichiers / dossiers trouvés
		if [[ SIGNAL_BIN_FILENAME_FOUND ]]; then
		        echo -e "Informations sur la version de $TXT_APP_TO_INSTALL installée :\n"

		        # Affichage de la version du paquet installé
		        sudo dpkg -l signal-desktop

		        # Saut de ligne console
		        echo -e ""

		        # Calcul de la taille du dossier installé
		        TAILLE_SIGNAL_SHARE_FOLDER=$(du -sh "$SIGNAL_SHARE_FOLDER" | cut -f1)

		        # Affichage console de la taille du dossier installé
		        echo -e "La taille du dossier $SIGNAL_SHARE_FOLDER est : $TAILLE_SIGNAL_SHARE_FOLDER\n"

		        # Calcul de la taille du fichier installé
		        TAILLE_SIGNAL_ETC_ALT_FILENAME=$(du -sh "$SIGNAL_ETC_ALT_FILENAME" | cut -f1)

		        # Affichage console de la taille du dossier installé
		        echo -e "La taille du fichier $SIGNAL_ETC_ALT_FILENAME est : $TAILLE_SIGNAL_ETC_ALT_FILENAME\n"

		        # Recherche de fichiers archives dans le système
		        fichiers=("$SIGNAL_VAR_CACHE_APT_ARCHIVES"/signal*)

		        if [ -e "${fichiers[0]}" ]; then
		            echo "Un fichier commençant par 'signal' appelé $(basename ${fichiers[0]}) existe dans $SIGNAL_VAR_CACHE_APT_ARCHIVES"
		        else
		            echo "Aucun fichier commençant par 'signal' dans $SIGNAL_VAR_CACHE_APT_ARCHIVES"
		        fi

		fi

		# On vérifie que le ppa est présent ou pas
		if grep SIGNAL_ETC_APT_SOURCES_FILENAME /etc/apt/sources.list.d/*.list; then
		        # Si le dépôt de Signal est déja présent
		        echo -e "Le dépôt ppa de Signal est déja présent dans la liste des sources apt\n"

		        echo -e "L'application Signal est déja installée !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet installé
		        sudo dpkg -l signal-desktop

		else
		        # Si le dépôt ppa de Signal n'est pas présent
		        echo -e "❌ Le dépôt ppa de Signal n'est pas présent dans la liste des sources apt\n"

		fi


		# Si le dossier APT n'existe pas, il faut installer
		if [[ ! -n "$SIGNAL_SHARE_FOLDER" ]]; then
			echo -e "Début de l'installation de Signal-desktop :"
		
		        # Importation de la clé GPG
		        wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor -o /usr/share/keyrings/signal-desktop-keyring.gpg;
		        cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

		        # Ajout du dépot Signal au système
		        # wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;

		        wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
		        cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null

		        # Mise à jour de l'index des paquets avant installation
		        sudo apt update

		        # Installation de Signal
		        sudo apt install signal-desktop

		fi

        ;;
	# APT - Fin setup type APT


	"Flatpak")
	echo -e "Type d'installation choisie par défaut : Flatpak\n"
	
	;;
	# FLATPAK - Fin setup type Flatpak

	$TXT_SETUP_TYPE_SNAP)
		echo -e "Type d'installation choisie par défaut : Snap (évite des pbs de clé gpg) \n"
		
		if [ -d "$SIGNAL_SNAP_FOLDER" ]; then
		        echo -e "L'application Signal est déja installée !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet installé
		        snap list signal-desktop		
		fi
		
		if [ ! -d "$SIGNAL_SNAP_FOLDER" ]; then
			if snap list signal-desktop > /dev/null 2>&1; then
		    		echo -e "Signal-Desktop est déja installé !\n"
		    		
		    		snap list signal-desktop
		    		
		    		# snap info signal-desktop --> Donne trop d'infos 
		    		
		    		echo -e ""
			else
		    		echo -e "Signal-Desktop n'est pas installé !\n"
		    		
		    		sudo snap install signal-desktop
		    		
		    		echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL !\n"    		
			fi		
		fi
	;;
	# SNAP - Fin setup type Snap

	*)
	echo -e "Type d'installation choisie par défaut : $TXT_SETUP_TYPE\n"
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE\n"
echo -e $TEXT_RESET

#################
############################## SIGNAL DESKTOP ####################################
fi # if $INSTALL_SIGNAL_DESKTOP; then

if $INSTALL_VISUAL_STUDIO_CODE || $INSTALL_ALL; then
############################## VISUAL STUDIO CODE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Visual Studio Code"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE\n"
echo -e $TEXT_RESET

# Installation de Visual Studio Code via un fichier local .deb
# sudo dpkg -i code_1.109.3-1770920364_amd64.deb

# Chemins des dossiers pour contrôler sa présence
VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME="/snap/bin/code"
VISUAL_STUDIO_CODE_USR_SHARE_FOLDER="/snap/code/"
# Booléens associés
VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME_FOUND=false
VISUAL_STUDIO_CODE_USR_SHARE_FOLDER_FOUND=false

# Contrôle du fichier
if Recherche_fichier $VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME existe !\n"; fi
	VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME_FOUND=true
	TAILLE_VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME=$(du -sh "$VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME n'existe pas !\n"; fi
	VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME_FOUND=false
fi
		
# Contrôle du dossier 
if Recherche_dossier $VISUAL_STUDIO_CODE_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $VISUAL_STUDIO_CODE_USR_SHARE_FOLDER existe !\n"; fi
	VISUAL_STUDIO_CODE_USR_SHARE_FOLDER_FOUND=true
	TAILLE_VISUAL_STUDIO_CODE_USR_SHARE_FOLDER=$(du -sh "$VISUAL_STUDIO_CODE_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $VISUAL_STUDIO_CODE_USR_SHARE_FOLDER n'existe pas !\n"; fi
	VISUAL_STUDIO_CODE_USR_SHARE_FOLDER_FOUND=false
fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME
tableau[$tab_ind,chemin]=$VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$VISUAL_STUDIO_CODE_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_VISUAL_STUDIO_CODE_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$VISUAL_STUDIO_CODE_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_SNAP)

		if $VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME_FOUND && $VISUAL_STUDIO_CODE_USR_SHARE_FOLDER_FOUND; then
			echo -e "Tous les fichiers et/ou dossiers recherchés ont été trouvés !\n"
		
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version de $TXT_APP_TO_INSTALL installée :\n"

			# Affichage de la version du paquet installé
			if snap list code > /dev/null 2>&1 ; then
				echo -e "Le paquet snap de $TXT_APP_TO_INSTALL a été trouvé !\n"
				
				snap list code
				
				echo -e ""
			else
				echo -e "Le paquet snap de $TXT_APP_TO_INSTALL n'a pas été trouvé !\n"
			fi
			
			if code --version > /dev/null 2>&1 ; then
				echo -e "La commande 'code --version' de $TXT_APP_TO_INSTALL fonctionne !\n"
				
				code --version
				
				echo -e ""
			else
				echo -e "La commande 'code --version' de $TXT_APP_TO_INSTALL ne fonctionne pas !\n"
			fi			
			
			# snap list | grep code
			
			# Vérification et affichage de la version de Visual Studio Code installé
			# code --version
		fi
		
		if $VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME_FOUND || $VISUAL_STUDIO_CODE_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi
		
		if $VISUAL_STUDIO_CODE_SNAP_BIN_FILENAME_FOUND && $VISUAL_STUDIO_CODE_USR_SHARE_FOLDER_FOUND; then
			echo -e "❌ Aucun des fichiers et/ou dossiers recherchés ont été trouvés !\n"
			
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			echo -e "Installation de l'application $TXT_APP_TON_INSTALL via snap :\n"
			
			sudo snap install code --classic			
			
		fi
	;;
	# SNAP - Fin setup type Snap
	
	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE\n"
echo -e $TEXT_RESET

#################
############################## VISUAL STUDIO CODE ####################################
fi # if $INSTALL_VISUAL_STUDIO_CODE; then

if $INSTALL_BRAVE || $INSTALL_ALL; then
############################## BRAVE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Brave"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel Brave via apt selon la procédure d'installation officielle du site Brave https://brave.com/linux/"
echo -e $TEXT_RESET

# Contrôle d'un dossier utilisateur
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin du dossier apt de Brave pour contrôler sa présence
BRAVE_OPT_FILENAME="/opt/brave.com/brave/brave"
BRAVE_USR_SHARE_DOC_FOLDER="/usr/share/doc/brave-browser"
BRAVE_APT_FILENAME="/etc/apt/sources.list.d/brave-browser-release.sources"
BRAVE_VAR_CACHE_APT_ARCHIVES="/var/cache/apt/archives"
# Chemins utilisateur
BRAVE_HOME_USR_CACHE_FOLDER="$HOME_USER/.cache/BraveSoftware"
BRAVE_HOME_USR_CONFIG_FOLDER="$HOME_USER/.config/BraveSoftware"
BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER="$HOME_USER/.config/BraveSoftware/Brave-Browser/Default"

BRAVE_OPT_FILENAME_FOUND=false
BRAVE_USR_SHARE_DOC_FOLDER_FOUND=false
BRAVE_HOME_USR_CACHE_FOLDER_FOUND=false
BRAVE_HOME_USR_CONFIG_FOLDER_FOUND=false
# Booléesn utilisateur
BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$BRAVE_OPT_FILENAME" ] ; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $BRAVE_OPT_FILENAME existe !\n"; fi
	BRAVE_OPT_FILENAME_FOUND=true
			
	# Calcul de la taille du dossier installé
	TAILLE_BRAVE_OPT_FILENAME=$(du -sh "$BRAVE_OPT_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $BRAVE_OPT_FILENAME est : $TAILLE_BRAVE_OPT_FILENAME\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $BRAVE_OPT_FILENAME n'existe pas !\n"; fi
	BRAVE_OPT_FILENAME_FOUND=false
fi
		
if [ -d "$BRAVE_USR_SHARE_DOC_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $BRAVE_USR_SHARE_DOC_FOLDER existe !\n"; fi
	BRAVE_USR_SHARE_DOC_FOLDER_FOUND=true

	# Calcul de la taille du fichier installé
	TAILLE_BRAVE_USR_SHARE_DOC_FOLDER=$(du -sh "$BRAVE_USR_SHARE_DOC_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $BRAVE_USR_SHARE_DOC_FOLDER est : $TAILLE_BRAVE_USR_SHARE_DOC_FOLDER\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $BRAVE_USR_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	BRAVE_USR_SHARE_DOC_FOLDER_FOUND=false
fi		
		



if [ -d "$BRAVE_HOME_USR_CACHE_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $BRAVE_HOME_USR_CACHE_FOLDER existe !\n"; fi
	BRAVE_HOME_USR_CACHE_FOLDER_FOUND=true
	
	# Calcul de la taille du dossier installé
	TAILLE_BRAVE_HOME_USR_CACHE_FOLDER=$(du -sh "$BRAVE_HOME_USR_CACHE_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $BRAVE_HOME_USR_CACHE_FOLDER est : $TAILLE_BRAVE_HOME_USR_CACHE_FOLDER\n"; fi         
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $BRAVE_HOME_USR_CACHE_FOLDER n'existe pas !\n"; fi
	BRAVE_HOME_USR_CACHE_FOLDER_FOUND=false
fi
		


if [ -d "$BRAVE_HOME_USR_CONFIG_FOLDER" ]; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $BRAVE_HOME_USR_CONFIG_FOLDER existe !\n"; fi
	BRAVE_HOME_USR_CONFIG_FOLDER_FOUND=true
			
	# Calcul de la taille du dossier installé
	TAILLE_BRAVE_HOME_USR_CONFIG_FOLDER=$(du -sh "$BRAVE_HOME_USR_CONFIG_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $BRAVE_HOME_USR_CONFIG_FOLDER est : $TAILLE_BRAVE_HOME_USR_CONFIG_FOLDER\n"; fi         
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $BRAVE_HOME_USR_CONFIG_FOLDER n'existe pas !\n"; fi
	BRAVE_HOME_USR_CONFIG_FOLDER_FOUND=false
fi

# Controle du dossier 
if Recherche_dossier $BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER existe !\n"; fi
	BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER_FOUND=true
	TAILLE_BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER=$(du -sh "$BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER n'existe pas !\n"; fi
	BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER_FOUND=false
fi


		
# Recherche de fichiers archives dans le système
fichiers=("$BRAVE_VAR_CACHE_APT_ARCHIVES"/brave*)

if [[ -e "${fichiers[0]}" ]] ; then
	# Calcul de la taille du fichier installé
	TAILLE_BRAVE_VAR_CACHE_APT_ARCHIVES_FILENAME=$(du -sh "${fichiers[0]}" | cut -f1)

	if $SHOW_ANALYSE_LINES; then echo -e "Un fichier commençant par '$TXT_APP_TO_INSTALL' appelé $(basename ${fichiers[0]}) ($TAILLE_BRAVE_VAR_CACHE_APT_ARCHIVES_FILENAME) existe dans $BRAVE_VAR_CACHE_APT_ARCHIVES !\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "Aucun fichier commençant par '$TXT_APP_TO_INSTALL' dans $BRAVE_VAR_CACHE_APT_ARCHIVES !\n"; fi
fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BRAVE_OPT_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_BRAVE_OPT_FILENAME
tableau[$tab_ind,chemin]=$BRAVE_OPT_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BRAVE_USR_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_BRAVE_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$BRAVE_USR_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BRAVE_HOME_USR_CACHE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_BRAVE_HOME_USR_CACHE_FOLDER
tableau[$tab_ind,chemin]=$BRAVE_HOME_USR_CACHE_FOLDER
tableau[$tab_ind,commentaires]="N'existe pas tant que Brave n'a pas ete lance"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BRAVE_HOME_USR_CONFIG_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_BRAVE_HOME_USR_CONFIG_FOLDER
tableau[$tab_ind,chemin]=$BRAVE_HOME_USR_CONFIG_FOLDER
tableau[$tab_ind,commentaires]="N'existe pas tant que Brave n'a pas ete lance"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER
tableau[$tab_ind,chemin]=$BRAVE_HOME_USER_CONFIG_BRAVE_BRAVE_DEFAULT_FOLDER
tableau[$tab_ind,commentaires]="Dossier contenant les favoris, cookies, historique et signatures"



if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers ont été trouvés
		if $BRAVE_OPT_FILENAME_FOUND && $BRAVE_USR_SHARE_DOC_FOLDER_FOUND && ! $BRAVE_HOME_USR_CACHE_FOLDER_FOUND && ! $BRAVE_HOME_USR_CONFIG_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée mais n'a jamais été lancée !\n"
		fi

		# Si tous les fichiers et/ou dossiers ont été trouvés
		if $BRAVE_OPT_FILENAME_FOUND && $BRAVE_USR_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet installé
			if dpkg -l brave-browser &>/dev/null ; then
				brave-browser --version
				
				echo -e ""
			
				dpkg -l brave-browser
				
				echo -e ""
			fi		
		fi
		
		# Si aucun des fichiers et/ou dossiers recherchés ont été trouvés
		if ! $BRAVE_OPT_FILENAME_FOUND && ! $BRAVE_USR_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			# Contrôle de la présence d'un fichier Brave dans le dossier apt
			if [[ -f "$BRAVE_APT_FILENAME" ]] ; then
				# Le fichier Brave est présent
				echo -e "Le dépôt de Brave est déja présent dans le dossier des apt\n"

				# Installation de Brave
				sudo apt install brave-browser -y
			else
				# Le fichier Brave n'est pas présent
				echo -e "❌ Le dépôt de Brave n'est pas présent dans le dossier des apt\n"

				# Installation des dépendances nécessaires
				sudo apt install curl

				# Téléchargement et installation de la clé GPG de Brave
				sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

				sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

				# Mise à jour de l'index des paquets
				sudo apt update

				# Installation de Brave (Si dernière version déja installé, ne fait rien et affiche l'indice de la version installée) 
				sudo apt install brave-browser -y

			fi		
		fi
	;;
	
	*)
		echo -e "Aucun type d'installation choisi, code à revoir !\n"
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l installation du logiciel Brave via apt et procédure d'installation officielle du site Brave https://brave.com/linux/"
echo -e $TEXT_RESET

#################
############################## BRAVE ####################################
fi # if $INSTALL_BRAVE; then



if $INSTALL_PROTON_MAIL || $INSTALL_ALL; then
############################## PROTON MAIL ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Proton Mail"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

# Options de la procédure d'installation
OPT_SHOW_DETAILLED_INFOS_FROM_SNAP_PACKAGE=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Proton-Mail"

# Chemin du dossier apt pour contrôler sa présence
PROTON_MAIL_SNAP_BIN_FILENAME="/snap/bin/proton-mail"
PROTON_MAIL_SNAP_FOLDER="/snap/proton-mail"
# Booléens associés
PROTON_MAIL_SNAP_BIN_FILENAME_FOUND=false
PROTON_MAIL_SNAP_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$PROTON_MAIL_SNAP_BIN_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $PROTON_MAIL_SNAP_BIN_FILENAME existe !\n"; fi
	PROTON_MAIL_SNAP_BIN_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_PROTON_MAIL_SNAP_BIN_FILENAME=$(du -sh "$PROTON_MAIL_SNAP_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $PROTON_MAIL_SNAP_BIN_FILENAME est : $TAILLE_PROTON_MAIL_SNAP_BIN_FILENAME\n"; fi            
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $PROTON_MAIL_SNAP_BIN_FILENAME n'existe pas !\n"; fi
	PROTON_MAIL_SNAP_BIN_FILENAME_FOUND=false
fi

if [ -d "$PROTON_MAIL_SNAP_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $PROTON_MAIL_SNAP_FOLDER existe !\n"; fi
	PROTON_MAIL_SNAP_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_PROTON_MAIL_SNAP_FOLDER=$(du -sh "$PROTON_MAIL_SNAP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $PROTON_MAIL_SNAP_FOLDER est : $TAILLE_PROTON_MAIL_SNAP_FOLDER\n"; fi         
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $PROTON_MAIL_SNAP_FOLDER n'existe pas !\n"; fi
        PROTON_MAIL_SNAP_FOLDER_FOUND=false
fi



declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$PROTON_MAIL_SNAP_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_PROTON_MAIL_SNAP_BIN_FILENAME
tableau[$tab_ind,chemin]=$PROTON_MAIL_SNAP_BIN_FILENAME
tableau[$tab_ind,commentaires]="Lien vers l'application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$PROTON_MAIL_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_PROTON_MAIL_SNAP_FOLDER
tableau[$tab_ind,chemin]=$PROTON_MAIL_SNAP_FOLDER
tableau[$tab_ind,commentaires]="Dossier snap de l'application"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_SNAP)
		if $PROTON_MAIL_SNAP_BIN_FILENAME_FOUND && $PROTON_MAIL_SNAP_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet FWUPD installé
			snap list | grep proton-mail
			
			echo -e ""
			
			if $OPT_SHOW_DETAILLED_INFOS_FROM_SNAP_PACKAGE; then		# Si le booléen est vrai
				echo -e "Informations détaillées sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
						
				echo -e "Résultats de la commande 'snap info proton-pass :\n"
					
				snap info proton-mail
						
				echo -e ""
			fi			
		fi

		if ! $PROTON_MAIL_SNAP_BIN_FILENAME_FOUND && ! $PROTON_MAIL_SNAP_FOLDER_FOUND; then
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via TXT_SETUP_TYPE_SNAP :\n"

			sudo snap install proton-mail
				
			echo -e ""

			echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via TXT_SETUP_TYPE_SNAP !\n"
		fi	
	

	;;
	# SNAP - Fin setup type SNAP
		
	*)
		
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## PROTON MAIL ####################################
fi # if $INSTALL_PROTON_MAIL; then

if $INSTALL_PROTON_PASS || $INSTALL_ALL; then
############################## PROTON PASS ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Proton Pass"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

# Options de la procédure d'installation
OPT_SHOW_DETAILLED_INFOS_FROM_SNAP_PACKAGE=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
PROTON_PASS_SNAP_FILENAME="/snap/proton-pass/43/usr/bin/proton-pass"
PROTON_PASS_SNAP_FOLDER="/snap/proton-pass"

# Chemins des fichiers et/ou dossiers utilisateurs
# Récupération du répertoire utilisateur, dépend du nom d'utilisateur
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")
# Dossiers utilisateur
PROTON_PASS_USER_SNAP_APP_NAME="proton-pass"
PROTON_PASS_USER_SNAP_APP_FOLDER="$HOME_USER_FOLDER/snap/$PROTON_PASS_USER_SNAP_APP_NAME"

# Booléens
PROTON_PASS_SNAP_FOLDER_FOUND=false
PROTON_PASS_SNAP_FILENAME_FOUND=false
# Booléens utilisateur
PROTON_PASS_USER_SNAP_APP_FOLDER_FOUND=false

# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$PROTON_PASS_SNAP_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $PROTON_PASS_SNAP_FILENAME existe !\n"; fi
        PROTON_PASS_SNAP_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_PROTON_PASS_SNAP_FILENAME=$(du -sh "$PROTON_PASS_SNAP_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $PROTON_PASS_SNAP_FILENAME est : $TAILLE_PROTON_PASS_SNAP_FILENAME\n"; fi          
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $PROTON_PASS_SNAP_FILENAME n'existe pas !\n"; fi
        PROTON_PASS_SNAP_FILENAME_FOUND=false
fi

if [ -d "$PROTON_PASS_SNAP_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $PROTON_PASS_SNAP_FOLDER existe !\n"; fi
        PROTON_PASS_SNAP_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_PROTON_PASS_SNAP_FOLDER=$(du -sh "$PROTON_PASS_SNAP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $PROTON_PASS_SNAP_FOLDER est : $TAILLE_PROTON_PASS_SNAP_FOLDER\n"; fi          
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $PROTON_PASS_SNAP_FOLDER n'existe pas !\n"; fi
        PROTON_PASS_SNAP_FOLDER_FOUND=false
fi

# Contrôle du dossier snap utilisateur (si installé en mode user)
if [ -d "$PROTON_PASS_USER_SNAP_APP_FOLDER" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $PROTON_PASS_USER_SNAP_APP_FOLDER existe !\n"; fi
        PROTON_PASS_USER_SNAP_APP_FOLDER_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_PROTON_PASS_USER_SNAP_APP_FOLDER=$(du -sh "$PROTON_PASS_USER_SNAP_APP_FOLDER" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $PROTON_PASS_USER_SNAP_APP_FOLDER est : $TAILLE_PROTON_PASS_USER_SNAP_APP_FOLDER\n"; fi          
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $PROTON_PASS_USER_SNAP_APP_FOLDER n'existe pas !\n"; fi
        PROTON_PASS_USER_SNAP_APP_FOLDER_FOUND=false
fi



declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$PROTON_PASS_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_PROTON_PASS_SNAP_FOLDER
tableau[$tab_ind,chemin]=$PROTON_PASS_SNAP_FOLDER
tableau[$tab_ind,commentaires]="Dossier snap de l'application"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$PROTON_PASS_SNAP_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_PROTON_PASS_SNAP_FILENAME
tableau[$tab_ind,chemin]=$PROTON_PASS_SNAP_FILENAME
tableau[$tab_ind,commentaires]="Dossier snap de la revision 43 de l'application (disparu en mars 2026)"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$PROTON_PASS_USER_SNAP_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_PROTON_PASS_USER_SNAP_APP_FOLDER
tableau[$tab_ind,chemin]=$PROTON_PASS_USER_SNAP_APP_FOLDER
tableau[$tab_ind,commentaires]="Dossier utilisateur si installe en mode user"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_SNAP)
		if $PROTON_PASS_SNAP_FOLDER_FOUND; then
			# Contrôle d'une version existante et installation de l'application via Snap
			if snap list | grep -q "^proton-pass "; then
				echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"
					
				echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"

				# Affichage de la version du paquet Proton-Pass installé
				snap list | grep proton-pass
					
				echo -e ""
					
				if $OPT_SHOW_DETAILLED_INFOS_FROM_SNAP_PACKAGE; then		# Si le booléen est vrai
					echo -e "Informations détaillées sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
						
					echo -e "Résultats de la commande 'snap info proton-pass :\n"
					
					snap info proton-pass
						
					echo -e ""
				fi			
			else
				echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée via $TXT_SETUP_TYPE_SNAP !\n"
			fi
		fi
		
		if ! $PROTON_PASS_SNAP_FOLDER_FOUND; then
			# Contrôle d'une version existante et installation de l'application via Snap
			if snap list | grep -q "^proton-pass "; then
				echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"
				
				echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
				
				snap info proton-pass
				
				echo -e ""				
			else
				echo -e "Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP n'a été détectée !\n"
				
				echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"

				echo -e "Installation de l'application $TXT_APP_TON_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
				
				sudo snap install proton-pass
				
				echo -e ""
				
				echo -e "✅ Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"				
			fi
		fi		
	;;
	
	*)
		
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## PROTON PASS ####################################
fi # if $INSTALL_PROTON_PASS; then


if $INSTALL_PROTON_AUTH || $INSTALL_ALL; then
############################## PROTON AUTHENTICATOR ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Proton Authenticator"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_DEB

# Options d'analyse
SHOW_ANALYSE_LINES=false

# Options de la procédure d'installation
OPT_SHOW_DETAILLED_INFOS_FROM_SNAP_PACKAGE=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux 
PROTON_AUTH_LOCAL_DEB_FILENAME="ProtonAuthenticator_1.1.4_amd64.deb"
PROTON_AUTH_LOCAL_DEB_FOLDER=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/DEB
PROTON_AUTH_LOCAL_DEB_FILENAME_FULLPATH=$PROTON_AUTH_LOCAL_DEB_FOLDER/$PROTON_AUTH_LOCAL_DEB_FILENAME

# Chemin du dossier apt pour contrôler sa présence
PROTON_AUTH_USR_BIN_FILENAME="/usr/bin/proton-authenticator"
# Booléens
PROTON_AUTH_USR_BIN_FILENAME_FOUND=false

# Chemins utilisateurs
PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER="/home/kvm-user/.cache/me.proton.authenticator"
# Booléens associés
PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER_FOUND=false


# Contrôle de la présence de fichiers et/ou dossiers existants
if [ -f "$PROTON_AUTH_USR_BIN_FILENAME" ]; then
        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $PROTON_AUTH_USR_BIN_FILENAME existe !\n"; fi
        PROTON_AUTH_USR_BIN_FILENAME_FOUND=true
        
	# Calcul de la taille du dossier installé
	TAILLE_PROTON_AUTH_USR_BIN_FILENAME=$(du -sh "$PROTON_AUTH_USR_BIN_FILENAME" | cut -f1)

	# Affichage console de la taille du dossier installé
	if $SHOW_ANALYSE_LINES; then echo -e "La taille du fichier $PROTON_AUTH_USR_BIN_FILENAME est : $TAILLE_PROTON_AUTH_USR_BIN_FILENAME\n"; fi          
else
        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $PROTON_AUTH_USR_BIN_FILENAME n'existe pas !\n"; fi
        PROTON_AUTH_USR_BIN_FILENAME_FOUND=false
fi

if Recherche_dossier $PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER existe !\n"; fi
	PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER_FOUND=true
	TAILLE_PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER=$(du -sh "$PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER n'existe pas !\n"; fi
	PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER_FOUND=false
fi


declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$PROTON_AUTH_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_PROTON_AUTH_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$PROTON_AUTH_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Executable"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER
tableau[$tab_ind,chemin]=$PROTON_AUTH_HOME_USER_CACHE_PROTON_FOLDER
tableau[$tab_ind,commentaires]="Dossier utilisateur cache si installe en mode user"




if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""



case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_DEB)
		echo -e "Début de la procédure d'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB :\n"	
		if $PROTON_AUTH_SNAP_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_DEB ou $TXT_SETUP_TYPE_APT !\n"
				
			echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB ou $TXT_SETUP_TYPE_APT :\n"
				
			dpkg -l proton-authenticator
				
			echo -e ""		
		fi

		if ! $PROTON_AUTH_SNAP_FOLDER_FOUND; then
			echo -e "Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP n'a été détectée !\n"
				
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"

			echo -e "Installation de l'application $TXT_APP_TON_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
				
			sudo dpkg -i $PROTON_AUTH_LOCAL_DEB_FILENAME_FULLPATH
				
			echo -e ""
		fi
		
		echo -e "Fin de la procédure d'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_DEB !\n"	
	;;
	
	*)
		
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## PROTON AUTHENTICATOR ####################################
fi # if $INSTALL_PROTON_AUTH; then

if $INSTALL_PYCHARM || $INSTALL_ALL; then
############################## PYCHARM ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Template_appname"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
APPNAME_USR_BIN_FILENAME="/usr/bin/app_bin_template"
APPNAME_USR_SHARE_FOLDER="/usr/share/app_template"
# Booléens associés
APPNAME_USR_BIN_FILENAME_FOUND=false
APPNAME_USR_SHARE_FOLDER_FOUND=false
# Tailles (nécessaire si fichier et/ou dossier absent)
TAILLE_APPNAME_USR_BIN_FILENAME=""
TAILLE_APPNAME_USR_SHARE_FOLDER=""


# Contrôle de fichier
if Recherche_fichier $APPNAME_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $APPNAME_USR_BIN_FILENAME existe !\n"; fi
	APPNAME_USR_BIN_FILENAME_FOUND=true
	TAILLE_APPNAME_USR_BIN_FILENAME=$(du -sh "$APPNAME_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $APPNAME_USR_BIN_FILENAME n'existe pas !\n"; fi
	APPNAME_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $APPNAME_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $APPNAME_USR_SHARE_FOLDER existe !\n"; fi
	APPNAME_USR_SHARE_FOLDER_FOUND=true
	TAILLE_APPNAME_USR_SHARE_FOLDER=$(du -sh "$APPNAME_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $APPNAME_USR_SHARE_FOLDER n'existe pas !\n"; fi
	APPNAME_USR_SHARE_FOLDER_FOUND=false
fi


declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$APPNAME_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_APPNAME_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$APPNAME_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$APPNAME_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_APPNAME_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$APPNAME_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""






case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $APPNAME_USR_BIN_FILENAME_FOUND && $APPNAME_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND || ! $APPNAME_USR_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND && ! $APPNAME_USR_SHARE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
	
	;;

	$TXT_SETUP_TYPE_SNAP)
	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## PYCHARM (FIN) #################################### 
fi # if $INSTALL_PYCHARM || $INSTALL_ALL; then


if $INSTALL_WIRESHARK || $INSTALL_ALL; then
############################## WIRESHARK ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Wireshark"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
WIRESHARK_USR_BIN_FILENAME="/usr/bin/wireshark"
WIRESHARK_USR_SHARE_FOLDER="/usr/share/wireshark"

WIRESHARK_APT_FILENAME="/etc/apt/sources.list.d/wireshark-dev-ubuntu-stable-questing.sources"

# Booléens associés
WIRESHARK_USR_BIN_FILENAME_FOUND=false
WIRESHARK_USR_SHARE_FOLDER_FOUND=false

# Contrôle du fichier
if Recherche_fichier $WIRESHARK_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $WIRESHARK_USR_BIN_FILENAME existe !\n"; fi
	WIRESHARK_USR_BIN_FILENAME_FOUND=true
	TAILLE_WIRESHARK_USR_BIN_FILENAME=$(du -sh "$WIRESHARK_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $WIRESHARK_USR_BIN_FILENAME n'existe pas !\n"; fi
	WIRESHARK_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du fichier
if Recherche_fichier $WIRESHARK_APT_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $WIRESHARK_APT_FILENAME existe !\n"; fi
	WIRESHARK_APT_FILENAME_FOUND=true
	TAILLE_WIRESHARK_APT_FILENAME=$(du -sh "$WIRESHARK_APT_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $WIRESHARK_APT_FILENAME n'existe pas !\n"; fi
	WIRESHARK_APT_FILENAME_FOUND=false
fi

# Contrôle du dossier
if Recherche_dossier $WIRESHARK_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $WIRESHARK_USR_SHARE_FOLDER existe !\n"; fi
	WIRESHARK_USR_SHARE_FOLDER_FOUND=true
	TAILLE_WIRESHARK_USR_SHARE_FOLDER=$(du -sh "$WIRESHARK_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $WIRESHARK_USR_SHARE_FOLDER n'existe pas !\n"; fi
	WIRESHARK_USR_SHARE_FOLDER_FOUND=false
fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$WIRESHARK_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_WIRESHARK_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$WIRESHARK_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$WIRESHARK_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_WIRESHARK_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$WIRESHARK_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $WIRESHARK_USR_BIN_FILENAME_FOUND && $WIRESHARK_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			# Affichage de la version du paquet installé
			dpkg -l wireshark
			
			echo -e ""
		fi

		# Si au moins un des fichiers et/ou dossiers recherchés n'a pas été trouvé
		if ! $WIRESHARK_USR_BIN_FILENAME_FOUND || ! $WIRESHARK_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# Si tous les fichiers et/ou dossiers recherchés n'ont pas été trouvés
		if ! $WIRESHARK_USR_BIN_FILENAME_FOUND && ! $WIRESHARK_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

			# Contrôle de la présence du dépôt ppa dans le dossier des apt
			if [ -f "$WIRESHARK_APT_FILENAME" ]; then
				# Le dépot est présent dans le dossier des sources
				echo -e "✅ Le dépôt ppa de Wireshark est déja présent dans le dossier des sources apt\n"

				# Répondre à 'Faux' pour la question lors de l'installation 'apt install' pour 'Should non-superusers be able to capture packets?'
				echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections

				# Installation de Wireshark
				sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
			else
				# Le dépôt n'est pas présent dans le dossier des sources apt
				echo -e "❌ Le dépôt ppa de Wireshark n'est pas présent dans le dossier des sources apt\n"

				# Ajout du dépôt ppa de Wireshark
				sudo add-apt-repository ppa:wireshark-dev/stable -y

				# Installation de Wireshark
				echo -e "Installation de l'application $TXT_APP_TON_INSTALL via $TXT_SETUP_TYPE_APT"
				
				# Répondre à 'Faux' pour la question lors de l'installation 'apt install' pour 'Should non-superusers be able to capture packets?'
				echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections
				
				sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
			fi
		fi	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## WIRESHARK ####################################
fi # if $INSTALL_WIRESHARK; then

# if $INSTALL_STELLARIUM || $INSTALL_ALL; then
if $INSTALL_STELLARIUM;then
############################## STELLARIUM ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Stellarium"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE avec l'ajout du dépôt ppa"
echo -e $TEXT_RESET

# Chemin du dossier apt de Stellarium pour contrôler sa présence
STELLARIUM_USR_BIN_FILENAME="/usr/bin/stellarium"
STELLARIUM_USR_SHARE_FOLDER="/usr/share/stellarium"
STELLARIUM_USR_SHARE_DOC_STELLARIUM="/usr/share/doc/stellarium"

# Booléens associés
STELLARIUM_USR_BIN_FILENAME_FOUND=false
STELLARIUM_USR_SHARE_FOLDER_FOUND=false
STELLARIUM_USR_SHARE_DOC_STELLARIUM_FOUND=false

# Contrôle du fichier
if Recherche_fichier $STELLARIUM_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $STELLARIUM_USR_BIN_FILENAME existe !\n"; fi
	STELLARIUM_USR_BIN_FILENAME_FOUND=true
	TAILLE_STELLARIUM_USR_BIN_FILENAME=$(du -sh "$STELLARIUM_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $STELLARIUM_USR_BIN_FILENAME n'existe pas !\n"; fi
	STELLARIUM_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier
if Recherche_dossier $STELLARIUM_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STELLARIUM_USR_SHARE_FOLDER existe !\n"; fi
	STELLARIUM_USR_SHARE_FOLDER_FOUND=true
	TAILLE_STELLARIUM_USR_SHARE_FOLDER=$(du -sh "$STELLARIUM_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STELLARIUM_USR_SHARE_FOLDER n'existe pas !\n"; fi
	STELLARIUM_USR_SHARE_FOLDER_FOUND=false
fi	

# Contrôle du dossier	
if Recherche_dossier $STELLARIUM_USR_SHARE_DOC_STELLARIUM; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STELLARIUM_USR_SHARE_DOC_STELLARIUM existe !\n"; fi
	STELLARIUM_USR_SHARE_DOC_STELLARIUM_FOUND=true
	TAILLE_STELLARIUM_USR_SHARE_DOC_STELLARIUM=$(du -sh "$STELLARIUM_USR_SHARE_DOC_STELLARIUM" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STELLARIUM_USR_SHARE_DOC_STELLARIUM n'existe pas !\n"; fi
	STELLARIUM_USR_SHARE_DOC_STELLARIUM_FOUND=false
fi



case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		if $STELLARIUM_USR_BIN_FILENAME_FOUND && $STELLARIUM_USR_SHARE_FOLDER_FOUND && $STELLARIUM_USR_SHARE_DOC_STELLARIUM_FOUND ; then
			echo -e "Tous les fichiers et/ou dossiers recherchés ont été trouvés !\n"
		
                        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

                        echo -e "Informations sur la version installée :\n"

                        # Affichage de la version du paquet installé
                        dpkg -l stellarium			
		fi
		
		if ! $STELLARIUM_USR_BIN_FILENAME_FOUND || ! $STELLARIUM_USR_SHARE_FOLDER_FOUND || ! $STELLARIUM_USR_SHARE_DOC_STELLARIUM_FOUND ; then
			echo -e "il manque un ou plusieurs fichiers et/ou dossiers ! Installation corrompue !\n"
		fi
		
		if ! $STELLARIUM_USR_BIN_FILENAME_FOUND && ! $STELLARIUM_USR_SHARE_FOLDER_FOUND && ! $STELLARIUM_USR_SHARE_DOC_STELLARIUM_FOUND ; then
			echo -e "Aucune installation existante de Stellarium trouvée"

		        # Contrôle de la présence du dépôt ppa dans la liste des apt
		        if grep -r "stellarium" /etc/apt/sources.list.d/; then

		                echo -e ""

		                echo -e "✅ Le dépôt ppa de Stellarium est déja présent dans la liste des apt\n"

		                # Installation de Stellarium
		                yes "" | sudo apt install -y stellarium
		        else
		                echo -e "❌ Le dépôt ppa de Stellarium n'est pas présent dans la liste des apt\n"

		                # Ajout du dépôt ppa de Stellarium
		                sudo add-apt-repository ppa:stellarium/stellarium-releases

		                # Mise à jour de l'index des paquets
		                sudo apt update

		                # Installation de Stellarium
		                # yes "" | sudo apt install -y stellarium
		                yes '' | sudo apt install -y stellarium 		# Modif 18/03/2026
		                
		                # yes '' génère une série de lignes vides (simulant des appuis sur Entrée)
		                # Le pipe | envoie ces entrées à la commande suivante
		                # sudo apt install -y stellarium installe le paquet avec confirmation automatique pour les prompts classiques
		        fi		
		fi

	;;
	# APT - Fin Setup type

	*)

	;;
esac

# Procédure de désinstallation pour info si besoin
echo -e "\nPour le désinstaller, utiliser la commande 'sudo apt remove --autoremove stellarium'"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## STELLARIUM ####################################
fi # if $INSTALL_STELLARIUM; then

if $INSTALL_THUNDERBIRD || $INSTALL_ALL; then
############################## THUNDERBIRD ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Thunderbird"

# Type d installation (APT, FLATPAK, SNAP, DPKG ou DEB)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=false

# Type d'installation (user ou system)
TXT_SETUP_OPT_SYSTEM_OR_USER="system"

# Options de la procédure d'installation
OPT_SHOW_DETAILLED_INFOS_FROM_SNAP_PACKAGE=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE en mode $TXT_SETUP_OPT_SYSTEM_OR_USER"
echo -e $TEXT_RESET

# Récupération du répertoire utilisateur
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

# Aller au répertoire utilisateur
# USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin des dossiers sous Ubuntu 25.10
THUNDERBIRD_APPARMOR_D_FILENAME="thunderbird"
THUNDERBIRD_APPARMOR_D_FOLDER="/etc/apparmor.d/"
THUNDERBIRD_APPARMOR_D_FILEPATH="$THUNDERBIRD_APPARMOR_D_FOLDER$THUNDERBIRD_APPARMOR_D_FILENAME"
THUNDERBIRD_LOCAL_SHARE_FOLDER="$HOME/.local/share/thunderbird"
THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER="$HOME_USER/Téléchargements/thunderbird.tmp"
THUNDERBIRD_USR_SHARE_HELP_FOLDER="/usr/share/help-langpack/fr/thunderbird"
THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER="/usr/lib/python3/dist-packages/orca/scripts/apps/Thunderbird"
THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER="/run/user/1000/.flatpak/org.mozilla.Thunderbird"
THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER="/var/lib/flatpak/app/org.mozilla.Thunderbird"
THUNDERBIRD_SNAP_FOLDER="/snap/thunderbird"
# Chemins utilisateur
THUNDERBIRD_FLATPAK_APP="org.mozilla.Thunderbird"
THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER="$HOME_USER/.var/app/$THUNDERBIRD_FLATPAK_APP"
THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME="thunderbird.desktop"
THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FOLDER="$HOME_USER/.local/share/applications"
THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH=$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FOLDER/$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME



# Initialisation des booléens des fichiers et/ou dossiers recherchés
THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER_FOUND=false
THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER_FOUND=false
THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER_FOUND=false
THUNDERBIRD_APPARMOR_D_FILEPATH_FOUND=false
THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH_FOUND=false
THUNDERBIRD_SNAP_FOLDER_FOUND=false
THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER_FOUND=false

# Tailles
TAILLE_THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER=""
TAILLE_THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER=""
TAILLE_THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER=""
TAILLE_THUNDERBIRD_APPARMOR_D_FILEPATH=""
TAILLE_THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER=""
TAILLE_THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH=""
TAILLE_THUNDERBIRD_SNAP_FOLDER=""
TAILLE_THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER=""


# Activer / désactiver débuguage si besoin
SHOW_ANALYSE_LINES=false

if Recherche_fichier $THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH existe !\n"; fi
	THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH_FOUND=true
	TAILLE_THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH=$(du -sh "$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH n'existe pas !\n"; fi
	THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH_FOUND=false
fi


# Contrôle du dossier 
if Recherche_dossier $THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER existe !\n"; fi
	THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER_FOUND=true
	TAILLE_THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER=$(du -sh "$THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER n'existe pas !\n"; fi
	THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER_FOUND=false
fi


# Contrôle du dossier 
if Recherche_dossier $THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER existe !\n"; fi
	THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER_FOUND=true
	TAILLE_THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER=$(du -sh "$THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER n'existe pas !\n"; fi
	THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER_FOUND=false
fi


# Contrôle du dossier 
if Recherche_dossier $THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER existe !\n"; fi
	THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=true
	TAILLE_THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER=$(du -sh "$THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER n'existe pas !\n"; fi
	THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER_FOUND=false
fi


# Contrôle du dossier 
if Recherche_dossier $THUNDERBIRD_SNAP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $THUNDERBIRD_SNAP_FOLDER existe !\n"; fi
	THUNDERBIRD_SNAP_FOLDER_FOUND=true
	TAILLE_THUNDERBIRD_SNAP_FOLDER=$(du -sh "$THUNDERBIRD_SNAP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $THUNDERBIRD_SNAP_FOLDER n'existe pas !\n"; fi
	THUNDERBIRD_SNAP_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER existe !\n"; fi
	THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER_FOUND=true
	TAILLE_THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER=$(du -sh "$THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER n'existe pas !\n"; fi
	THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER_FOUND=false
fi


# Contrôle du dossier 
if Recherche_dossier $THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER existe !\n"; fi
	THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER_FOUND=true
	TAILLE_THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER=$(du -sh "$THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER n'existe pas !\n"; fi
	THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER_FOUND=false
fi
	

if dpkg -S $THUNDERBIRD_APPARMOR_D_FILEPATH &>/dev/null; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le paquet $THUNDERBIRD_APPARMOR_D_FILEPATH est installé !\n"; fi			
	THUNDERBIRD_APPARMOR_D_FILEPATH_FOUND=true
	
        # Calcul de la taille du dossier installé
        TAILLE_THUNDERBIRD_APPARMOR_D_FILEPATH=$(du -sh "$THUNDERBIRD_APPARMOR_D_FILEPATH" | cut -f1)

        # Affichage console de la taille du dossier installé
        if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $THUNDERBIRD_APPARMOR_D_FILEPATH est : $TAILLE_THUNDERBIRD_APPARMOR_D_FILEPATH\n"; fi	
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le paquet $THUNDERBIRD_APPARMOR_D_FILEPATH n'est pas installé !\n"; fi
	THUNDERBIRD_APPARMOR_D_FILEPATH_FOUND=false
fi

# Controle et taille du dossier
#if [ -f "$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH" ]; then
#        if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier '$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH' existe !\n"; fi
        
#        THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH_FOUND=true
		        
        # Calcul de la taille du dossier installé
#        TAILLE_THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH=$(du -sh "$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH" | cut -f1)

        # Affichage console de la taille du dossier installé
#        if $SHOW_ANALYSE_LINES; then echo -e "La taille du dossier $THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH est : $TAILLE_THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH\n"; fi		        
#else
#        if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier '$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH' n'existe pas !\n"; fi
        
#        THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH_FOUND=false
#fi


	
		
# Contrôle d'une version déja installée via le gestionnaire de paquet Flatpak
if flatpak list | grep -q $THUNDERBIRD_FLATPAK_APP; then
        echo -e "$TXT_APP_TO_INSTALL via Flatpak déja installé\n"

	echo -e "Informations sur la version installée :\n"

        # Afficher la version de l'application via flatpak
        flatpak list --app | grep Thunderbird

	# Saut de ligne console
	echo -e ""

fi		



declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER
tableau[$tab_ind,chemin]=$THUNDERBIRD_USR_LIB_PYTHON3_DIST_PACKAGES_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER
tableau[$tab_ind,chemin]=$THUNDERBIRD_RUN_USER_1000_FLATPAK_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER
tableau[$tab_ind,chemin]=$THUNDERBIRD_FLATPAK_USER_VAR_APP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$THUNDERBIRD_APPARMOR_D_FILEPATH_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_APPARMOR_D_FILEPATH
tableau[$tab_ind,chemin]=$THUNDERBIRD_APPARMOR_D_FILEPATH
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,chemin]=$THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH
tableau[$tab_ind,chemin]=$THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$THUNDERBIRD_SNAP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_SNAP_FOLDER
tableau[$tab_ind,chemin]=$THUNDERBIRD_SNAP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER
tableau[$tab_ind,chemin]="${THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER//é/e}"					# Les accents créent des erreurs d'espaces dans l'affichage tableau. Pour remplacer plusieurs accents 'un coup utiliser la commande : 	ma_variable_sans_accent=$(echo "$ma_variable" | tr 'àéèêëùúûü' 'aeeeeuuuu')
# tableau[$tab_ind,chemin]=$(echo -n $THUNDERBIRD_HOME_USER_DOWNLOADS_THUNDERBIRD_FOLDER | iconv -f utf-8 -t iso-8859-1//TRANSLIT)
tableau[$tab_ind,commentaires]="Dossier temp alternatif snap pour stocker des fichiers ouverts directement depuis Thunderbird"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi


TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

# echo -e "$TABLEAU_COMMENTAIRES_SIZE"

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do

		# printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s| %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}" " ${tableau["$i,existe"]}" "  ${tableau["$i,taille"]}" " ${tableau["$i,chemin"]}" "${tableau["$i,commentaires"]}"
		#echo -e $TEXT_GREEN
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		#echo -e $TEXT_RESET
		
		#echo -e $TEXT_GREEN
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		
		
		#echo -e $TEXT_RESET
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"

		# echo -e "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s| %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}" " ${TEXT_GREEN}${tableau["$i,existe"]}${TEXT_RESET}" "  ${tableau["$i,taille"]}" " ${tableau["$i,chemin"]}" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""

# Analyse des fichiers et dossiers trouvés et installation si nécessaire
case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		if $THUNDERBIRD_SNAP_FOLDER_FOUND; then
			echo -e "✅ L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_APT !\n"
			
			echo -e "❗ Particularité pour Thunderbird : L'application APT est la même que SNAP, APT installe l'appli SNAP !\n"
		
			echo -e "Informations sur la version installée :\n"
			
			dpkg -l thunderbird
			
			echo -e ""
		fi
	
		if ! $THUNDERBIRD_SNAP_FOLDER_FOUND; then
			# Contrôle et désinstallation d'une version existante via Flatpak
			if flatpak info org.mozilla.Thunderbird &> /dev/null; then
				echo -e "❌ L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
				
				echo -e "Informations sur la version de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK"
				
				flatpak info org.mozilla.Thunderbird
				
				echo -e ""
				
				echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
						
				# Désinstallation Flatpak
				flatpak uninstall -y org.mozilla.Thunderbird
				
				echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"			
			else
				echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK n'a été détectée !\n"
			fi
			
			# Contrôle d'une version existante et installation de l'application via Snap
			if snap list | grep -q "^thunderbird "; then
				echo -e "❌ L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"
				
				echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
				
				snap info thunderbird
				
				echo -e ""
				
				echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
				
				# Désinstallation en gardant les données de configuration
				sudo snap remove thunderbird
				
				# Désinstallation en supprimant les données de configuration
				sudo snap remove --purge thunderbird
				
				echo -e ""
				
				echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"
			else
				echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP n'a été détectée !\n"
			fi		
		
			# Contrôle et désinstallation d'une version existante via APT
			if dpkg -l thunderbird 2> /dev/null | grep -q "^ii" ; then
				echo -e "✅ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
				
				echo -e "Informations sur la version de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK"
				
				dpkg -l thunderbird
				
				echo -e ""
			else
				echo -e "❌ Il n'existe pas de version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
				
				echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT : \n"
				
				sudo apt install thunderbird
				
				echo -e ""
				
				echo -e "Commande pour éviter les mises à jour automatique qui résinstallent la version Snap au lieu de APT :\n"
				
				echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-thunderbird
				
				echo -e ""
				
				echo -e "✅ Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
			fi	
		fi
	
		
		if ! $THUNDERBIRD_SNAP_FOLDER_FOUND && ! $THUNDERBIRD_HOME_USER_LOCAL_SHARE_APPLICATIONS_FILENAME_COMPLETE_PATH_FOUND; then
			# Réinstallation de Thunderbird via apt
			sudo apt install --reinstall thunderbird
		fi
		
	;;

	$TXT_SETUP_TYPE_FLATPAK)
		# Contrôle et désinstallation d'une version existante via APT
		if dpkg -l thunderbird 2> /dev/null | grep -q "^ii" ; then
			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT : \n"
			
			sudo apt remove -y thunderbird
			
			echo -e ""
			
			echo -e "Purge de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT : \n"
			
			sudo apt purge -y thunderbird
			
			echo -e "Nettoyage des dépendances orphelines :\n"
			
			sudo apt autoremove
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
		else
			echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT n'a été détectée !\n"
		fi
		
		# Contrôle d'une version existante et installation de l'application via Snap
		if snap list | grep -q "^thunderbird "; then
			echo -e "❌ L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_SNAP !\n"
			
			echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
			
			snap info thunderbird
			
			echo -e ""
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
			
			# Désinstallation en gardant les données de configuration
			sudo snap remove thunderbird
			
			# Désinstallation en supprimant les données de configuration
			sudo snap remove --purge thunderbird
			
			echo -e ""
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"
		else
			echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP n'a été détectée !\n"
		fi		
	
		# Vérification de la présence de Flatpak
                echo -e "Vérification de la présence de flatpak :\n"

                if [ ! command -v flatpak &> /dev/null ] ; then
                        echo -e "❌ Flatpak n'est pas installé\n"

                        echo -e "Ajout du dépôt Flathub nécessaire pour installer Thunderbird"

                        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

                        echo -e "Installation de Flatpak en cours nécessaire pour installer Thunderbird"

                        sudo apt install -y flatpak
                else
                        echo -e "✅ Flatpak est installé : $(flatpak --version) !\n"

                fi
                # Fin de la vérification de la présence de Flatpak

		if flatpak info org.mozilla.Thunderbird &> /dev/null; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Informations sur la version de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK"
			
			flatpak info org.mozilla.Thunderbird
			
			echo -e ""
		else
			echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK n'a été détectée !\n"
		fi
		
		# Analyse des fichiers et dossiers trouvés et installation si nécessaire	
		if ! $THUNDERBIRD_VAR_LIB_FLATPAK_APP_FOLDER_FOUND; then
			echo -e "Aucun des dossiers n'a été trouvés !\n"
			
			# Si le dépot flatpak de l'application n'est pas présent
			echo -e "Ajout du dépôt Flathub de $TXT_APP_TO_INSTALL (si pas déja fait)\n"

			flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo			
			
			echo -e "Installation de Thunderbird via Flatpak en mode $TXT_SETUP_OPT_SYSTEM_OR_USER !\n"

			flatpak install -y --$TXT_SETUP_OPT_SYSTEM_OR_USER flathub $THUNDERBIRD_FLATPAK_APP			# En mode user, l'icone n'apparait pas automatiquement !
			
			echo -e ""
			
			echo -e "❗ Rappel : l'application Flatpak de $TXT_APP_TO_INSTALL nouvellement installée apparaîtra après le redémarrage du système !\n"
			
		fi		
		
	;;
	
	$TXT_SETUP_TYPE_SNAP)
		# Contrôle et désinstallation d'une version existante via APT
		if dpkg -l thunderbird 2> /dev/null | grep -q "^ii" ; then
			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT : \n"
			
			sudo apt remove -y thunderbird
			
			echo -e ""
			
			echo -e "Purge de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT : \n"
			
			sudo apt purge -y thunderbird
			
			echo -e "Nettoyage des dépendances orphelines :\n"
			
			sudo apt autoremove
			
			echo -e ""
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
		else
			echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT n'a été détectée  !\n"
		fi
		
		# Contrôle et désinstallation d'une version existante via Flatpak
		if flatpak info org.mozilla.Thunderbird &> /dev/null; then
			echo -e "❌ L'application $TXT_APP_TO_INSTALL est déja installée via $TXT_SETUP_TYPE_FLATPAK !\n"
			
			echo -e "Informations sur la version de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK"
			
			flatpak info org.mozilla.Thunderbird
			
			echo -e ""
			
			echo -e "Début de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
					
			# Désinstallation Flatpak
			flatpak uninstall -y org.mozilla.Thunderbird
			
			echo -e "✅ Fin de la désinstallation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"			
		else
			echo -e "✅ Aucune installation existante de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK n'a été détectée !\n"
		fi		
	
		# Contrôle d'une version existante et installation de l'application via Snap
		if snap list | grep -q "thunderbird"; then
			echo -e "$TXT_APP_TO_INSTALL est installé via Snap !\n"
			
			snap list thunderbird
			
			if $OPT_SHOW_DETAILLED_INFOS_FROM_SNAP_PACKAGE; then
				echo -e "Informations sur la version de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
				
				snap info thunderbird
				
				echo -e ""			
			fi
		else
			echo "$TXT_APP_TO_INSTALL n'est pas installé via Snap."
			
			echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP :\n"
			
			case $TXT_SETUP_OPT_SYSTEM_OR_USER in
				"system")
					sudo snap install thunderbird
				;;
				
				"user")
					sudo snap install --user thunderbird
				;;
				
				*)
					echo -e "La variable '$TXT_SETUP_OPT_SYSTEM_OR_USER' d'option d'installation ('system' ou 'user') inscrite dans le code est incorrecte !\n"
				;;
			esac
			
			echo -e "✅ Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_SNAP !\n"
		fi
	;;
	
	*)
		echo -e "Aucun type d'installation trouvé (apt, Flatpak, Snap, deb) ! Aucune installation effectuée !\n"
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE en mode $TXT_SETUP_OPT_SYSTEM_OR_USER"
echo -e $TEXT_RESET

#################
############################## THUNDERBIRD (FIN) ####################################
fi # if $INSTALL_THUNDERBIRD; then

if $INSTALL_RHYTHMBOX || $INSTALL_ALL; then
############################## RHYTHMBOX ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="RhythmBox"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_FLATPAK

# Options d'analyse
SHOW_ANALYSE_LINES=false

# Option d'installation
SYSTEM_OR_USER="system"			# Le mode user ne semble pas recommandé car n'installe pas toutes les dépendances

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET


# Récupération du nom d'utilisateur actuel (pas root)
REAL_USER="${SUDO_USER:-$USER}"

# Récupération du répertoire utilisateur
HOME_USER_FOLDER=$(eval echo "~${SUDO_USER:-$USER}")

# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux
RHYTHMBOX_LOCAL_SHARE_FOLDER="$HOME_USER_FOLDER/.local/share/rhythmbox"
RHYTHMBOX_USR_SHARE_HELP_FOLDER="/usr/share/help-langpack/fr/rhythmbox"
RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER="/var/lib/flatpak/app/org.gnome.Rhythmbox3"		# Dossier créé en installation system de rhythmbox (system ou user)
FLATPAK_RHYTHMBOX_APP="org.gnome.Rhythmbox3"
RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER="$HOME_USER_FOLDER/.var/app/$FLATPAK_RHYTHMBOX_APP"
# Booléens
RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND=false
RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND=false
RHYTHMBOX_USR_SHARE_HELP_FOLDER_FOUND=false
RHYTHMBOX_VIA_FLATPAK_ALREADY_INSTALLED=false
# Tailles
TAILLE_RHYTHMBOX_USR_SHARE_HELP_FOLDER=""
TAILLE_RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER=""
TAILLE_RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER=""


# CHMOD des fichiers et/ou dossiers à vérifier ou créer
# Le 1er chiffre doit impérativement être 7 pour donner tous les accès à l'utilisateur qui installe l'application. 
# Les 2 autres chiffres sont au choix mais 0 est préférable pour sécuriser
RHYTHMBOX_CHMOD_FILES_AND_FOLDERS=761
RHYTHMBOX_CHMOD_RHYTHMDB_XML_FILE=777



# Contrôle du dossier 
if Recherche_dossier $RHYTHMBOX_USR_SHARE_HELP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $RHYTHMBOX_USR_SHARE_HELP_FOLDER existe !\n"; fi
	RHYTHMBOX_USR_SHARE_HELP_FOLDER_FOUND=true
	TAILLE_RHYTHMBOX_USR_SHARE_HELP_FOLDER=$(du -sh "$RHYTHMBOX_USR_SHARE_HELP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $RHYTHMBOX_USR_SHARE_HELP_FOLDER n'existe pas !\n"; fi
	RHYTHMBOX_USR_SHARE_HELP_FOLDER_FOUND=false
fi


# Contrôle et taille du dossier
if $SHOW_ANALYSE_LINES; then echo -e "Contrôle de la présence du dossier $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER (dossier utilisateur local) :\n"; fi

# Contrôle du dossier 
if Recherche_dossier $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER existe !\n"; fi
	RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND=true
	TAILLE_RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER=$(du -sh "$RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER n'existe pas !\n"; fi
	RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND=false
fi

if $SHOW_ANALYSE_LINES; then echo -e "Contrôle de la présence du dossier $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER (dossier system) :\n"; fi
		
# Contrôle du dossier 
if Recherche_dossier $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER existe !\n"; fi
	RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND=true
	TAILLE_RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER=$(du -sh "$RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER n'existe pas !\n"; fi
	RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND=false
fi

# Vérification d'une version déja installée sous apt
if $SHOW_ANALYSE_LINES; then echo -e "Vérification d'une version de l'application $TXT_APP_TO_INSTALL déja installée sous apt :\n"; fi

if dpkg -l rhythmbox &> /dev/null ; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée sous apt !\n"; fi
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Il n'existe pas de version de l'application $TXT_APP_TO_INSTALL déja installée sous apt !\n"; fi
fi

# Test temporaire
declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$RHYTHMBOX_USR_SHARE_HELP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_RHYTHMBOX_USR_SHARE_HELP_FOLDER
tableau[$tab_ind,chemin]=$RHYTHMBOX_USR_SHARE_HELP_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER
tableau[$tab_ind,chemin]=$RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER
tableau[$tab_ind,chemin]=$RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_FLATPAK)
		echo -e "Début de la procédure d'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK :\n"

		# Vérification d'une version déja installée sous apt
		echo -e "Vérification d'une version existante de l'application $TXT_APP_TO_INSTALL déja installée (car installée dans le noyau de la version complète d'Ubuntu 25.10) :\n"
				
		# Contrôle et désinstallation d'une version existante de Rhythmbox via APT
		if dpkg -l rhythmbox 2> /dev/null | grep -q "^ii" ; then
			echo -e "❌ Il existe une version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT !\n"
			
			echo -e "Détails sur la version de l'application $TXT_APP_TO_INSTALL déja installée via $TXT_SETUP_TYPE_APT :\n"
			
			dpkg -l rhythmbox
			
			echo -e ""
		
			# Désinstallation d'une version existante de Rhythmbox via APT (pour éviter un doublon avec l'installation de Rhythmbox via Flatpak)
			echo -e "Début de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			echo -e "Suppression de Rhythmbox en $TXT_SETUP_TYPE_APT (sans supprimer les fichiers de configuratiuon) :\n"
			
			sudo apt-get remove -y rhythmbox
			
			echo -e ""
			
			echo -e "Suppression de Rhythmbox et de tous les fichiers de configuration :\n"
			
			sudo apt-get purge -y rhythmbox
			
			echo -e ""
			
			echo -e "Nettoyage des dépendances inutiles de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT :\n"
			
			sudo apt-get autoremove -y
			
			echo -e ""
			
			echo -e "Fin de la désinstallation de l'application $TXT_APP_TO_INSTALL en $TXT_SETUP_TYPE_APT\n"
		else
			echo -e "✅ Il n'existe pas de version de l'application $TXT_APP_TO_INSTALL déja installée sous apt !\n"
		fi		
		# Vérification d'une version déja installée sous apt (FIN)

		# Vérification d'une version déja installée sous Flatpak
                echo -e "Vérification de la présence de $TXT_SETUP_TYPE_FLATPAK :\n"

                if dpkg -l flatpak &> /dev/null ; then
                        echo -e "Flatpak est présent pour installer $TXT_APP_TO_INSTALL !\n"
                else
                        echo -e "Flatpak n'est pas présent pour installer $TXT_APP_TO_INSTALL ! \n"
                        
                        echo -e "Début de l'installation de Flatpak en cours nécessaire pour installer $TXT_APP_TO_INSTALL :\n"

                        sudo apt install -y flatpak
                        
                        echo -e "Fin de l'installation de Flatpak en cours nécessaire pour installer $TXT_APP_TO_INSTALL :\n"
                fi

                if [ ! command -v flatpak &> /dev/null ] ; then
                        echo -e "❌ Flatpak n'est pas installé\n"

                        echo -e "Ajout du dépôt Flathub nécessaire pour installer $TXT_APP_TO_INSTALL"

                        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

                        echo -e "Installation de Flatpak en cours nécessaire pour installer $TXT_APP_TO_INSTALL"

                        sudo apt install -y flatpak
                else
                        echo -e "✅ Flatpak est installé : $(flatpak --version) !\n"

                fi
		# Vérification d'une version déja installée sous Flatpak (FIN)
		

		
		# Analyse des résultats des fichiers et/ou dossiers recherchés
		# Si les 2 dossiers (system et user) recherchés existent
		if $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND && $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND ; then
			echo -e "✅ Tous les fichiers et/ou dossiers recherchés ont été trouvés !\n"
			
			echo -e "❗ L'application $TXT_APP_TO_INSTALL est installée 2 fois : en mode system et user !\n"
		fi
		
		# Si le dossier system uniquement est présent, pas le dossier user (dépend du type d'installation choisi)
		if ! $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND && $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND ; then
			echo -e "✅ L'application $TXT_APP_TO_INSTALL est déjà installée en mode system !\n"		
		fi
		
		# Si le dossier user uniquement est présent, pas le dossier user (dépend du type d'installation choisi)
		if $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND && ! $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND ; then
			echo -e "✅ L'application $TXT_APP_TO_INSTALL est déjà installée en mode user !\n"
		fi		
		
		# Si le dossier system ou user est présent, on affiche les détails de la version installée
		if $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND || $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND ; then
			# Contrôle d'une version déja installée via le gestionnaire de paquet Flatpak
			if flatpak list | grep -q org.gnome.Rhythmbox3 ; then
				echo -e "Rhythmbox via Flatpak déja installé !\n"
				RHYTHMBOX_VIA_FLATPAK_ALREADY_INSTALLED=true

				echo -e "Informations sur la version installée :\n"

				# Afficher la version de RhythmBox via flatpak
				flatpak list --app | grep Rhythmbox

				# Saut de ligne console
				echo -e ""
			else
				echo -e "Rhythmbox via Flatpak n'est pas installé !\n"
				RHYTHMBOX_VIA_FLATPAK_ALREADY_INSTALLED=false
			fi			
		fi
		
		# Si le dossier Flatpak de Rhymthmbox n'existe pas ni en mode user, ni en mode system, ou qu'aucune installation via flatpak n'a été détecté, on installe l'appli		
		if ! $RHYTHMBOX_HOME_USER_VAR_APP_FLATPAK_FOLDER_FOUND && ! $RHYTHMBOX_VAR_LIB_FLATPAK_FOLDER_FOUND || ! $RHYTHMBOX_VIA_FLATPAK_ALREADY_INSTALLED; then
			echo -e "Ajout du dépôt Flathub de Rhythmbox :\n"

			flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo		
		
			case $SYSTEM_OR_USER in
				"system")
					echo -e "Installation de rhythmbox via Flatpak en mode 'system' via la commande 'flatpak install -y --system flathub org.gnome.Rhythmbox3' !\n"

					flatpak install -y --system flathub org.gnome.Rhythmbox3
					
					echo -e ""
				;;
				
				"user")
					echo -e "Installation de rhythmbox via Flatpak en mode 'user' via la commande 'flatpak install -y --user flathub org.gnome.Rhythmbox3' !\n"

					flatpak install -y --user flathub org.gnome.Rhythmbox3
					
					echo -e ""
					
					# A APPROFONDIR
					# Autoriser l'accès à tous les périphériques
					# flatpak override --user --device=all org.gnome.Rhythmbox3
					
					# Accorder l'accès à un dossier spécifique (ex. musique externe)
					# flatpak override --user --filesystem=/chemin/vers/dossier org.gnome.Rhythmbox3
					
					# Réinitialiser toutes les overrides
					# flatpak override --user --reset org.gnome.Rhythmbox3
				;;
			esac
		fi

		echo -e "Fin de la procédure d'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"
		
		echo -e "❗ Rappel : l'application Flatpak de $TXT_APP_TO_INSTALL nouvellement installée apparaîtra après le redémarrage du système !\n"

	;;
	# FLATPAK - Fin setup type Flatpak

	$TXT_SETUP_TYPE_APT)
		echo -e "Début de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
		
		echo -e "Pas codé !\n"
	
		echo -e "Fin de l'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
	;;

	*)
		echo -e "Aucune installation n'a été effectuée !\n"
	;;
esac

echo -e "--------------- Fichier Rhythmdb.xml avec radios FR --------------------\n"

echo -e "Début de l'ajout des radios FR à l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"
		
RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER="$HOME_USER_FOLDER/.var/app/org.gnome.Rhythmbox3/data/rhythmbox"
RHYTHMBOX_HOME_USER_VAR_FOLDER="$HOME_USER_FOLDER/.var"
RHYTHMBOX_HOME_USER_VAR_APP_FOLDER="$HOME_USER_FOLDER/.var/app"
RHYTHMBOX_HOME_USER_VAR_APP_GNOME_FOLDER="$HOME_USER_FOLDER/.var/app/org.gnome.Rhythmbox3"
RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER="$HOME_USER_FOLDER/.var/app/org.gnome.Rhythmbox3/data"
RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER="$HOME_USER_FOLDER/.var/app/org.gnome.Rhythmbox3/data/rhythmbox"

# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux 
RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME="rhythmdb.xml"
RHYTHMBOX_SCRIPT_LOCAL_FILE_TO_COPY="rhythmdb.xml"
RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$RHYTHMBOX_SCRIPT_LOCAL_FILE_TO_COPY
RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME_FULLPATH=$RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER/$RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME
			
# Contrôle de la présence du dossier utilisateur flatpak caché de Rhythmbox (n'existe pas avant le 1er lancement, soit après redémarrage)
if [ -d "$RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER" ]; then
	echo -e "✅ Le dossier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER existe !\n"
else
	echo -e "❌ Le dossier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER n'existe pas !\n"
			
	echo -e "Création du dossier utilisateur caché $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER :\n"
				
	echo -e "Création du dossier $RHYTHMBOX_HOME_USER_VAR_FOLDER :\n"
				
	sudo mkdir $RHYTHMBOX_HOME_USER_VAR_FOLDER
	
	sudo chown $REAL_USER:$REAL_USER $RHYTHMBOX_HOME_USER_VAR_FOLDER
				
	sudo chmod $RHYTHMBOX_CHMOD_FILES_AND_FOLDERS $RHYTHMBOX_HOME_USER_VAR_FOLDER
				
	echo -e "Création du dossier $RHYTHMBOX_HOME_USER_VAR_APP_FOLDER :\n"
				
	sudo mkdir $RHYTHMBOX_HOME_USER_VAR_APP_FOLDER
	
	sudo chown $REAL_USER:$REAL_USER $RHYTHMBOX_HOME_USER_VAR_APP_FOLDER
	
	sudo chmod $RHYTHMBOX_CHMOD_FILES_AND_FOLDERS $RHYTHMBOX_HOME_USER_VAR_APP_FOLDER
			
	echo -e "Création du dossier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_FOLDER :\n"
			
	sudo mkdir $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_FOLDER
	
	sudo chown $REAL_USER:$REAL_USER $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_FOLDER
				
	sudo chmod $RHYTHMBOX_CHMOD_FILES_AND_FOLDERS $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_FOLDER
				
	echo -e "Création du dossier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER :\n"
				
	sudo mkdir $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER
	
	sudo chown $REAL_USER:$REAL_USER $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER
				
	sudo chmod $RHYTHMBOX_CHMOD_FILES_AND_FOLDERS $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER
				
	echo -e "Création du dossier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER :\n"
				
	sudo mkdir $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER
	
	sudo chown $REAL_USER:$REAL_USER $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER
				
	sudo chmod $RHYTHMBOX_CHMOD_FILES_AND_FOLDERS $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER
				
	# sudo mkdir $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_FOLDER
fi
			
# Recherche du fichier de radio FR à côté du script
if [ -f $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH ] ; then
	echo -e "✅ Le fichier de radio FR est présent à côté du script dans le même dossier, plus exactement le sous dossier 'Bash_Ubuntu_25_10_configuration-Additional_files' !\n"
	
	RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH_ACTUAL_OWNER=$(ls -ld $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH | awk '{print $3}')
	
	if [[ $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire actuel '$RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH_ACTUAL_OWNER' du fichier $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH est correct !\n"
	else
		echo -e "❌ Le propriétaire actuel '$RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH_ACTUAL_OWNER' du fichier $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH n'est pas correct !\n"
		
		echo -e "Modification du propriétaire du fichier à copier à l'utilisateur actuel $REAL_USER :\n"
					
		# Modification du propriétaire du dossier à l'utilisateur courant avant la copie
		sudo chown $REAL_USER:$REAL_USER $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH			
	fi
				
	# Affichage du nouveau propriétaire du fichier
	ls -l $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH
				
	echo -e ""
				
	echo -e "Remplacement du fichier '$RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME' du dossier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER :\n"
				
	cp -v $RHTYHMBOX_RHYTHMDB_XML_LOCAL_FILE_TO_COPY_FULLPATH $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER
				
	echo -e ""
	
	echo -e "Fin du remplacement du fichier '$RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME' du dossier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMBOX_FOLDER :\n"
				
	echo -e "Vérification de la présence du fichier $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME_FULLPATH :\n"

	echo -e "Modification du propriétaire du fichier copié à l'utilisateur actuel '$REAL_USER' :\n"
				
	# Modification du propriétaire du fichier copié à l'utilisateur courant
	sudo chown $REAL_USER:$REAL_USER $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME_FULLPATH	

	# Modification du chmod du fichier copié à l'utilisateur courant
	sudo chmod $RHYTHMBOX_CHMOD_RHYTHMDB_XML_FILE $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME_FULLPATH	

	ls -l $RHYTHMBOX_HOME_USER_VAR_APP_GNOME_DATA_RHYTHMDB_FILENAME_FULLPATH
			
	echo -e ""
							
	echo -e "Quelques radios FR ont été ajoutées par défaut dans l'application Rhythmbox !\n"
	
	# sudo chown $REAL_USER -R $HOME_USER_FOLDER/.var
else
	echo -e "❌ Le fichier de radio FR n'est pas présent à côté dans le même dossier du script !\n"
fi
			
echo -e "Fin de l'ajout des radios FR à l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_FLATPAK !\n"






echo -e "Informations supplémentaires sur Rhythmbox :\n"
echo -e "Pour le désinstaller, utiliser la commande :										flatpak uninstall org.gnome.Rhythmbox3"
echo -e "Si cette commande est utilisée en mode 'user', la désinstallation se fait uniquement sur l'utilisateur courant !"
echo -e "Pour supprimer aussi les données de configuration, utiliser la commande 						flatpak uninstall --delete-data org.gnome.Rhythmbox3"
echo -e "Pour supprimer aussi les données de configuration (automatisée), utiliser la commande 					flatpak uninstall -y --delete-data org.gnome.Rhythmbox3"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## RHYTHMBOX ####################################
fi # if $INSTALL_RHYTHMBOX; then

if $INSTALL_QEMU_KVM || $INSTALL_ALL; then
############################## QEMU-KVM ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Qemu-KVM"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du nom d'utilisateur actuel (pas root)
REAL_USER="${SUDO_USER:-$USER}"

# Chemin des fichiers et/ou dossiers pour contrôler leur présence
QEMU_KVM_BIN_FILENAME="/usr/bin/kvm"
QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME="/usr/share/applications/virt-manager.desktop"		# Le vrai raccourci
QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME="/usr/share/applications/qemu.desktop"
QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER="/usr/share/osinfo/platform/linux-kvm.org"
QEMU_KVM_SYS_MODULE_FOLDER="/sys/module/kvm"
QEMU_KVM_VAR_LIB_LIBVERT_FOLDER="/var/lib/libvirt"
# Booléens associés
QEMU_KVM_BIN_FILENAME_FOUND=false
QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME_FOUND=false
QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME_FOUND=false
QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER_FOUND=false
QEMU_KVM_SYS_MODULE_FOLDER_FOUND=false
QEMU_KVM_VAR_LIB_LIBVERT_FOLDER_FOUND=false
# Tailles
TAILLE_QEMU_KVM_BIN_FILENAME=""
# Nombre de lignes dans le fichier
NB_LINES_QEMU_KVM_BIN_FILENAME=0


# Contrôle de fichier
if Recherche_fichier $QEMU_KVM_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $QEMU_KVM_BIN_FILENAME existe !\n"; fi
	QEMU_KVM_BIN_FILENAME_FOUND=true
	TAILLE_QEMU_KVM_BIN_FILENAME=$(du -sh "$QEMU_KVM_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $QEMU_KVM_BIN_FILENAME n'existe pas !\n"; fi
	QEMU_KVM_BIN_FILENAME_FOUND=false
fi

# Contrôle de fichier
if Recherche_fichier $QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME existe !\n"; fi
	QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME_FOUND=true
	TAILLE_QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME=$(du -sh "$QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME" | cut -f1)
	NB_LINES_QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME=$(sed -n '$=' $QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $QEMU_KVM_BIN_FILENAME n'existe pas !\n"; fi
	QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME_FOUND=false
fi

# Contrôle de fichier
if Recherche_fichier $QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME existe !\n"; fi
	QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME_FOUND=true
	TAILLE_QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME=$(du -sh "$QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME" | cut -f1)
	NB_LINES_QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME=$(sed -n '$=' $QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $QEMU_KVM_BIN_FILENAME n'existe pas !\n"; fi
	QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER existe !\n"; fi
	QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER_FOUND=true
	TAILLE_QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER=$(du -sh "$QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER n'existe pas !\n"; fi
	QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $QEMU_KVM_SYS_MODULE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $QEMU_KVM_SYS_MODULE_FOLDER existe !\n"; fi
	QEMU_KVM_SYS_MODULE_FOLDER_FOUND=true
	TAILLE_QEMU_KVM_SYS_MODULE_FOLDER=$(du -sh "$QEMU_KVM_SYS_MODULE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $QEMU_KVM_SYS_MODULE_FOLDER n'existe pas !\n"; fi
	QEMU_KVM_SYS_MODULE_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $QEMU_KVM_VAR_LIB_LIBVERT_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $QEMU_KVM_VAR_LIB_LIBVERT_FOLDER existe !\n"; fi
	QEMU_KVM_VAR_LIB_LIBVERT_FOLDER_FOUND=true
	TAILLE_QEMU_KVM_VAR_LIB_LIBVERT_FOLDER=$(du -sh "$QEMU_KVM_VAR_LIB_LIBVERT_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $QEMU_KVM_VAR_LIB_LIBVERT_FOLDER n'existe pas !\n"; fi
	QEMU_KVM_VAR_LIB_LIBVERT_FOLDER_FOUND=false
fi

declare -A tableau

typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$QEMU_KVM_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_QEMU_KVM_BIN_FILENAME
tableau[$tab_ind,chemin]=$QEMU_KVM_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME
tableau[$tab_ind,chemin]=$QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME
tableau[$tab_ind,commentaires]="Fichier launcher dock ($NB_LINES_QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME lignes)"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME
tableau[$tab_ind,chemin]=$QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME
tableau[$tab_ind,commentaires]="Fichier launcher dock ($NB_LINES_QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME lignes)"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER
tableau[$tab_ind,chemin]=$QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$QEMU_KVM_SYS_MODULE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_QEMU_KVM_SYS_MODULE_FOLDER
tableau[$tab_ind,chemin]=$QEMU_KVM_SYS_MODULE_FOLDER
tableau[$tab_ind,commentaires]="Deja present dans l installation complete d Ubuntu25 10"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]="  X"
tableau[$tab_ind,existe]=$QEMU_KVM_VAR_LIB_LIBVERT_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_QEMU_KVM_VAR_LIB_LIBVERT_FOLDER
tableau[$tab_ind,chemin]=$QEMU_KVM_VAR_LIB_LIBVERT_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi


# echo -e "${$(TABLEAU_COMMENTAIRES_SIZE+1)}"
# echo -e "$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)"

# TABLEAU_COMMENTAIRES_SIZE_MOINS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE - 1)

#echo -e "$TABLEAU_COMMENTAIRES_SIZE_MOINS_1"

# TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

#echo -e "$TABLEAU_COMMENTAIRES_SIZE_PLUS_1"

# TABLEAU_COMMENTAIRES_SIZE_PLUS_2=$(expr $TABLEAU_COMMENTAIRES_SIZE + 2)

#echo -e "$TABLEAU_COMMENTAIRES_SIZE_PLUS_2"

#echo -e "$TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE"

# TABLEAU_BORDER_FIRST_LINE_PREFIX="+%-17s+%-78s+%-${TABLEAU_COMMENTAIRES_SIZE}s+\n" 

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""	

case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		echo -e "Début de la procédure d'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"	
	
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés (sauf sys/module qui est présent de base dans ubuntu25.10)
		if $QEMU_KVM_BIN_FILENAME_FOUND && $QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME_FOUND && $QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME_FOUND && $QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER_FOUND && $QEMU_KVM_SYS_MODULE_FOLDER_FOUND ; then
			echo -e "✅ L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
			
			# Vérification du statut de libvirt
			echo -e "Vérification du statut de libvirt (5 dernières lignes uniquement) via la commande 'sudo systemctl status libvirtd --lines=5' :\n"
			
			sudo systemctl status libvirtd --lines=5
			
			echo -e ""
			
			# Vérification du fonctionnement de l'hyperviseur
			echo -e "Vérification fonctionnement de l'hyperviseur via la commande 'sudo virsh -c qemu:///system version' :\n"
			
			sudo virsh -c qemu:///system version
			
			echo -e ""
			
			echo -e "Affichage des utilisateurs du groupe kvm :\n"

			getent group kvm

			echo -e ""			
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés (sauf sys/module qui est présent de base dans ubuntu25.10)
		if ! $QEMU_KVM_BIN_FILENAME_FOUND || ! $QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME_FOUND || ! $QEMU_KVM_VAR_LIB_LIBVERT_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
			
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			
			sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager virtinst libguestfs-tools
			
			echo -e "Récupération du vrai nom de l'utilisateur actuel. Lorsque le script est lancé avec sudo, la variable $USER est 'root' au lieu du vrai nom donc il faut utiliser la commande 'REAL_USER="${SUDO_USER:-$USER}"' :\n"
			
			# Ajout de l'utilisateur courant à la liste des utilisateur kvm pour gérer les VM sans sudo
			sudo usermod -aG kvm $REAL_USER
			
			# Ajout de l'utilisateur courant à la liste des utilisateur kvm pour gérer les VM sans sudo
			sudo usermod -aG libvirt $REAL_USER
			
			# Vérification ou rajout si nécessaire de l'utilisteur au groupe libvirt
			sudo adduser $REAL_USER libvirt
			
			echo -e "Rendre l'utilisateur actuel propriétaire du répertoire '/var/run/libvirt/libvirt-sock'"
			
			# Autoriser l'accès de l'utilisateur courant au répertoire libvirt-sock
			sudo chown $REAL_USER:$REAL_USER /var/run/libvirt/libvirt-sock
			
			echo -e ""
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés (sauf sys/module qui est présent de base dans ubuntu25.10)
		if ! $QEMU_KVM_BIN_FILENAME_FOUND && ! $QEMU_KVM_USR_SHARE_APPLICATIONS_VIRT_FILENAME_FOUND && ! $QEMU_KVM_USR_SHARE_APPLICATIONS_FILENAME_FOUND && ! $QEMU_KVM_VAR_LIB_LIBVERT_FOLDER && ! $QEMU_KVM_SHARE_OSINFO_PLATFORM_FOLDER_FOUND; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			
			sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager virtinst libguestfs-tools
			
			# Ajout de l'utilisateur courant à la liste des utilisateur kvm pour gérer les VM sans sudo
			sudo usermod -aG kvm $REAL_USER
			
			# Ajout de l'utilisateur courant à la liste des utilisateur kvm pour gérer les VM sans sudo
			sudo usermod -aG libvirt $REAL_USER
			
			# Vérification ou rajout si nécessaire de l'utilisteur au groupe libvirt
			sudo adduser $REAL_USER libvirt
			
			# Autoriser l'accès de l'utilisateur courant au répertoire libvirt-sock
			sudo chown $USER:$USER /var/run/libvirt/libvirt-sock
			
			echo -e ""
		fi
		
		echo -e "Fin de la procédure d'installation de l'application $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
	;;
	# APT - Fin setup type
	
	*)
	
	;;
esac

echo -e "Commandes utiles pour créer des fichiers au format qcow2 pour Qemu-KVM :					Commandes exemples avec l'image LibreElec :\n"
echo -e "Pour extraire le fichier vmdk à partir d'un fichier ova, utiliser la commande suivante : 			tar -xvf LibreELEC-Generic.x86_64-12.2.1.ova"
echo -e "Pour convertir le fichier vmdk en fichier qcow2 utilisable par Qemu-KVM						qemu-img convert -f vmdk -O qcow2 LibreELEC-Generic.x86_64-12.2.1.vmdk LibreELEC-Generic.x86_64-12.2.1.qcow2"
echo -e "Pour convertir un fichier img en fichier qcow2 utilisable par Qemu-KVM						sudo chown root:root LibreELEC-Generic-legacy.x86_64-12.2.1.qcow2"
echo -e "Pour redimensionner une image disque										qemu-resize LibreELEC-Generic-legacy.x86_64-12.2.1.img +5G"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## QEMU-KVM ####################################
fi # if $INSTALL_QEMU_KVM; then


if $INSTALL_OLLAMA || $INSTALL_ALL; then
############################## MODELE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Ollama"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_CURL

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Récupération du répertoire utilisateur
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME="/etc/systemd/system/ollama.service"
OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER="/usr/local/lib/ollama"
OLLAMA_USR_SHARE_OLLAMA_FOLDER="/usr/share/ollama"
OLLAMA_HOME_USER_OLLAMA_FOLDER="$HOME_USER/.ollama"

#APPNAME_USR_BIN_FILENAME_FOUND=false

OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER_FOUND=false
OLLAMA_USR_SHARE_OLLAMA_FOLDER_FOUND=false
OLLAMA_HOME_USER_OLLAMA_FOLDER_FOUND=false
OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME_FOUND=false

# Nombre de lignes dans le fichier
NB_LINES_OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME=0

# Contrôle de fichier
if Recherche_fichier $OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME existe !\n"; fi
	OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME_FOUND=true
	TAILLE_OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME=$(du -sh "$OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME" | cut -f1)
	# NB_LINES_OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME= Nb_lines_in_file "$OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME"
	# NB_LINES_OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME= wc -l $OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME
	NB_LINES_OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME=$(sed -n '$=' $OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME n'existe pas !\n"; fi
	OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER existe !\n"; fi
	OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER_FOUND=true
	TAILLE_OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER=$(du -sh "$OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER n'existe pas !\n"; fi
	OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $OLLAMA_USR_SHARE_OLLAMA_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OLLAMA_USR_SHARE_OLLAMA_FOLDER existe !\n"; fi
	OLLAMA_USR_SHARE_OLLAMA_FOLDER_FOUND=true
	TAILLE_OLLAMA_USR_SHARE_OLLAMA_FOLDER=$(du -sh "$OLLAMA_USR_SHARE_OLLAMA_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OLLAMA_USR_SHARE_OLLAMA_FOLDER n'existe pas !\n"; fi
	OLLAMA_USR_SHARE_OLLAMA_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $OLLAMA_HOME_USER_OLLAMA_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $OLLAMA_HOME_USER_OLLAMA_FOLDER existe !\n"; fi
	OLLAMA_HOME_USER_OLLAMA_FOLDER_FOUND=true
	TAILLE_OLLAMA_HOME_USER_OLLAMA_FOLDER=$(du -sh "$OLLAMA_HOME_USER_OLLAMA_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $OLLAMA_HOME_USER_OLLAMA_FOLDER n'existe pas !\n"; fi
	OLLAMA_HOME_USER_OLLAMA_FOLDER_FOUND=false
fi

declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER
tableau[$tab_ind,chemin]=$OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER
tableau[$tab_ind,commentaires]="Dossier des librairies (Cuda 12&13, vulkan, les include .h, ...)"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OLLAMA_USR_SHARE_OLLAMA_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OLLAMA_USR_SHARE_OLLAMA_FOLDER
tableau[$tab_ind,chemin]=$OLLAMA_USR_SHARE_OLLAMA_FOLDER
tableau[$tab_ind,commentaires]="Dossier contenant le fichier .profile entre autre"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OLLAMA_HOME_USER_OLLAMA_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_OLLAMA_HOME_USER_OLLAMA_FOLDER
tableau[$tab_ind,chemin]=$OLLAMA_HOME_USER_OLLAMA_FOLDER
tableau[$tab_ind,commentaires]="Dossier utilisateur cache"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME
tableau[$tab_ind,chemin]=$OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME
tableau[$tab_ind,commentaires]="Fichier ($NB_LINES_OLLAMA_ETC_SYSTEMD_SYSTEM_OLLAMA_SERVICE_FILENAME lignes) contenant les variables user, group et environnement utilisees par Ollama"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""






case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_CURL)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER_FOUND && $OLLAMA_USR_SHARE_OLLAMA_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			ollama -v
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER_FOUND || ! $OLLAMA_USR_SHARE_OLLAMA_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $OLLAMA_USR_LOCAL_LIB_OLLAMA_FOLDER_FOUND && ! $OLLAMA_USR_SHARE_OLLAMA_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL via Curl"
			
			curl -fsSL https://ollama.com/install.sh | sh

		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
	
	;;

	$TXT_SETUP_TYPE_SNAP)
	
	;;

	*)
	
	;;
esac

echo -e "Informations supplémentaires sur Rhythmbox :\n"
echo -e "Pour le désinstaller, utiliser la liste des commandes suiavntes :"
echo -e "Arret du service Ollama									sudo systemctl stop ollama"
echo -e "Désactivation du service Ollama								sudo systemctl disable ollama"
echo -e "Suppression du service Ollama								sudo rm /etc/systemd/system/ollama.service"
echo -e "Suppression des librairies liés à Ollama						sudo rm -r \$(which ollama | tr 'bin' 'lib')"
echo -e "Suppression des binaires Ollama								sudo rm \$(which ollama)"
echo -e "Suppression de l'utilisateur Ollama							sudo userdel ollama"
echo -e "Suppression du groupe Ollama								sudo groupdel ollama"
echo -e "Suppression du dossier Ollama								sudo rm -r /usr/share/ollama"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## OLLAMA (FIN) #################################### 
fi # if $INSTALL_OLLAMA || $INSTALL_ALL; then


if $INSTALL_RASPBERRY_PI_IMAGER || $INSTALL_ALL; then
############################## MODELE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Raspberry Pi Imager"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_SNAP

# Options d'analyse
SHOW_ANALYSE_LINES=true

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME="/snap/bin/rpi-imager"
RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER="/snap/rpi-imager"
# Booléens associés
RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME_FOUND=false
RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER_FOUND=false
# Tailles (nécessaire si fichier et/ou dossier absent)
TAILLE_RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME=""
TAILLE_RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER=""


# Contrôle de fichier
if Recherche_fichier $RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME existe !\n"; fi
	RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME_FOUND=true
	TAILLE_RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME=$(du -sh "$RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME n'existe pas !\n"; fi
	RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER existe !\n"; fi
	RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER_FOUND=true
	TAILLE_RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER=$(du -sh "$RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER n'existe pas !\n"; fi
	RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER_FOUND=false
fi


declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME
tableau[$tab_ind,chemin]=$RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME
tableau[$tab_ind,commentaires]="Binaire"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]=""
tableau[$tab_ind,snap]="  X"
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER
tableau[$tab_ind,chemin]=$RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""






case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)

	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
	
	;;

	$TXT_SETUP_TYPE_SNAP)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME && $RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME || ! $RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $RPI_IMAGER_SNAP_BIN_RPI_IMAGER_FILENAME && ! $RPI_IMAGER_SNAP_RPI_IMAGER_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi			
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## MODELE (FIN) #################################### 
fi # if $INSTALL_RASPBERRY_PI_IMAGER || $INSTALL_ALL; then




if $INSTALL_TUXGUITAR || $INSTALL_ALL; then
############################## MODELE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Template_appname"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Aller au répertoire utilisateur
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
TUXGUITAR_USR_BIN_FILENAME="/usr/bin/tuxguitar"
TUXGUITAR_USR_SHARE_FOLDER="/usr/share/tuxguitar"
TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER="/tmp/tuxguitar-kvm-user"
TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER="$HOME_USER/.config/tuxguitar"


# Booléens associés
TUXGUITAR_USR_BIN_FILENAME_FOUND=false
TUXGUITAR_USR_SHARE_FOLDER_FOUND=false
TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND=false
TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER_FOUND=false
# Tailles (nécessaire si fichier et/ou dossier absent)
TAILLE_TUXGUITAR_USR_BIN_FILENAME=""
TAILLE_TUXGUITAR_USR_SHARE_FOLDER=""
TAILLE_TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER=""
TAILLE_TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER=""


# Contrôle de fichier
if Recherche_fichier $TUXGUITAR_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $TUXGUITAR_USR_BIN_FILENAME existe !\n"; fi
	TUXGUITAR_USR_BIN_FILENAME_FOUND=true
	TAILLE_TUXGUITAR_USR_BIN_FILENAME=$(du -sh "$TUXGUITAR_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $TUXGUITAR_USR_BIN_FILENAME n'existe pas !\n"; fi
	TUXGUITAR_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $TUXGUITAR_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $TUXGUITAR_USR_SHARE_FOLDER existe !\n"; fi
	TUXGUITAR_USR_SHARE_FOLDER_FOUND=true
	TAILLE_TUXGUITAR_USR_SHARE_FOLDER=$(du -sh "$TUXGUITAR_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $TUXGUITAR_USR_SHARE_FOLDER n'existe pas !\n"; fi
	TUXGUITAR_USR_SHARE_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER existe !\n"; fi
	TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND=true
	TAILLE_TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER=$(du -sh "$TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER n'existe pas !\n"; fi
	TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER existe !\n"; fi
	TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND=true
	TAILLE_TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER=$(du -sh "$TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER n'existe pas !\n"; fi
	TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER existe !\n"; fi
	TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER_FOUND=true
	TAILLE_TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER=$(du -sh "$TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER n'existe pas !\n"; fi
	TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER_FOUND=false
fi



declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$TUXGUITAR_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_TUXGUITAR_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$TUXGUITAR_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]="Binaire"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$TUXGUITAR_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_TUXGUITAR_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$TUXGUITAR_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]="Dossier classique usr share"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER
tableau[$tab_ind,chemin]=$TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER
tableau[$tab_ind,commentaires]="Dossier temp"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER
tableau[$tab_ind,chemin]=$TUXGUITAR_HOME_USER_CONFIG_TUXGUITAR_FOLDER
tableau[$tab_ind,commentaires]="Dossier config utilisateur"

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""






case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $APPNAME_USR_BIN_FILENAME_FOUND && $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version installée :\n"

			tuxguitar --version

			echo -e "Liste des paquets dpkg liés à TuxGuitar avec la commande 'dpkg -l | grep tuxguitar' : \n"

			dpkg -l | grep tuxguitar
			
			echo -e ""
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND || ! $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND && ! $TUXGUITAR_TMP_TUXGUITAR_USER_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			sudo apt -y install tuxguitar
			
			echo -e "Installation des plugins de sons améliorés :\n"
			sudo apt -y install tuxguitar-fluidsynth fluid-soundfont-gm
		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
	
	;;

	$TXT_SETUP_TYPE_SNAP)
	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## MODELE (FIN) #################################### 
fi # if $INSTALL_TUXGUITAR || $INSTALL_ALL; then

















if $INSTALL_COMFYUI || $INSTALL_ALL; then
############################## COMFYUI ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Comfyui"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Aller au répertoire utilisateur
HOME_USER=$(eval echo "~${SUDO_USER:-$USER}")

# Cgemins utilisateur
# Chemin du dossier apt pour contrôler sa présence"
COMFYUI_HOME_USER_COMFY_FOLDER="$HOME_USER/comfy"
COMFYUI_HOME_USER_COMFY_ENV_FOLDER="$HOME_USER/comfy-env"
COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME="$HOME_USER/comfy/ComfyUI/main.py"

# Chemins des fichiers .workflows utilisateur
COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER="$HOME_USER/comfy/ComfyUI/user/default/workflows"

# Chemins des dossiers models
COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER="$HOME_USER/comfy/ComfyUI/output"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER="$HOME_USER/comfy/ComfyUI/models"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER="$HOME_USER/comfy/ComfyUI/models/audio_encoders"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER="$HOME_USER/comfy/ComfyUI/models/checkpoints"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER="$HOME_USER/comfy/ComfyUI/models/diffusion_models"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER="$HOME_USER/comfy/ComfyUI/models/loras"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER="$HOME_USER/comfy/ComfyUI/models/text_encoders"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER="$HOME_USER/comfy/ComfyUI/models/unet"
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER="$HOME_USER/comfy/ComfyUI/models/upscale_models"


# Booléens associés
COMFYUI_HOME_USER_COMFY_FOLDER_FOUND=false
COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME_FOUND=false
COMFYUI_HOME_USER_COMFY_ENV_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER_FOUND=false
# Booléens des fichiers workflows
COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER_FOUND=false
# Booléens utilisateur
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER_FOUND=false
COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER_FOUND=false





if Recherche_fichier $COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME existe !\n"; fi
	COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME_FOUND=true
	TAILLE_COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME=$(du -sh "$COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME n'existe pas !\n"; fi
	COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_ENV_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_ENV_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_ENV_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_ENV_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_ENV_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_ENV_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_ENV_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_FOLDER_FOUND=false
fi

# Dossier contenant les fichiers workflows utilisateur
if Recherche_dossier $COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER_FOUND=false
fi


# Dossiers contenant les models
if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER_FOUND=false
fi

if Recherche_dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER existe !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER_FOUND=true
	TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER=$(du -sh "$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER n'existe pas !\n"; fi
	COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER_FOUND=false
fi

TXT_SUBFOLDER=" >"

declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME
tableau[$tab_ind,chemin]=$COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME
tableau[$tab_ind,commentaires]="Fichier de lancement de l'application python ComfyUI"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_ENV_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_ENV_FOLDER
tableau[$tab_ind,chemin]=$COMFYUI_HOME_USER_COMFY_ENV_FOLDER
tableau[$tab_ind,commentaires]="Dossier d'environnement venv par defaut de ComfyUI"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_FOLDER
tableau[$tab_ind,chemin]=$COMFYUI_HOME_USER_COMFY_FOLDER
tableau[$tab_ind,commentaires]="Dossier principal par defaut de ComfyUI"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER
tableau[$tab_ind,chemin]=$COMFYUI_HOME_USER_COMFY_USER_DEFAULT_WORKFLOWS_FOLDER
tableau[$tab_ind,commentaires]="Dossier contenant les workflows enregistres par l'utilisateur"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_OUTPUT_FOLDER"
tableau[$tab_ind,commentaires]="Dossier contenant les images et videos generees"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_FOLDER"
tableau[$tab_ind,commentaires]="Dossier contenant les models"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_AUDIO_ENCODERS_FOLDER"
tableau[$tab_ind,commentaires]="$TXT_SUBFOLDER Dossier contenant les models audio encoders"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_CHECKPOINTS_FOLDER"
tableau[$tab_ind,commentaires]="$TXT_SUBFOLDER Dossier contenant les models checkpoints"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_DIFFUSION_MODELS_FOLDER"
tableau[$tab_ind,commentaires]="$TXT_SUBFOLDER Dossier contenant les models diffusion_models"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_LORAS_FOLDER"
tableau[$tab_ind,commentaires]="$TXT_SUBFOLDER Dossier contenant les models loras"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_TEXT_ENCODERS_FOLDER"
tableau[$tab_ind,commentaires]="$TXT_SUBFOLDER Dossier contenant les models text_encoders"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UNET_FOLDER"
tableau[$tab_ind,commentaires]="$TXT_SUBFOLDER Dossier contenant les models unet"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER
tableau[$tab_ind,chemin]="$TXT_SUBFOLDER$TXT_SUBFOLDER $COMFYUI_HOME_USER_COMFY_COMFYUI_MODELS_UPSCALE_MODELS_FOLDER"
tableau[$tab_ind,commentaires]="$TXT_SUBFOLDER Dossier contenant les models upscale_models"



if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"


for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
		
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""








case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME_FOUND && $COMFYUI_HOME_USER_COMFY_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			echo -e "Informations sur la version du package FrontEnd de Comfyui via la commande '/home/$USER/comfy-env/bin/pip show comfyui-frontend-package' :\n"
			
			/home/$REAL_USER/comfy-env/bin/pip show comfyui-frontend-package
			
			echo -e ""

			echo -e "Informations sur les versions de paquets ComfyUI via la commande '/home/$REAL_USER/comfy-env/bin/pip list | grep comfyui' :\n"
			
			/home/$REAL_USER/comfy-env/bin/pip list | grep comfyui
			
			echo -e ""
			
			echo -e "Informations sur la version de comfy-cli en activant l'envrionnement, récup version, puis désactivation de l'envrionnement :\n"
			
			source $HOME_USER/comfy-env/bin/activate
			
			comfy-cli --version
			
			deactivate
			
			echo -e ""			
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME_FOUND || ! $COMFYUI_HOME_USER_COMFY_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $COMFYUI_HOME_USER_MAIN_PYTHON_FILENAME_FOUND && ! $COMFYUI_HOME_USER_COMFY_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
			echo -e "Lancer un terminal à la racine du dossier utilisateur, puis taper la commande comfy which"
		fi	
	;;
	
	*)
	
	;;
esac


echo -e "Informations supplémentaires sur ComfyUI :\n"
echo -e "Pour lancer l'environnement Comfy, utiliser la commande :										source comfy-env/bin/activate"
echo -e "Puis dans l'environnement Comfy, lancer l'interface navigateur de Comfy avec la commande :						comfy launch"
echo -e "Pour mettre à jour l'installation existante												pip install --upgrade comfy-cli"



echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## COMFYUI (FIN) #################################### 
fi # if $INSTALL_COMFYUI || $INSTALL_ALL; then












############################### FICHIERS RACCOURCIS .DESKTOP ###############################

if $INSTALL_FREEBOX_TV || $INSTALL_ALL; then
############################## RACCOURCI FREEBOX TV ####################################
#################

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du raccourci Freebox_tv.desktop pour avoir la TV via VLC"
echo -e $TEXT_RESET

# Chemin du dossier pour contrôler sa présence
FREEBOX_TV_FILENAME="freebox_tv.desktop"
FREEBOX_TV_VLC_PLAYLIST_FILENAME="Playlist_Freebox_TV_m3u.xspf"
FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME="tv-logo-free-vector-349x351-no_border.png"

# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux 
FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME
FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_TV_FILE_TO_COPY_FULLPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$FREEBOX_TV_VLC_PLAYLIST_FILENAME

# Aller au répertoire utilisateur
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin du dossier apt pour contrôler sa présence"
FREEBOX_LOCAL_SHARE_FOLDER="$USER_HOME/.local/share/applications"
FREEBOX_TV_VLC_PLAYLIST_FOLDER="$USER_HOME/.local/share/vlc"
FREEBOX_TV_VIA_VLC_ICON_FOLDER="$USER_HOME/.local/share/icons"
FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH=$FREEBOX_LOCAL_SHARE_FOLDER/$FREEBOX_TV_FILENAME
FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH=$FREEBOX_TV_VLC_PLAYLIST_FOLDER/$FREEBOX_TV_VLC_PLAYLIST_FILENAME

# Chmod des fichiers et/ou dossiers à créer si nécessaire
FREEBOX_TV_CHMOD_FOLDERS_AND_FILES="644"

echo -e "------------ Recherche et vérification de la présence des fichiers et/ou dossiers ------------\n"

### CONTROLE DES FICHIERS (DEBUT) ###
if [ -d "$FREEBOX_TV_VIA_VLC_ICON_FOLDER" ]; then
	echo -e "✅ Le dossier $FREEBOX_TV_VIA_VLC_ICON_FOLDER existe !\n"
else
	echo -e "❌ Le dossier $FREEBOX_TV_VIA_VLC_ICON_FOLDER n'existe pas !\n"
	
	echo -e "Création du dossier $FREEBOX_TV_VIA_VLC_ICON_FOLDER :\n"
	
	sudo mkdir $FREEBOX_TV_VIA_VLC_ICON_FOLDER
	      
        REAL_USER="${SUDO_USER:-$USER}"
        
        echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) avant de copier le fichier"
        
	# Modification du propriétaire du dossier à l'utilisateur courant
	sudo chown -R $REAL_USER:$REAL_USER $FREEBOX_TV_VIA_VLC_ICON_FOLDER       
        
        echo -e "Elévations des permissions sur le dossier $FREEBOX_TV_VIA_VLC_ICON_FOLDER qui vient d'être créé :\n"
	        
        sudo chmod -v $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES $FREEBOX_TV_VIA_VLC_ICON_FOLDER        
        
        echo -e "Affichage des fichiers contenu dans le dossier $FREEBOX_TV_VIA_VLC_ICON_FOLDER :\n"
        
        ls -l $FREEBOX_TV_VIA_VLC_ICON_FOLDER
        
	# CHMOD
	FREEBOX_TV_VIA_VLC_ICON_FOLDER_ACTUAL_CHMOD=$(ls -l $FREEBOX_TV_VIA_VLC_ICON_FOLDER | cut -d' ' -f1)
		
	case $FREEBOX_TV_VIA_VLC_ICON_FOLDER_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
		"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
		"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
		"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
		"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
		"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
		"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
		"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
		*) echo -e "Chmod inconnu !\n" ;;
	esac
fi

echo -e "-------------------------------------- Icône Freebox TV personnalisée --------------------------------------\n"

# Icone VLC TV
echo -e "Recherche de l'image icône TV pour Ubuntu '$FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME' :\n"

if [ -f "$FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME" ]; then

        echo -e "✅ Le fichier $FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME existe !\n"

else

        echo -e "❌ Le fichier $FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME n'existe pas !\n"

        # Vérification de la présence du fichier playlist à côté de ce script
        if [ -f "$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH" ]; then
                echo -e "✅ Le fichier original '$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' est présent à côté de ce script avant d'être copié !\n"

		REAL_USER="${SUDO_USER:-$USER}"

        	echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier avant de le copier :\n"
        	
        	sudo chown $REAL_USER:$REAL_USER $FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH
        	
        	ls -l $FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH
        	
        	echo -e ""

                echo -e "Copie du fichier icône $FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH en cours :\n"

                sudo cp -v "$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH" $FREEBOX_TV_VIA_VLC_ICON_FOLDER
                
                echo -e ""
                
                echo -e "Attributions des permissions à l'utilisateur courant sur le fichier $FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME :\n"
                
                sudo chmod $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES $FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME
		
		echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier avant de le copier :\n"
		
		# Modification du propriétaire du fichier à l'utilisateur courant
		sudo chown $REAL_USER:$REAL_USER $FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME               
                
		echo -e "Vérification de la présence du fichier $FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME :\n"
				
		ls -l "$FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME"
		
		echo -e ""
		
		# CHMOD
		FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_ACTUAL_CHMOD=$(ls -l $FREEBOX_TV_VIA_VLC_ICON_FOLDER/$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME | cut -d' ' -f1)
		
		case $FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
			"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
			"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
			"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
			"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
			"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
			"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
			"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
			*) echo -e "Chmod inconnu !\n" ;;
		esac

        else
                echo -e "❌ Le fichier original '$FREEBOX_TV_VIA_VLC_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' n'est pas présent à côté de ce script avant d'être copié !\n"

        fi

fi

echo -e "-------------------------------------- Fichier Playlist TV --------------------------------------\n"

# Fichier Playlist
if [ -d "$FREEBOX_TV_VLC_PLAYLIST_FOLDER" ]; then
	echo -e "✅ Le dossier $FREEBOX_TV_VLC_PLAYLIST_FOLDER existe !\n"
else
	echo -e "❌ Le dossier $FREEBOX_TV_VLC_PLAYLIST_FOLDER n'existe pas !\n"
	
	echo -e "Création du dossier $FREEBOX_TV_VLC_PLAYLIST_FOLDER :\n"
	
	sudo mkdir $FREEBOX_TV_VLC_PLAYLIST_FOLDER
	
	echo -e "Rendre l'utilisateur actuel '$REAL_USER' propriétaire du dossier créé $FREEBOX_TV_VLC_PLAYLIST_FOLDER :"
	
	sudo chown -R $REAL_USER:$REAL_USER $FREEBOX_TV_VLC_PLAYLIST_FOLDER
	
	echo -e "Attributions des permissions sur le dossier (644) :"
	
	sudo chmod 755 $FREEBOX_TV_VLC_PLAYLIST_FOLDER
fi

echo -e "Recherche du fichier 'FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH' playlist personnalisé contenant les chaines TV (HD uniquement) et leurs liens :\n"

if [ -f "$FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH" ]; then

	echo -e "✅ Le fichier $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH existe !\n"

	echo -e "Vérification du propriétaire actuel du fichier existant $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH :\n"
	
	FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_OWNER=$(ls -ld $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH | awk '{print $3}')
	
	# echo -e "Le propriétaire actuel du fichier $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH existant est $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_OWNER !\n"

	if [[ $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire '$FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_OWNER' du fichier $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH est correct !\n"
	else
		echo -e "❌ Le propriétaire '$FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_OWNER' du fichier $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH n'est pas correct !\n"
		
		echo -e "Correction du propriétaire '$REAL_USER' du dossier $FREEBOX_TV_VLC_PLAYLIST_FOLDER :\n"
		
		sudo chown $REAL_USER:$REAL_USER $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH
		
		$FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_OWNER=$(ls -ld $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH | awk '{print $3}')
	fi
	
	echo -e "Fin de la vérification du propriétaire actuel du fichier existant $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH !\n"

	# CHMOD
	echo -e "Vérification des permissions sur le fichier playlist :\n"

	FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_TXT_ACTUAL_CHMOD=$(ls -l $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH | cut -d' ' -f1)
	
	case $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
		"-rw-r--r--") 
			echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n"
			FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD="644"
		;;
		"-rw-rw-r--") 
			echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n"
			FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD="664"
		;;
		"-rw-rw-rw-") 
			echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n"
			FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD="666"	
		;;
		"-rwxr-xr-x") 
			echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" 
			FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD="755"
		;;
		"-rwrrw-rw-")
			echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n"
			FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD="766"
		;;
		"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
		"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
		*) echo -e "Chmod inconnu !\n" ;;
	esac
	
	if [[ $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD == $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES ]]; then
		echo -e "✅ Le chmod $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD du fichier $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH est correct !\n"
	else
		echo -e "❌ Le chmod $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD du fichier $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH n'est pas correct !\n"
		
		echo -e "Correction du chmod en cours :\n"
		
		sudo chmod $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH
	
		echo -e "Chmod corrigé !\n"
	fi
	
	echo -e "Fin de la vérification des permissions sur le fichier playlist !\n"

else

        echo -e "❌ Le fichier $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH n'existe pas !\n"

	# Vérification de la présence du fichier playlist à côté de ce script
	if [ -f "$FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_TV_FILE_TO_COPY_FULLPATH" ]; then
		echo -e "✅ Le fichier original 'Playlist_Freebox_TV_m3u.xspf' est présent à côté de ce script avant d'être copié !\n"

		REAL_USER="${SUDO_USER:-$USER}"

        	echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier avant de le copier :\n"
        	
        	sudo chown $REAL_USER:$REAL_USER $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_TV_FILE_TO_COPY_FULLPATH

	        echo -e "Copie du fichier playlist Freebox_TV.desktop en cours :\n"

	        sudo cp -v $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_TV_FILE_TO_COPY_FULLPATH $FREEBOX_TV_VLC_PLAYLIST_FOLDER
	        
	        echo -e ""
	        
	        echo -e "Elévations des permissions sur le fichier playlist qui vient d'être copié :\n"
	        
	        sudo chmod $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH
	        
        	# Modification du propriétaire du fichier à l'utilisateur courant
		sudo chown $REAL_USER:$REAL_USER $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH
	        
		ls -l $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH
				
		echo -e ""
		
		# CHMOD
		FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD=$(ls -l $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH | cut -d' ' -f1)
		
		case $FREEBOX_TV_HOME_USER_LOCAL_SHARE_VLC_PLAYLIST_COMPLETEPATH_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
			"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
			"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
			"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
			"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
			"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
			"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
			"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
			*) echo -e "Chmod inconnu !\n" ;;
		esac
		
		# Vérification des droits de permissions sur le dossier '.local/share/vlc' contenant la playlist
		# sudo chown $REAL_USER:$REAL_USER $FREEBOX_TV_VLC_PLAYLIST_FOLDER

	else
                echo -e "❌ Le fichier original 'Playlist_Freebox_TV_m3u.xspf' n'est pas présent à côté de ce script avant d'être copié !\n"

	fi

fi

echo -e "------------------------------ Vérification des accès au dossier $FREEBOX_TV_VIA_VLC_ICON_FOLDER --------------------------------\n"

echo -e "Attribution de propriétaire sur le dossier '$FREEBOX_TV_VLC_PLAYLIST_FOLDER' avec chown :\n"

sudo chown -R $REAL_USER:$REAL_USER $FREEBOX_TV_VLC_PLAYLIST_FOLDER

echo -e "Attribution d'un chmod de 755 sur le dossier '$FREEBOX_TV_VLC_PLAYLIST_FOLDER' :\n"

sudo chmod 755 $FREEBOX_TV_VLC_PLAYLIST_FOLDER

echo -e "-------------------------------------- Fichier Freebox_TV.desktop --------------------------------------\n"

echo -e "Recherche du fichier raccourci Ubuntu '$FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH' :\n"


if [ -f "$FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH" ]; then
	echo -e "✅ Le fichier raccourci $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH existe !\n"
	
	echo -e "Vérification du propriétaire actuel du fichier existant $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH :\n"

	# Modification du propriétaire du fichier à l'utilisateur courant
	sudo chown $REAL_USER:$REAL_USER $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH

	echo -e "Attributions des permissions (chmod de $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES) sur le fichier raccourci :\n"	

	sudo chmod $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH

	echo -e "Vérifications des permissions sur le fichier raccourci Ubuntu :\n"
	
       	ls -l $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH
       	
       	echo -e ""
       	
	# CHMOD
	FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=$(ls -l $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH | cut -d' ' -f1)
	
	case $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
		"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
		"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
		"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
		"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
		"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
		"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
		"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
		*) echo -e "Chmod inconnu !\n" ;;
	esac
else
        echo -e "❌ Le fichier raccourci $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH n'existe pas !\n"


	FREEBOX_TV_FILENAME_CREATE_OR_COPY="create"
			
	case $FREEBOX_TV_FILENAME_CREATE_OR_COPY in
		"create")
			echo -e "Début de la création du fichier freebox.desktop dans le dossier cible $FREEBOX_LOCAL_SHARE_FOLDER :\n"
				
			# Récupération de la variable chemin d'utilisateur
			HOME_USER_PATH=$(eval echo "~${SUDO_USER:-$USER}")
								
			# Ne pas identer le contenu des cat sinon les indentations apparaissent dans le fichier créé !
			cat << EOF > $HOME_USER_PATH/.local/share/applications/freebox_tv.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Freebox TV
Comment=Lancer la Freebox TV avec VLC
Exec=nice -n -10 vlc-wrapper --video-on-top --no-qt-video-autoresize --playlist-enqueue $HOME_USER_PATH/.local/share/vlc/Playlist_Freebox_TV_m3u.xspf --playlist-autostart --intf qt
Icon=$HOME_USER_PATH/.local/share/icons/tv-logo-free-vector-349x351-no_border.png
Terminal=false
Categories=Multimedia;

# Pour la commande Exec, quelques explications sur les paramètres
# -f : Ouvre VLC en plein écran
# --no-qt-video-autoresize : ne redimensionne pas aux dimensions de la vidéo source
# --nooverlay : désactive l'accélération matérielle
# --playlist-enqueue : Ouvre la liste de lecture précisée /xxx/xxx.xspf
# --playlist-autostart : Lance la liste de lecture automatiquement au lancement (par défaut est déja à true)
# --intf qt : Ouvre la liste de lecture pour avoir le choix (bien pour choisir une chaine tv dans une playlist tv)
#
# Ce fichier a été créé via le script Bash_Ubuntu_25_10_configuration_vX.X.X.sh écrit par Olivosaure !
EOF
				
			echo -e "Le fichier freebox.desktop a été créé dans le dossier cible $FREEBOX_LOCAL_SHARE_FOLDER !\n"
				
			# Attribution du chmod
			# chmod +x $FREEBOX_LOCAL_SHARE_FOLDER/$FREEBOX_TV_FILENAME
				
			# Modification du propriétaire du fichier à l'utilisateur courant
			sudo chown $REAL_USER:$REAL_USER $FREEBOX_LOCAL_SHARE_FOLDER/$FREEBOX_TV_FILENAME
				
			sudo chmod $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES $FREEBOX_LOCAL_SHARE_FOLDER/$FREEBOX_TV_FILENAME
				
			# echo -e "$FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH"
				
			echo -e "Fin de la création du fichier '$FREEBOX_TV_FILENAME' dans le dossier cible $FREEBOX_LOCAL_SHARE_FOLDER :\n"
		;;
				
		"copy")
			# Contrôle de la présence de fichiers et/ou dossiers existants
			if [ -f "$FREEBOX_TV_FILENAME" ]; then			
				echo -e "Le fichier $FREEBOX_TV_FILENAME est bien présent dans le même dossier que le fichier bash !\n"
						
				echo -e "Copie du fichier en cours :\n"

				sudo cp -v $FREEBOX_TV_FILENAME $FREEBOX_LOCAL_SHARE_FOLDER
						
				echo -e ""

				# Modification du propriétaire du fichier à l'utilisateur courant
				echo -e "Attribution de propriétaire sur le fichier $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH :\n"
				
				sudo chown $REAL_USER:$REAL_USER $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH
	
				echo -e "Attributions des permissions (chmod de $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES) sur le fichier playlist qui vient d'être copié :\n"
						
				sudo chmod $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH
						
				ls -l $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH
							
				echo -e ""
						
				# CHMOD
				FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_TXT_ACTUAL_CHMOD=$(ls -l $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH | cut -d' ' -f1)
						
				case $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
					"-rw-r--r--") 
						echo -e "-rw-r--r-- correspond à un chmod de 644 !\n"
						$FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_ACTUAL_CHMOD="644"
					;;
					"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
					"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
					"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
					"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
					"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
					"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
					*) echo -e "Chmod inconnu !\n" ;;
				esac

				echo -e "Le chmod du fichier $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH à copier est $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_ACTUAL_CHMOD !\n"

				if [[ $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_ACTUAL_CHMOD == $FREEBOX_TV_CHMOD_FOLDERS_AND_FILES ]] ; then
					echo -e "✅ Le chmod '$FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_ACTUAL_CHMOD' du fichier $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH à copier est correct !\n"
				else
					echo -e "❌ Le chmod '$FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH_ACTUAL_CHMOD' du fichier $FREEBOX_HOME_USER_LOCAL_SHARE_APPS_FREEBOX_TV_FILENAME_COMPLETEPATH à copier n'est pas correct !\n"
				fi
				# CHMOD du fichier à copier (FIN)
			else
				echo "Le fichier $FREEBOX_TV_FILENAME n'est pas présent dans le même dossier que le fichier bash .sh"
			fi
		;;
	esac
fi



### CONTROLE DES FICHIERS (FIN) ###

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du raccourci Freebox_tv.desktop pour avoir la TV via VLC"
echo -e $TEXT_RESET

#################
############################## RACCOURCI FREEBOX TV ####################################
fi # if $INSTALL_FREEBOX_TV || $INSTALL_ALL; then


if $INSTALL_VLC_WRAPPER_DESKTOP_SHORTCUT || $INSTALL_ALL; then
############################## RACCOURCI VLC WRAPPER ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="VLC Wrapper"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du raccourci Ubuntu pour lancer $TXT_APP_TO_INSTALL au lieu de VLC"
echo -e $TEXT_RESET

# Rajout du chemin relatif du dossier des fichiers additionnels de ce script de configuration
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="./Bash_Ubuntu_25_10_configuration-Additional_files"

# Noms des fichiers ou dossiers à rechercher
VLC_WRAPPER_DESKTOP_FILENAME="vlc-wrapper.desktop"
VLC_WRAPPER_ICON_PNG_FILENAME="VLC_perso-512x512.png"

VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME
VLC_WRAPPER_DESKTOP_FILENAME_TO_COPY_COMPLETEPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME

# Aller au répertoire utilisateur
HOME_USER_PATH=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin du dossier apt pour contrôler sa présence
VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER="$HOME_USER_PATH/.local/share/applications"
VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER="$HOME_USER_PATH/.local/share/icons"
VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH=$VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME
VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH=$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME

# Booléens associés
VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_FOUND=false

# Chmod des fichiers et/ou dossiers à créer si nécessaire
VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES="644"

echo -e "------------ Recherche et vérification de la présence des fichiers et/ou dossiers ------------\n"

# Contrôle de la présence du dossier VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER="$HOME_USER_PATH/.local/share/icons"
if [ -d $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER ]; then
	echo -e "✅ Le dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER existe !\n"
	VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_FOUND=true
	
	echo -e "Début de la vérification du propriétaire actuel dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER existant :\n"
	
	VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	
	echo -e "Le propriétaire actuel du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER existant est $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER !\n"
	
	if [[ $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire '$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER est correct !\n"
	else
		echo -e "❌ Le propriétaire '$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER n'est pas correct !\n"
		
		echo -e "Correction du propriétaire '$REAL_USER' du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER :\n"
		
		sudo chown $REAL_USER:$REAL_USER $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER
		
		VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	fi
	
	echo -e "Fin de la vérification du propriétaire actuel dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER existant !\n"
else
	echo -e "❌ Le dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER n'existe pas !\n"
	VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_FOUND=false
	
	echo -e "Création du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER :\n"
	
	mkdir $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER
	
	echo -e "Propriétaire actuel du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER créé :\n"
	
	VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	
	echo -e "Attribution de l'utilisateur actuel comme propriétaire du dossier :\n"
	
	sudo chown $REAL_USER:$REAL_USER $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER
	
	echo -e "Vérification du propriétaire du dossier créé :\n"
	
	VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	
	if [[ $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire '$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER est correct !\n"
	else
		echo -e "❌ Le propriétaire '$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER n'est pas correct !\n"
	fi
	
	echo -e "Vérification du propriétaire du dossier terminée !\n"
fi

echo -e "-------------------------------------- Icône VLC-Wrapper personnalisée --------------------------------------\n"

# Icone VLC WRAPPER
echo -e "Recherche de l'image icône perso VLC Wrapper pour Ubuntu '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' :\n"

if [ -f "$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH" ]; then

        echo -e "✅ Le fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existe !\n"
        
        # Vérification (et correction si besoin) du propriétaire du fichier existant
        echo -e "Vérification du propriétaire du fichier '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' déjà existant :\n"
        
        VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH | awk '{print $3}')

	if [[ $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER == $REAL_USER ]] ; then
		echo -e "✅ Le propriétaire '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER' du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant est correct !\n"
	else
		echo -e "❌ Le propriétaire '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER' du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant n'est pas correct !\n"
			
		echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier avant de le copier :\n"

		sudo chown $REAL_USER:$REAL_USER $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH		
	fi
	# Vérification (et correction si besoin) du propriétaire du fichier existant (FIN)

	# CHMOD du fichier existant
	echo -e "Vérification du chmod du fichier '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' déjà existant :\n"
	
	VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_TXT_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH | cut -d' ' -f1)
	
	case $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
		"-rw-r--r--") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=644 ;;
		"-rw-rw-r--") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=664 ;;
		"-rw-rw-rw-") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=666 ;;
		"-rwxrwx---") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=700 ;;
		"-rwxr-xr-x") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=755 ;;
		"-rwrrw-rw-") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=766 ;;
		"-rwxrwxr-x") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=775 ;;
		"-rwxrwxrwx") VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=777 ;;
		*) echo -e "Chmod inconnu !\n" ;;
	esac
	
        # echo -e "Le chmod du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant est $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD !\n"

	if [[ $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD == $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES ]] ; then
		echo -e "✅ Le chmod '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD' du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant est correct !\n"
	else
		echo -e "❌ Le chmod '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD' du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant n'est pas correct !\n"
			
		echo -e "Attribution du chmod demandé ($REAL_USER) sur le fichier avant de le copier :\n"

		sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH		
	fi
	# CHMOD du fichier existant (FIN)
	
	echo -e "Informations supplémentaires sur le fichier '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' existant :\n"
        
       	ls -l $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH
       		
	echo -e ""	
else
        echo -e "❌ Le fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME n'existe pas !\n"

        # Vérification de la présence du fichier icône à côté de ce script
        if [ -f "$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH" ]; then
        	echo -e "✅ Le fichier original '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' est présent à côté de ce script avant d'être copié !\n"
        	
        	# Propriétaire du fichier à copier
		echo -e "Vérification du propriétaire du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier dans le dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER :\n"
		
		VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH | awk '{print $3}')

		if [[ $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER == $REAL_USER ]] ; then
			echo -e "✅ Le propriétaire '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER' du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier est correct !\n"
		else
			echo -e "❌ Le propriétaire '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER' du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier n'est pas correct !\n"
			
			echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier avant de le copier :\n"

			sudo chown $REAL_USER:$REAL_USER $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH		
		fi
		
		echo -e "Fin de la vérification du propriétaire du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH avant de le copier dans le dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER !\n"
        	# Propriétaire du fichier à copier (FIN)
        	
        	# CHMOD du fichier à copier
        	echo -e "Vérification du CHMOD du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH avant de le copier dans le dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER :\n"
        	
        	echo -e "Le chmod demandé est $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES !\n"
        	
        	VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_TXT_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH | cut -d' ' -f1)
        	
		case $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
			"-rw-r--r--") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=644 ;;
			"-rw-rw-r--") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=664 ;;
			"-rw-rw-rw-") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=666 ;;
			"-rwxr-xr-x") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=755 ;;
			"-rwrrw-rw-") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=766 ;;
			"-rwxrwxr-x") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=775 ;;
			"-rwxrwxrwx") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=777 ;;
			*) echo -e "Chmod inconnu !\n" ;;
		esac        	
        	
        	echo -e "Le chmod du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier est $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD !\n"

		if [[ $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD == $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES ]] ; then
			echo -e "✅ Le chmod '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD' du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier est correct !\n"
		else
			echo -e "❌ Le chmod '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD' du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier n'est pas correct !\n"
			
			echo -e "Attribution du chmod demandé ($REAL_USER) sur le fichier avant de le copier :\n"

			sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH		
		fi
		# CHMOD du fichier à copier (FIN)
        	
        	echo -e "Fin de la vérification du CHMOD du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH avant de le copier dans le dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER !\n"
        	
        	# Copie du fichier
                echo -e "Copie du fichier icône $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH en cours :\n"

                sudo cp -v $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER
                
                echo -e ""             
		# Copie du fichier (FIN)

		# Contrôle du propriétaire du fichier copié
		VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH=$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME

		echo -e "Début du contrôle du propriétaire du fichier copié :\n"
		
		echo -e "Lecture du propriétaire du fichier copié\n"

		VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | awk '{print $3}')

		if [[ $VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_OWNER == $REAL_USER ]]; then
			echo -e "✅ Le propriétaire actuel '$VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_OWNER' du fichier copié $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH est correct !\n"
		else
			echo -e "❌ Le propriétaire actuel '$VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_OWNER' du fichier copié $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH n'est pas correct !\n"
			
			echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier copié :\n"		# Car peut arriver qu'il copie avec un proprio 'root'
			
			# Modification du propriétaire du fichier copié à l'utilisateur courant
			sudo chown $REAL_USER:$REAL_USER $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH	

		        echo -e "Vérification du propriétaire du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH copié :\n"
		        
		        VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_OWNER=$(ls -ld $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | awk '{print $3}')
		        
		        echo -e "✅ Le nouveau propriétaire '$VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_OWNER' du fichier copié est correct !\n"
		        
		        echo -e "Fin du contrôle du propriétaire du fichier copié !\n"			
		fi
		# Contrôle du propriétaire du fichier copié (FIN)

		# CHMOD du fichier copié
		VLC_WRAPPER_ICON_PNG_FILENAME_TXT_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | cut -d' ' -f1)

		case $VLC_WRAPPER_ICON_PNG_FILENAME_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
			"-rw-r--r--") VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=644 ;;
			"-rw-rw-r--") VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=664 ;;
			"-rw-rw-rw-") VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=666 ;;
			"-rwxr-xr-x") VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=755 ;;
			"-rwrrw-rw-") VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=766 ;;
			"-rwxrwxr-x") VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=775 ;;
			"-rwxrwxrwx") VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=777 ;;
			*) echo -e "Chmod inconnu !\n" ;;
		esac

		if [[ $VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD == $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES ]]; then
			echo -e "✅ Le CHMOD actuel du fichier copié '$VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD' est correct !\n"
		else
			echo -e "❌ Le CHMOD actuel du fichier copié '$VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD' n'est pas correct (différent de $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES) !\n"
			
			echo -e "Attribution du CHMOD demandé '$VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES' sur le fichier copié :\n"
			
			sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH
			
			# Attribution du chmod
			# chmod +x "$VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME"     
			
	       		ls -l $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH
					
			echo -e ""
			
			# CHMOD
			VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | cut -d' ' -f1)
				
			case $VLC_WRAPPER_ICON_PNG_FILENAME_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
				"-rw-r--r--") echo -e "-rw-r--r-- correspond à un chmod de 644 !\n" ;;
				"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
				"-rw-rw-rw-") echo -e "-rw-rw-rw- correspond à un chmod de 666 !\n" ;;
				"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
				"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
				"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
				"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
				*) echo -e "Chmod inconnu !\n" ;;
			esac
			
			echo -e "Fin de l'attribution du CHMOD demandé '$VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES' sur le fichier copié !\n"
		fi
		# CHMOD du fichier copié (FIN)
		
                echo -e "Fin de la vérification chmod et du propriétaire du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME copié !\n"		
        else
                echo -e "❌ Le fichier original '$VLC_WRAPPER_ICON_PNG_FILENAME' n'est pas présent à côté de ce script avant d'être copié !"              
        fi
fi

echo -e "-------------------------------------- VLC Wrapper .desktop file --------------------------------------\n"

echo -e "Recherche du raccourci perso VLC Wrapper pour Ubuntu '$VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH' :\n"

if [ -f "$VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH" ]; then

        echo -e "✅ Le fichier raccourci $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH existe !\n"
	
	echo -e "Vérification du propriétaire du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH :\n"
	
	VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_OWNER=$(ls -ld "$VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH" | awk '{print $3}')

	if [[ $VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire '$VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_OWNER' du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME est correct !\n"
	else
		echo -e "❌ Le propriétaire '$VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_OWNER' du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME n'est pas correct !\n"
			
		echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier existant $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME :\n"

		sudo chown $REAL_USER:$REAL_USER $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME
		
		echo -e "Fin de l'attribution du propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier existant $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME !\n"
	fi
	
	echo -e "Fin de la vérification du propriétaire du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH !\n"
	
        echo -e "Vérification du chmod du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH :\n"
        
	sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH
	        
       	ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH
				
	echo -e ""
	
	# CHMOD
	VLC_WRAPPER_DESKTOP_FILENAME_TXT_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH | cut -d' ' -f1)
			
	case $VLC_WRAPPER_DESKTOP_FILENAME_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
		"-rw-r--r--") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD="644" ;;
		"-rw-rw-r--") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD="664" ;;
		"-rw-rw-rw-") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD="666" ;;
		"-rwxr-xr-x") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD="755" ;;
		"-rwrrw-rw-") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD="766" ;;
		"-rwxrwxr-x") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD="775" ;;
		"-rwxrwxrwx") VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD="777" ;;
		*) echo -e "Chmod inconnu !\n" ;;
	esac
	
       	# echo -e "Le chmod du fichier $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH existant est $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD !\n"

	if [[ $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD == $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES ]] ; then
		echo -e "✅ Le chmod '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD' du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH existant est correct !\n"
	else
		echo -e "❌ Le chmod '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD' du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH existant n'est pas correct !\n"
		echo -e "Attribution du chmod demandé ($REAL_USER) sur le fichier avant de le copier :\n"

		sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH		
	fi	
	
	echo -e "Fin de la vérification du chmod du fichier $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME !\n"	

else

        echo -e "❌ Le fichier raccourci $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH n'existe pas !\n"

	VLC_WRAPPER_DESKTOP_FILENAME_CREATE_OR_COPY="create"
			
	case $VLC_WRAPPER_DESKTOP_FILENAME_CREATE_OR_COPY in
		"create")
			echo -e "Début de la création du fichier '$VLC_WRAPPER_DESKTOP_FILENAME' dans le dossier cible $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER :\n"
				
			# Récupération de la variable chemin d'utilisateur
			HOME_USER_PATH=$(eval echo "~${SUDO_USER:-$USER}")
				
			#eval $cat << EOF > home/kvm-user/.local/share/applications/mon-script.desktop\n[Desktop Entry]\nVersion=1.0\nEOF'
			#cat > $FREEBOX_LOCAL_SHARE_FOLDER/$FREEBOX_TV_FILENAME << 'EOF'
				
			# Ne pas identer le contenu des cat sinon les indentations apparaissent dans le fichier créé !
			cat << EOF > $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH
[Desktop Entry]
Version=1.0
Type=Application
Name=VLC Wrapper
Comment=Lancer VLC Wrapper
Exec=nice -n -10 vlc-wrapper --video-on-top
Icon=$HOME_USER_PATH/.local/share/icons/VLC_perso-512x512.png
Terminal=false
Categories=Multimedia;

# Pour la commande Exec, quelques explications sur les paramètres
# -f : Ouvre VLC en plein écran
# --no-qt-video-autoresize : ne redimensionne pas aux dimensions de la vidéo source
# --nooverlay : désactive l'accélération matérielle
# --playlist-enqueue : Ouvre la liste de lecture précisée /xxx/xxx.xspf
# --playlist-autostart : Lance la liste de lecture automatiquement au lancement (par défaut est déja à true)
# --intf qt : Ouvre la liste de lecture pour avoir le choix (bien pour choisir une chaine tv dans une playlist tv)
# %U : Désactive la console (peut parfois appraitre derrière l'interface) --> Marche pas 
#
# Ce fichier a été créé via le script Bash_Ubuntu_25_10_configuration_vX.X.X.sh écrit par Olivosaure !
EOF

			echo -e "✅ Le fichier '$VLC_WRAPPER_DESKTOP_FILENAME' a été créé dans le dossier cible $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER !\n"
				
			sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH				
				
			# Attribution du chmod
			# chmod +x "$VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH"
				
			# Modification du propriétaire du fichier à l'utilisateur courant
			sudo chown $REAL_USER:$REAL_USER $VLC_WRAPPER_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH
				
		   	ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME
						
			echo -e ""
				
			# CHMOD
			VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME | cut -d' ' -f1)
					
			case $VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
				"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
				"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
				"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
				"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
				"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
				"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
				"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
				*) echo -e "Chmod inconnu !\n" ;;
			esac
			
			echo -e "Fin de la création du fichier '$VLC_WRAPPER_DESKTOP_FILENAME' dans le dossier cible $VLC_WRAPPER_LOCAL_SHARE_FOLDER :\n"

		;;
			
		"copy")
			# Vérification de la présence du fichier playlist à côté de ce script
			if [ -f "$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH" ]; then
				echo -e "✅ Le fichier original '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' est présent à côté de ce script avant d'être copié !"

				echo -e "Copie du fichier icône $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH en cours"

				sudo cp -v $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER
					
				sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME
					
			       	ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME
							
				echo -e ""
					
				# CHMOD
				VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME | cut -d' ' -f1)
						
				case $VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
					"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
					"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
					"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
					"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
					"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
					"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
					"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
					*) echo -e "Chmod inconnu !\n" ;;
				esac   
			else
				echo -e "❌ Le fichier original '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' n'est pas présent à côté de ce script avant d'être copié !"
			fi
		;;
	esac 
fi

# Vérification des droits permissions du dossier utilisateur ~/local/share/icons
# echo -e "Attribution des droits permissions du dossier utilisateur '$HOME_USER_PATH/.local/share/icons' avec chmod :\n"

# sudo chmod 755 $HOME_USER_PATH/.local/share/icons

echo -e "------------------------------ Vérification des accès au dossier $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER --------------------------------\n"

echo -e "Attribution de propriétaire sur le dossier '$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER' avec chown :\n"

sudo chown -R $REAL_USER:$REAL_USER $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER

echo -e "Attribution d'un chmod de 755 sur le dossier '$VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER' :\n"

sudo chmod 755 $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER

# ls -ld $HOME_USER_PATH/.local/share/icons

echo -e "Rappel : Security Note: Running VLC as root can expose your system to vulnerabilities if a malicious media file exploits a bug in the player. Always prefer using vlc-wrapper or running VLC under a non-root user account."

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL"
echo -e $TEXT_RESET

#################
############################## RACCOURCI VLC WRAPPER ####################################
fi # if $INSTALL_VLC_WRAPPER_DESKTOP_SHORTCUT || $INSTALL_ALL; then








if $INSTALL_WHATSAPP; then
############################## RACCOURCI WHATSAPP ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="WhatsApp"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT	# Normalement non nécessaire

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemins des fichiers et/ou dossiers pour contrôler leur présence
# Rajout du chemin relatif du dossier des fichiers additionnels de ce script de configuration
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="./Bash_Ubuntu_25_10_configuration-Additional_files"

# Noms des fichiers ou dossiers à rechercher
WHATSAPP_WEBAPP_DESKTOP_FILENAME_WITHOUT_EXTENSION="whatsapp-webapp-Dock_access"
WHATSAPP_WEBAPP_DESKTOP_FILENAME="$WHATSAPP_WEBAPP_DESKTOP_FILENAME_WITHOUT_EXTENSION.desktop"
WHATSAPP_WEBAPP_ICON_PNG_FILENAME="WhatsApp_icon.png"
WHATSAPP_WEBAPP_LOCAL_SUBFOLDER="WhatsApp_Web_App-Dock_Acess"

WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$WHATSAPP_WEBAPP_LOCAL_SUBFOLDER/$WHATSAPP_WEBAPP_ICON_PNG_FILENAME
WHATSAPP_WEBAPP_DESKTOP_FILENAME_TO_COPY_COMPLETEPATH=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/$WHATSAPP_WEBAPP_LOCAL_SUBFOLDER/$WHATSAPP_WEBAPP_DESKTOP_FILENAME

# Aller au répertoire utilisateur
HOME_USER_PATH=$(eval echo "~${SUDO_USER:-$USER}")

# Chemins des dossiers locaux pour contrôler sa présence
WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_FOLDER="$HOME_USER_PATH/.local/share/applications"
WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER="$HOME_USER_PATH/.local/share/icons"
WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH=$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_FOLDER/$WHATSAPP_WEBAPP_DESKTOP_FILENAME
WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH=$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER/$WHATSAPP_WEBAPP_ICON_PNG_FILENAME

# Booléens associés
WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_FOUND=false

# Chmod des fichiers et/ou dossiers à créer si nécessaire
WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES="755"
WHATSAPP_WEBAPP_CHMOD_DESKTOP_FILE="644"

echo -e "------------ Recherche et vérification de la présence des fichiers et/ou dossiers ------------\n"

# Contrôle de la présence du dossier WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER="$HOME_USER_PATH/.local/share/icons"
if [ -d $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER ]; then
	echo -e "✅ Le dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER existe !\n"
	WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_FOUND=true
	
	echo -e "Début de la vérification du propriétaire actuel dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER existant :\n"
	
	WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	
	echo -e "Le propriétaire actuel du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER existant est $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER !\n"
	
	if [[ $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER est correct !\n"
	else
		echo -e "❌ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER n'est pas correct !\n"
		
		echo -e "Correction du propriétaire '$REAL_USER' du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER :\n"
		
		sudo chown $REAL_USER:$REAL_USER $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER
		
		WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	fi
	
	echo -e "Fin de la vérification du propriétaire actuel dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER existant !\n"
else
	echo -e "❌ Le dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER n'existe pas !\n"
	WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_FOUND=false
	
	echo -e "Création du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER :\n"
	
	mkdir $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER
	
	echo -e "Propriétaire actuel du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER créé :\n"
	
	WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	
	echo -e "Attribution de l'utilisateur actuel comme propriétaire du dossier :\n"
	
	sudo chown $REAL_USER:$REAL_USER $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER
	
	echo -e "Vérification du propriétaire du dossier créé :\n"
	
	WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER | awk '{print $3}')
	
	if [[ $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER est correct !\n"
	else
		echo -e "❌ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER' du dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER n'est pas correct !\n"
	fi
	
	echo -e "Vérification du propriétaire du dossier terminée !\n"
fi


echo -e "-------------------------------------- Icône WhatsApp WebApp personnalisée --------------------------------------\n"

# Icone VLC WRAPPER
echo -e "Recherche de l'image icône perso VLC Wrapper pour Ubuntu '$VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' :\n"

if [ -f "$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH" ]; then

        echo -e "✅ Le fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existe !\n"
        
        # Vérification (et correction si besoin) du propriétaire du fichier existant
        echo -e "Vérification du propriétaire du fichier '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' déjà existant :\n"
        
        WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH | awk '{print $3}')

	if [[ $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER == $REAL_USER ]] ; then
		echo -e "✅ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER' du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant est correct !\n"
	else
		echo -e "❌ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_OWNER' du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant n'est pas correct !\n"
			
		echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier avant de le copier :\n"

		sudo chown $REAL_USER:$REAL_USER $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH	
	fi
	# Vérification (et correction si besoin) du propriétaire du fichier existant (FIN)

	# CHMOD du fichier existant
	echo -e "Vérification du chmod du fichier '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' déjà existant :\n"
	
	WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_TXT_ACTUAL_CHMOD=$(ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH | cut -d' ' -f1)
	
	case $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
		"-rw-r--r--") WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=644 ;;
		"-rw-rw-r--") WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=664 ;;
		"-rw-rw-rw-") WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=666 ;;
		"-rwxr-xr-x") WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=755 ;;
		"-rwrrw-rw-") WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=766 ;;
		"-rwxrwxr-x") WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=775 ;;
		"-rwxrwxrwx") WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD=777 ;;
		*) echo -e "Chmod inconnu !\n" ;;
	esac
	
        # echo -e "Le chmod du fichier $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant est $VLC_WRAPPER_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD !\n"

	if [[ $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD == $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES ]] ; then
		echo -e "✅ Le chmod '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD' du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant est correct !\n"
	else
		echo -e "❌ Le chmod '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH_ACTUAL_CHMOD' du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH existant n'est pas correct !\n"
			
		echo -e "Attribution du chmod demandé ($REAL_USER) sur le fichier avant de le copier :\n"

		sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH		
	fi
	# CHMOD du fichier existant (FIN)
	
	echo -e "Informations supplémentaires sur le fichier '$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH' existant :\n"
        
       	ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH
       		
	echo -e ""	
else
        echo -e "❌ Le fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_ICON_PNG_FILENAME_COMPLETEPATH n'existe pas !\n"

        # Vérification de la présence du fichier icône à côté de ce script
        if [ -f "$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH" ]; then
        	echo -e "✅ Le fichier original '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' est présent à côté de ce script avant d'être copié !\n"
        	
        	# Propriétaire du fichier à copier
		echo -e "Vérification du propriétaire du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier dans le dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER :\n"
		
		WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH | awk '{print $3}')

		if [[ $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER == $REAL_USER ]] ; then
			echo -e "✅ Le propriétaire '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER' du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier est correct !\n"
		else
			echo -e "❌ Le propriétaire '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_OWNER' du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier n'est pas correct !\n"
			
			echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier avant de le copier :\n"

			sudo chown $REAL_USER:$REAL_USER $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH		
		fi
		
		echo -e "Fin de la vérification du propriétaire du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH avant de le copier dans le dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER !\n"
        	# Propriétaire du fichier à copier (FIN)
        	
        	# CHMOD du fichier à copier
        	echo -e "Vérification du CHMOD du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH avant de le copier dans le dossier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER :\n"
        	
        	echo -e "Le chmod demandé est $WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES !\n"
        	
        	WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_TXT_ACTUAL_CHMOD=$(ls -l $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH | cut -d' ' -f1)
        	
		case $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
			"-rw-r--r--") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=644 ;;
			"-rw-rw-r--") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=664 ;;
			"-rw-rw-rw-") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=666 ;;
			"-rwxr-xr-x") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=755 ;;
			"-rwrrw-rw-") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=766 ;;
			"-rwxrwxr-x") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=775 ;;
			"-rwxrwxrwx") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD=777 ;;
			*) echo -e "Chmod inconnu !\n" ;;
		esac        	
        	
        	echo -e "Le chmod du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier est $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD !\n"

		if [[ $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD == $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES ]] ; then
			echo -e "✅ Le chmod '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD' du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier est correct !\n"
		else
			echo -e "❌ Le chmod '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH_ACTUAL_CHMOD' du fichier $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH à copier n'est pas correct !\n"
			
			echo -e "Attribution du chmod demandé ($REAL_USER) sur le fichier avant de le copier :\n"

			sudo chmod $WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH		
		fi
		# CHMOD du fichier à copier (FIN)
        	
        	# Copie du fichier
                echo -e "Copie du fichier icône $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH en cours :\n"

                sudo cp -v $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER
                
                echo -e ""             
		# Copie du fichier (FIN)

		# Contrôle du propriétaire du fichier copié
		WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH=$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER/$WHATSAPP_WEBAPP_ICON_PNG_FILENAME

		echo -e "Début du contrôle du propriétaire du fichier copié :\n"
		
		echo -e "Lecture du propriétaire du fichier copié\n"

		WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | awk '{print $3}')

		if [[ $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_OWNER == $REAL_USER ]]; then
			echo -e "✅ Le propriétaire actuel '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_OWNER' du fichier copié $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH est correct !\n"
		else
			echo -e "❌ Le propriétaire actuel '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_OWNER' du fichier copié $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH n'est pas correct !\n"
			
			echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier copié :\n"		# Car peut arriver qu'il copie avec un proprio 'root'
			
			# Modification du propriétaire du fichier copié à l'utilisateur courant
			sudo chown $REAL_USER:$REAL_USER $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH	

		        echo -e "Vérification du propriétaire du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH copié :\n"
		        
		        WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_OWNER=$(ls -ld $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | awk '{print $3}')
		        
		        echo -e "✅ Le nouveau propriétaire '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_OWNER' du fichier copié est correct !\n"
		        
		        echo -e "Fin du contrôle du propriétaire du fichier copié !\n"			
		fi
		# Contrôle du propriétaire du fichier copié (FIN)

		# CHMOD du fichier copié
		WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TXT_ACTUAL_CHMOD=$(ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | cut -d' ' -f1)

		case $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
			"-rw-r--r--") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=644 ;;
			"-rw-rw-r--") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=664 ;;
			"-rw-rw-rw-") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=666 ;;
			"-rwxr-xr-x") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=755 ;;
			"-rwrrw-rw-") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=766 ;;
			"-rwxrwxr-x") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=775 ;;
			"-rwxrwxrwx") WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=777 ;;
			*) echo -e "Chmod inconnu !\n" ;;
		esac

		if [[ $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD == $WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES ]]; then
			echo -e "✅ Le CHMOD actuel du fichier copié '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD' est correct !\n"
		else
			echo -e "❌ Le CHMOD actuel du fichier copié '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD' n'est pas correct (différent de $WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES) !\n"
			
			echo -e "Attribution du CHMOD demandé '$WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES' sur le fichier copié :\n"
			
			sudo chmod $WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH
			
			# Attribution du chmod
			# chmod +x "$VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_ICONS_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME"     
			
	       		ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH
					
			echo -e ""
			
			# CHMOD
			WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD=$(ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FILENAME_COMPLETEPATH | cut -d' ' -f1)
				
			case $WHATSAPP_WEBAPP_ICON_PNG_FILENAME_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
				"-rw-r--r--") echo -e "-rw-r--r-- correspond à un chmod de 644 !\n" ;;
				"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
				"-rw-rw-rw-") echo -e "-rw-rw-rw- correspond à un chmod de 666 !\n" ;;
				"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
				"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
				"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
				"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
				*) echo -e "Chmod inconnu !\n" ;;
			esac
			
			echo -e "Fin de l'attribution du CHMOD demandé '$WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES' sur le fichier copié !\n"
		fi
		# CHMOD du fichier copié (FIN)
		
                echo -e "Fin de la vérification chmod et du propriétaire du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER/$VLC_WRAPPER_ICON_PNG_FILENAME copié !\n"		
        else
                echo -e "❌ Le fichier original '$WHATSAPP_WEBAPP_ICON_PNG_FILENAME' n'est pas présent à côté de ce script avant d'être copié !"              
        fi
fi

echo -e "-------------------------------------- WhatsApp_Dock_access_with_icon.desktop file --------------------------------------\n"

echo -e "Recherche du raccourci perso VLC Wrapper pour Ubuntu '$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH' :\n"

if [ -f "$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH" ]; then

        echo -e "✅ Le fichier raccourci $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH existe !\n"
        
	echo -e "Vérification du propriétaire du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH :\n"
	
	WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_OWNER=$(ls -ld "$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH" | awk '{print $3}')

	if [[ $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_OWNER == $REAL_USER ]]; then
		echo -e "✅ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_OWNER' du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH est correct !\n"
	else
		echo -e "❌ Le propriétaire '$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_OWNER' du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH n'est pas correct !\n"
			
		echo -e "Attribution de propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier existant $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH :\n"

		sudo chown $REAL_USER:$REAL_USER $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH
		
		echo -e "Fin de l'attribution du propriétaire à l'utilisateur actuel ($REAL_USER) sur le fichier existant $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH !\n"
	fi	

	# CHMOD - Début
        echo -e "Vérification du chmod du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH :\n"
              
	sudo chmod $WHATSAPP_WEBAPP_CHMOD_DESKTOP_FILE $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH
	
       	ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH
				
	echo -e ""
	
	WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_TXT_ACTUAL_CHMOD=$(ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH | cut -d' ' -f1)
			
	case $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_TXT_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
		"-rw-r--r--") 
			echo -e "-rw-r--r-- correspond à un chmod de 644 !\n" 
			WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_CHMOD="644"
		;;
		"-rw-rw-r--") 
			echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n"
			WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_CHMOD="664"
		;;
		"-rw-rw-rw-") echo -e "-rw-rw-rw- correspond à un chmod de 666 !\n" ;;
		"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
		"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
		"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
		"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
		*) echo -e "Chmod inconnu !\n" ;;
	esac
	
	if [[ $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_CHMOD == $WHATSAPP_WEBAPP_CHMOD_DESKTOP_FILE ]] ; then
		echo -e "✅ Le chmod '$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_CHMOD' du fichier '$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH' est correct !\n"
	else
		echo -e "❌ Le chmod '$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_CHMOD' du fichier '$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH' n'est pas correct !\n"
	fi
	
	echo -e "Fin de la vérification du chmod du fichier $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH !\n"
	# CHMOD - Fin
else

        echo -e "❌ Le fichier raccourci $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH n'existe pas !\n"

	WHATSAPP_WEBAPP_DESKTOP_FILENAME_CREATE_OR_COPY="create"
			
	case $WHATSAPP_WEBAPP_DESKTOP_FILENAME_CREATE_OR_COPY in
		"create")
			echo -e "Début de la création du fichier '$WHATSAPP_WEBAPP_DESKTOP_FILENAME' dans le dossier cible $WHATSAPP_WEBAPP_LOCAL_SHARE_FOLDER :\n"
				
			# Récupération de la variable chemin d'utilisateur
			HOME_USER_PATH=$(eval echo "~${SUDO_USER:-$USER}")
				
			#eval $cat << EOF > home/kvm-user/.local/share/applications/mon-script.desktop\n[Desktop Entry]\nVersion=1.0\nEOF'
			#cat > $FREEBOX_LOCAL_SHARE_FOLDER/$FREEBOX_TV_FILENAME << 'EOF'
				
			# Ne pas identer le contenu des cat sinon les indentations apparaissent dans le fichier créé !
			cat << EOF > $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH
[Desktop Entry]
Name=WhatsApp
Comment=WhatsApp WebApp
Exec=firefox https://web.whatsapp.com
Icon=$HOME_USER_PATH/.local/share/icons/WhatsApp_icon.png
Terminal=false
Type=Application
Categories=Network;InstantMessaging;WebBrowser;
StartupNotify=false

# Pour la commande Exec, quelques explications sur les paramètres
# -f : Ouvre VLC en plein écran
# --no-qt-video-autoresize : ne redimensionne pas aux dimensions de la vidéo source
# --nooverlay : désactive l'accélération matérielle
# --playlist-enqueue : Ouvre la liste de lecture précisée /xxx/xxx.xspf
# --playlist-autostart : Lance la liste de lecture automatiquement au lancement (par défaut est déja à true)
# --intf qt : Ouvre la liste de lecture pour avoir le choix (bien pour choisir une chaine tv dans une playlist tv)
# %U : Désactive la console (peut parfois appraitre derrière l'interface) --> Marche pas 
#
# Pour le rendre exécutable, utiliser la commande chmod +x ~/.local/share/applications/site-web.desktop d'après Brave AI
#
# Ce fichier a été créé via le script Bash_Ubuntu_25_10_configuration_vX.X.X.sh écrit par Olivosaure !
EOF

			echo -e "✅ Le fichier '$WHATSAPP_WEBAPP_DESKTOP_FILENAME' a été créé dans le dossier cible $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER !\n"	
				
			# Attribution du chmod
			# chmod +x "$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH"
				
			# Modification du propriétaire du fichier à l'utilisateur courant
			sudo chown $REAL_USER:$REAL_USER $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH	

			sudo chmod $WHATSAPP_WEBAPP_CHMOD_FOLDERS_AND_FILES $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH

		   	ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH	
						
			echo -e ""
				
			# CHMOD
			WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_CHMOD=$(ls -l $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH	 | cut -d' ' -f1)
					
			case $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_DESKTOP_FILENAME_FULLPATH_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
				"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
				"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
				"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
				"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
				"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
				"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
				"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
				*) echo -e "Chmod inconnu !\n" ;;
			esac
			
			echo -e "Fin de la création du fichier '$VLC_WRAPPER_DESKTOP_FILENAME' dans le dossier cible $FREEBOX_LOCAL_SHARE_FOLDER :\n"

		;;
			
		"copy")
			# Vérification de la présence du fichier playlist à côté de ce script
			if [ -f "$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH" ]; then
				echo -e "✅ Le fichier original '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' est présent à côté de ce script avant d'être copié !"

				echo -e "Copie du fichier icône $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH en cours"

				sudo cp -v $VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER
					
				sudo chmod $VLC_WRAPPER_CHMOD_FOLDERS_AND_FILES $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME
					
			       	ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME
							
				echo -e ""
					
				# CHMOD
				VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_CHMOD=$(ls -l $VLC_WRAPPER_LOCAL_SHARE_APPS_FOLDER/$VLC_WRAPPER_DESKTOP_FILENAME | cut -d' ' -f1)
						
				case $VLC_WRAPPER_DESKTOP_FILENAME_ACTUAL_CHMOD in # Dans l'ordre des chmods 644, 664, 666, 777
					"-rw-r--r--") echo -e "-rw-rw-r-- correspond à un chmod de 644 !\n" ;;
					"-rw-rw-r--") echo -e "-rw-rw-r-- correspond à un chmod de 664 !\n" ;;
					"-rw-rw-rw-") echo -e "-rw-rw-r-- correspond à un chmod de 666 !\n" ;;
					"-rwxr-xr-x") echo -e "-rwxr-xr-x correspond à un chmod de 755 !\n" ;;
					"-rwrrw-rw-") echo -e "-rwrrw-rw- correspond à un chmod de 766 !\n" ;;
					"-rwxrwxr-x") echo -e "-rwxrwxr-x correspond à un chmod de 775 !\n" ;;
					"-rwxrwxrwx") echo -e "-rwxrwxrwx correspond à un chmod de 777 !\n" ;;
					*) echo -e "Chmod inconnu !\n" ;;
				esac   
			else
				echo -e "❌ Le fichier original '$VLC_WRAPPER_ICON_PNG_FILENAME_TO_COPY_COMPLETEPATH' n'est pas présent à côté de ce script avant d'être copié !"
			fi
		;;
	esac 
fi

# Gestion du dock : on épingle la nouvelle app
echo -e "Début de l'ajout de l'application au dock :\n"

WHATSAPP_WEBAPP_DOCK_SETUP_TYPE="Brut"

case $WHATSAPP_WEBAPP_DOCK_SETUP_TYPE in
	"Brut")
		echo -e "Ajout au dock en méthode brut (en suspens, pas codé) :\n"
	
		#sudo gsettings set org.gnome.shell favorite-apps "['org.gnome.TextEditor.desktop', 'org.gnome.Nautilus.desktop', 'firefox_firefox.desktop', 'vlc.desktop' ]"
		
		
	;;
	
	*)
		echo -e "Ajout au dock en méthode propre mais marche pas :"
		
		# dbus-run-session -- gsettings set org.gnome.shell favorite-apps "$new_favorites"

		echo -e "Validation du fichier desktop :\n"

		desktop-file-validate $HOME_USER_PATH/.local/share/applications/whatsapp-webapp-Dock_access.desktop

		echo -e "Mise à jour des applications du dock pour détecter la nouvelle application :\n"

		update-desktop-database $HOME_USER_PATH/.local/share/applications/


		echo -e "Début de la récupération de la liste des applications épinglées au dock :\n" 

		current_favorites=""

		# Récupérer la liste actuelle des favoris
		current_favorites=$(gsettings get org.gnome.shell favorite-apps)

		echo -e $current_favorites

		echo -e ""

		echo -e "Fin de la récupération de la liste des applications épinglées au dock !\n"


		# Contrôle de la présence de l'application dans le dock (déja épinglée)
		if gsettings get org.gnome.shell favorite-apps | grep -q "'whatsapp-webapp-Dock_access'"; then
			echo "whatsapp-webapp-Dock_access est dans les favoris"
		else
			echo "whatsapp-webapp-Dock_access n'est pas dans les favoris"
			
			new_favorites=""

			# Ajouter le nom du fichier .desktop (sans extension) à la liste
			# new_favorites=$(echo "$current_favorites" | sed 's/\]/, '\''whatsapp-webapp-Dock_access'\'' ]/')

			new_favorites=$(echo "$current_favorites" | awk '{gsub(/\]/, ", \"whatsapp-webapp-Dock_access\" ]")} 1')   


			echo -e $new_favorites

			gsettings set org.gnome.shell favorite-apps "$new_favorites"

			echo -e "L'application a été ajoutée au dock !\n"

		fi	
	;;
esac




echo -e "Fin de l'ajout de l'application au dock !\n"





echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-80s|%-61s	|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "             Informations supplémentaires"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-8s|%-8s|%-60s|%-60s	|\n" " APT" " SNA" " FLA" " Existe" " Taille" "        Chemin du fichier ou dossier recherché              " "                       Commentaires"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

echo -e "$WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_FOUND	|   $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER_ACTUAL_OWNER	| $WHATSAPP_WEBAPP_LOCAL_SHARE_ICONS_FOLDER	"
echo -e "$WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH_FOUND	|		| $WHATSAPP_WEBAPP_LOCAL_SHARE_APPS_VLC_WRAPPER_DESKTOP_FILENAME_COMPLETEPATH"
echo -e ""




case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $APPNAME_BIN_FILENAME_FOUND && $APPNAME_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $APPNAME_BIN_FILENAME_FOUND || ! $APPNAME_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $APPNAME_BIN_FILENAME_FOUND && ! $APPNAME_SHARE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi	
	;;
	
	*)
	
	;;
esac

echo -e "-------------------------------------- Ajout de l'appli 'WhatsApp_Dock_access_with_icon.desktop' au dock --------------------------------------\n"

# Dépendances nécessaires dans les VM QEMU-KVM Ubuntu25.10
# Il faut installer 'sudo apt install dbus-x11' pour ne pas a avoir d'erreur sur les commandes gsettings 

new_app_to_add_to_dock="whatsapp-webapp-Dock_access.desktop"

echo -e "Application à ajouter au dock : $new_app_to_add_to_dock\n"

current_apps=$(gsettings get org.gnome.shell favorite-apps | sed 's/\[//;s/\]//')

echo -e "Liste des applis actuelles dans gsettings avant l'ajout :\n"

echo -e $current_apps

echo -e ""

# Ajout de la nouvelle appli
if gsettings get org.gnome.shell favorite-apps | grep -q $new_app_to_add_to_dock; then
	echo -e "L'application est déja dans les favoris !\n"
else
	echo -e "L'application n'est pas dans les favoris !\n"
	
	echo -e "Ajout de la nouvelle appli :\n"
	gsettings set org.gnome.shell favorite-apps "[$current_apps, '$new_app_to_add_to_dock']"
fi

# Vérification
echo -e "Vérification de l'ajout de la nouvelle application :\n"

current_apps_with_new=$(gsettings get org.gnome.shell favorite-apps | sed 's/\[//;s/\]//')

echo -e "$current_apps_with_new"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## RACCOURCI WHATSAPP #################################### 
fi # if $INSTALL_WHATSAPP; then


############################### FICHIERS RACCOURCIS .DESKTOP (FIN) ##########################

############################### JEUX ###############################
if $INSTALL_GNOME_SUDOKU || $INSTALL_ALL; then
############################## GNOME SUDOKU ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Gnome-Sudoku"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation du minijeu $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin du dossier apt pour contrôler sa présence
GNOME_SUDOKU_GAMES_FILENAME="/usr/games/gnome-sudoku"
GNOME_SUDOKU_SHARE_FOLDER="/usr/share/doc/gnome-sudoku"
GNOME_SUDOKU_SHARE_HELP_C_FOLDER="/usr/share/help/C/gnome-sudoku"
GNOME_SUDOKU_SHARE_HELP_CA_FOLDER="/usr/share/help/ca/gnome-sudoku"


case $TXT_SETUP_TYPE in
        $TXT_SETUP_TYPE_APT)

		# Contrôle de la présence de fichiers et/ou dossiers existants
		echo -e "Recherche en cours de version déja installée :\n"

		# Contrôle de la présence de fichiers et/ou dossiers existants
		if [ -f "$GNOME_SUDOKU_GAMES_FILENAME" ]; then
		        echo -e "✅ Le fichier $GNOME_SUDOKU_GAMES_FILENAME existe !\n"
		else
			echo -e "❌ Le fichier $GNOME_SUDOKU_GAMES_FILENAME n'existe pas !\n"
		fi
		
		if [ -d "$GNOME_SUDOKU_SHARE_FOLDER" ]; then
		        echo -e "✅ Le dossier $GNOME_SUDOKU_SHARE_FOLDER existe !\n"
		        
			# Calcul de la taille du dossier installé
			TAILLE_GNOME_SUDOKU_SHARE_FOLDER=$(du -sh "$GNOME_SUDOKU_SHARE_FOLDER" | cut -f1)

			# Affichage console de la taille du dossier installé
			echo -e "La taille du dossier $GNOME_SUDOKU_SHARE_FOLDER est : $TAILLE_GNOME_SUDOKU_SHARE_FOLDER\n"		        
		else
			echo -e "❌ Le dossier $GNOME_SUDOKU_SHARE_FOLDER n'existe pas !\n"
		fi		
		
		if [ -d "$GNOME_SUDOKU_SHARE_HELP_C_FOLDER" ]; then
		        echo -e "✅ Le dossier $GNOME_SUDOKU_SHARE_HELP_C_FOLDER existe !\n"

			# Calcul de la taille du dossier installé
			TAILLE_GNOME_SUDOKU_SHARE_HELP_C_FOLDER=$(du -sh "$GNOME_SUDOKU_SHARE_HELP_C_FOLDER" | cut -f1)

			# Affichage console de la taille du dossier installé
			echo -e "La taille du dossier $GNOME_SUDOKU_SHARE_HELP_C_FOLDER est : $TAILLE_GNOME_SUDOKU_SHARE_HELP_C_FOLDER\n"

		else
		        echo -e "❌ Le dossier $GNOME_SUDOKU_SHARE_HELP_CA_FOLDER n'existe pas !\n"      
		fi
		
		if [ -d "$GNOME_SUDOKU_SHARE_HELP_CA_FOLDER" ]; then
		        echo -e "✅ Le dossier $GNOME_SUDOKU_SHARE_HELP_CA_FOLDER existe !\n"

                        # Calcul de la taille du dossier installé
                        TAILLE_GNOME_SUDOKU_SHARE_HELP_CA_FOLDER=$(du -sh "$GNOME_SUDOKU_SHARE_HELP_CA_FOLDER" | cut -f1)

                        # Affichage console de la taille du dossier installé
                        echo -e "La taille du dossier $GNOME_SUDOKU_SHARE_HELP_CA_FOLDER est : $TAILLE_GNOME_SUDOKU_SHARE_HELP_CA_FOLDER\n"

		else
		        echo -e "❌ Le dossier $GNOME_SUDOKU_SHARE_HELP_CA_FOLDER n'existe pas !\n"      
		fi		




		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if [[ -f "$GNOME_SUDOKU_GAMES_FILENAME" ]] && [[ -d "$GNOME_SUDOKU_SHARE_FOLDER" ]]; then
		        echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

		        echo -e "Informations sur la version installée :\n"

		        # Affichage de la version du paquet FWUPD installé
		        dpkg -l gnome-sudoku

			echo -e ""		
		fi
		
		# Si au moins un des fichiers et/ou dossiers recherchés n'a pas été trouvé
		if [[ ! -f "$GNOME_SUDOKU_GAMES_FILENAME" ]] || [[ ! -d "$GNOME_SUDOKU_SHARE_FOLDER" ]]; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi
		
		# Si aucun des fichiers et/ou dossiers recherchés ont été trouvés
		if [[ ! -f "$GNOME_SUDOKU_GAMES_FILENAME" ]] && [[ ! -d "$GNOME_SUDOKU_SHARE_FOLDER" ]]; then
		        echo -e "L'application $TXT_APP_TO_INSTALL n'est pas installée\n"

		        echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
		        
		        sudo apt install -y gnome-sudoku	
		fi		

	;;
	# APT - Fin setup type APT

	*)

	;;
esac

echo -e "Pour plus d'informations, il existe un Github à l'adresse suivante : https://github.com/ubuntu/gnome-sudoku"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du minijeu $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## GNOME SUDOKU ####################################
fi # if $INSTALL_GNOME_SUDOKU; then

if $INSTALL_STEAM || $INSTALL_ALL; then
############################## STEAM ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Steam"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_DEB

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo "${TXT_APP_TO_INSTALL^^} - Installation de la plateforme de jeu $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Variables d'installation à partir d'un fichier local .deb
BASH_CONFIG_ADDITIONNAL_FILES_FOLDER="Bash_Ubuntu_25_10_configuration-Additional_files"
# Chemins des fichiers et/ou dossiers DEB locaux
STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME="steam-launcher_latest-stable_amd64.deb"
STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FOLDER=$BASH_CONFIG_ADDITIONNAL_FILES_FOLDER/DEB
STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH=$STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FOLDER/$STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME

# Chemin des dossiers à contrôler
STEAM_TMP_FOLDER="/tmp/steam"
STEAM_USR_LIB_FOLDER="/usr/lib/steam"
STEAM_SHARE_DOC_FOLDER="/usr/share/doc/steam"
STEAM_INSTALLER_SHARE_DOC_FOLDER="/usr/share/doc/steam-installer"
STEAM_LAUNCHER_USER_SHARE_DOC_FOLDER="/usr/share/doc/steam-launcher"
STEAM_INSTALLER_USER_SHARE_BUG_FOLDER="/usr/share/bug/steam-installer"

# Fichiers APPARMORS
STEAM_INSTALLER_ETC_APPARMOR_D_FILENAME="steam-installer"
STEAM_INSTALLER_ETC_APPARMOR_D_FOLDER="/etc/appamor.d/"
STEAM_INSTALLER_ETC_APPARMOR_D_FILEPATH=$STEAM_INSTALLER_ETC_APPARMOR_D_FOLDER$STEAM_INSTALLER_ETC_APPARMOR_D_FILENAME

# Récupération du chemin répertoire de l'utilisateur actuel
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")

# Chemin du dossier utilisateur
STEAM_HOME_USER_FOLDER="$USER_HOME/.steam"
STEAM_LOCAL_SHARE_STEAM_FOLDER="$USER_HOME/.local/share/Steam"
STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER="$USER_HOME/.local/share/Steam/steamapps/common"                   # Chemin du dossier contenant les jeux installés via Steam

# Chemin du raccourci launcher Ubuntu
STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME="/usr/share/applications/steam.desktop"



# Initialisation des booléens de fichiers/dossiers trouvés
STEAM_TMP_FOLDER_FOUND=false
STEAM_USR_LIB_FOLDER_FOUND=false
STEAM_SHARE_DOC_FOLDER_FOUND=false

STEAM_HOME_USER_FOLDER_FOUND=false
STEAM_LOCAL_SHARE_STEAM_FOLDER_FOUND=false
STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER_FOUND=false

STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME_FOUND=false

STEAM_INSTALLER_DPKG_FOUND=false

STEAM_INSTALLER_USER_SHARE_BUG_FOLDER_FOUND=false


# Contrôle du dossier 
if Recherche_dossier $STEAM_TMP_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_TMP_FOLDER existe !\n"; fi
	STEAM_TMP_FOLDER_FOUND=true
	TAILLE_STEAM_TMP_FOLDER=$(du -sh "$STEAM_TMP_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_TMP_FOLDER n'existe pas !\n"; fi
	STEAM_TMP_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $STEAM_USR_LIB_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_USR_LIB_FOLDER existe !\n"; fi
	STEAM_USR_LIB_FOLDER_FOUND=true
	TAILLE_STEAM_USR_LIB_FOLDER=$(du -sh "$STEAM_USR_LIB_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_USR_LIB_FOLDER n'existe pas !\n"; fi
	STEAM_USR_LIB_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $STEAM_SHARE_DOC_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_SHARE_DOC_FOLDER existe !\n"; fi
	STEAM_SHARE_DOC_FOLDER_FOUND=true
	TAILLE_STEAM_SHARE_DOC_FOLDER=$(du -sh "$STEAM_SHARE_DOC_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	STEAM_SHARE_DOC_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $STEAM_INSTALLER_SHARE_DOC_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_INSTALLER_SHARE_DOC_FOLDER existe !\n"; fi
	STEAM_INSTALLER_SHARE_DOC_FOLDER_FOUND=true
	TAILLE_STEAM_SHARE_DOC_FOLDER=$(du -sh "$STEAM_INSTALLER_SHARE_DOC_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_INSTALLER_SHARE_DOC_FOLDER n'existe pas !\n"; fi
	STEAM_INSTALLER_SHARE_DOC_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $STEAM_HOME_USER_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_HOME_USER_FOLDER existe !\n"; fi
	STEAM_HOME_USER_FOLDER_FOUND=true
	TAILLE_STEAM_HOME_USER_FOLDER=$(du -sh "$STEAM_HOME_USER_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_HOME_USER_FOLDER n'existe pas !\n"; fi
	STEAM_HOME_USER_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $STEAM_LOCAL_SHARE_STEAM_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_LOCAL_SHARE_STEAM_FOLDER existe !\n"; fi
	STEAM_LOCAL_SHARE_STEAM_FOLDER_FOUND=true
	TAILLE_STEAM_LOCAL_SHARE_STEAM_FOLDER=$(du -sh "$STEAM_LOCAL_SHARE_STEAM_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_LOCAL_SHARE_STEAM_FOLDER n'existe pas !\n"; fi
	STEAM_LOCAL_SHARE_STEAM_FOLDER_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER existe !\n"; fi
	STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER_FOUND=true
	TAILLE_STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER=$(du -sh "$STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER n'existe pas !\n"; fi
	STEAM_LOCAL_SHARE_STEAM_STEAMAPPS_COMMON_FOLDER_FOUND=false
fi

# Contrôle de fichier
if Recherche_fichier $STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME existe !\n"; fi
	STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME_FOUND=true
	TAILLE_STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME=$(du -sh "$STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME n'existe pas !\n"; fi
	STEAM_USR_SHARE_APPLICATIONS_STEAM_DESKTOP_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $STEAM_INSTALLER_USER_SHARE_BUG_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $STEAM_INSTALLER_USER_SHARE_BUG_FOLDER existe !\n"; fi
	STEAM_INSTALLER_USER_SHARE_BUG_FOLDER_FOUND=true
	TAILLE_STEAM_INSTALLER_USER_SHARE_BUG_FOLDER=$(du -sh "$STEAM_INSTALLER_USER_SHARE_BUG_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $STEAM_INSTALLER_USER_SHARE_BUG_FOLDER n'existe pas !\n"; fi
	STEAM_INSTALLER_USER_SHARE_BUG_FOLDER_FOUND=false
fi

# Contrôle de fichier
if Recherche_fichier $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier local $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH est présent à côté du script dans le dossier $BASH_CONFIG_ADDITIONNAL_FILES_FOLDER !\n"; fi
	STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH_FOUND=true
	TAILLE_STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH=$(du -sh "$STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier local $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH n'est pas présent à côté du script dans le dossier $BASH_CONFIG_ADDITIONNAL_FILES_FOLDER !\n"; fi
	STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH_FOUND=false
fi



# Contrôle de la présence de l architecture i386 (détection uniquement, pas l installation)
echo -e "Contrôle de la présence de l'architecture i386, nécessaire pour Steam :\n"

if dpkg --print-foreign-architectures | grep -q i386; then
	echo -e "✅ L'architecture i386 a été détectée !\n"

	# Affichage de la réponse
        dpkg --print-foreign-architectures

	echo -e ""

        echo -e "Affichage des apt liés à Steam dans la liste des apt du système :\n"

        apt list --installed 2>/dev/null | grep steam

	echo -e ""
else
        echo -e "❌ L'architecture i386 n'a pas été détectée !\n"

fi

# Contrôle de la présence du Steam-Launcher
# Affichage des informations de version de l'application Steam-launcher
# Test de présence d'un paquet dpkg, sans affichage console, en contrôlant le résultat $?
dpkg -l steam &>/dev/null

echo -e ""

# Si le statut d'errer du résultat de la fonction dpkg -l steam est = 0, le paquet est trouvé
if [ $? -eq 0 ] ; then
	echo -e ""

        echo -e "✅ Le Steam a été trouvé dans dpkg (fichier /var/lib/dpkg/status) !\n"

	echo -e "Informations sur la version de Steam trouvé dans dpkg :\n"

        dpkg -l steam

	echo -e ""
else
        echo -e "❌ Le Steam n'a pas été trouvé dans dpkg (fichier /var/lib/dpkg/status) !\n"
fi

# Test de présence d'un paquet dpkg, sans affichage console, en contrôlant le résultat $?
dpkg -l steam-launcher &>/dev/null

echo -e ""

# Affichage des informations de version de l'application Steam-launcher
if [ $? -eq 0 ] ; then
	echo -e ""

        echo -e "✅ Le Steam launcher a été trouvé dans dpkg (fichier /var/lib/dpkg/status) !\n"

	echo -e "Informations sur la version du Steam-launcher trouvé dans dpkg :\n"

        dpkg -l steam-launcher

	echo -e ""
else
        echo -e "❌ Le Steam-launcher n'a pas été trouvé dans dpkg (fichier /var/lib/dpkg/status) !\n"
fi

if dpkg -l steam-installer &>/dev/null; then
	echo -e "Le Steam-Installer est déja installé !\n"
	
	echo -e "Informations sur la version du Steam-Installer déja présent :\n"
	
        dpkg -l steam-launcher

	echo -e ""	
else
        echo -e "❌ Le 'steam-installer' n'a pas été trouvé dans dpkg (fichier /var/lib/dpkg/status) !\n"
fi




declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STEAM_USR_LIB_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_STEAM_USR_LIB_FOLDER
tableau[$tab_ind,chemin]=$STEAM_USR_LIB_FOLDER
tableau[$tab_ind,commentaires]="Dossier des librairies Steam"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STEAM_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_STEAM_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$STEAM_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]="Dossier contenant le 'subscriber agreement' et le readme"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STEAM_TMP_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_STEAM_TMP_FOLDER
tableau[$tab_ind,chemin]=$STEAM_TMP_FOLDER
tableau[$tab_ind,commentaires]="Dossier des fichiers temporaires"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STEAM_INSTALLER_SHARE_DOC_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_STEAM_INSTALLER_SHARE_DOC_FOLDER
tableau[$tab_ind,chemin]=$STEAM_INSTALLER_SHARE_DOC_FOLDER
tableau[$tab_ind,commentaires]="Documentations"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STEAM_HOME_USER_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_STEAM_HOME_USER_FOLDER
tableau[$tab_ind,chemin]=$STEAM_HOME_USER_FOLDER
tableau[$tab_ind,commentaires]="Dossier utilisateur cache"

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$STEAM_INSTALLER_USER_SHARE_BUG_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_STEAM_INSTALLER_USER_SHARE_BUG_FOLDER
tableau[$tab_ind,chemin]=$STEAM_INSTALLER_USER_SHARE_BUG_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi


TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"



for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""


# Installation de Steam selon le type demandé (APT, snap, flatpak, deb)
case $TXT_SETUP_TYPE in
        $TXT_SETUP_TYPE_APT)
		### Gestion des résultats sur les fichiers / dossiers trouvés
		if $STEAM_INSTALLER_USER_SHARE_BUG_FOLDER_FOUND && ! $STEAM_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "✅ L'application Steam-Installer est déja installée !\n"
			
			echo -e "Informations sur la version de Steam-Installer détecté :\n"

			apt list --installed 2>/dev/null | grep steam-installer
			
			echo -e ""
		fi

		if ! $STEAM_INSTALLER_USER_SHARE_BUG_FOLDER_FOUND && ! $STEAM_INSTALLER_SHARE_DOC_FOLDER_FOUND ; then
			echo -e "❌ Aucun des dossiers recherchés n'a été trouvés !\n"

			echo -e "Début de la procédure d'installation via $TXT_SETUP_TYPE\n"

			echo -e "Contrôle de la présence de l'architecture i386, nécessaire pour Steam :\n"

			# Contrôle de la présence de l'architecture i386
			if dpkg --print-foreign-architectures | grep -q i386; then
				echo -e "✅ L'architecture i386 a été détectée !\n"

				dpkg --print-foreign-architectures

				echo -e ""

				echo -e "Affichage des apt liés à Steam dans la liste des apt du système :\n"

				apt list --installed 2>/dev/null | grep steam
						
				echo -e ""
			else
				echo -e "❌ L'architecture i386 n'a pas été détectée !\n"

				# Ajout de l'architecture i386
				echo -e "Ajout de l'architecture i386 nécessaire avant l'installation de steam\n"

				sudo dpkg --add-architecture i386
					        
				echo -e ""

				sudo apt update
			fi

			# Affichage des informations de version de l'application Steam-launcher
			if [ dpkg -l steam-launcher &>/dev/null ] ; then
				echo -e "✅ Le steam launcher a été trouvé dans dpkg1 !\n"

				dpkg -l steam-launcher
						
				echo -e ""
			else
				echo -e "❌ Le Steam-launcher n'a pas été trouvé dans dpkg !\n"
						
				echo -e "Début de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT :\n"
						
				echo -e "Installation de Steam-launcher (installation recommandée) en cours :\n"
						
				sudo apt -y install steam-installer
						
				echo -e ""
						
				echo -e "Fin de l'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE_APT !\n"
			fi
		fi
        ;;
        # APT - Fin setup type APT

        $TXT_SETUP_TYPE_DEB)
	        echo -e "Début de la procédure d'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE :\n"
	        
	        if ! $STEAM_USR_LIB_FOLDER_FOUND; then
			echo -e "Contrôle de la présence de l'architecture i386, nécessaire pour Steam :\n"

		        # Contrôle de la présence de l'architecture i386
		        if dpkg --print-foreign-architectures | grep -q i386; then
		                echo -e "✅ L'architecture i386 a été détectée !\n"

		                dpkg --print-foreign-architectures
		        else
		                echo -e "❌ L'architecture i386 n'a pas été détectée !\n"

		                # Ajout de l'architecture i386
		                echo -e "Ajout de l'architecture i386 nécessaire avant l'installation de steam\n"

		                sudo dpkg --add-architecture i386

				sudo apt update
		        fi
		        
		        if [ -f $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH ]; then
		        	echo -e "✅ Le fichier local $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH est présent à côté du script dans le dossier $BASH_CONFIG_ADDITIONNAL_FILES_FOLDER !\n"
		        	
		        	echo -e "Début de l'installation du fichier $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH via 'dpkg -i' :\n"
		        	
		        	echo -e "Début de l'installation des dépendances :"
		        	
		        	echo -e "Début de l'installation de 'curl' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get install curl
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'curl' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'libutempter0 qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get install libutempter0
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libutempter0' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'xbitmaps qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get install xbitmaps
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'xbitmaps' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'xterm' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get install xterm
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'xterm' qui est une dépendance de 'steam-launcher' !\n"		        	
		        	
		        	# Début des dépendances 32 bits
		        	
		        	echo -e "Début de l'installation de 'libc6-i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get install libc6-i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libc6-i386' qui est une dépendance de 'steam-launcher' !\n"                	

		        	echo -e "Début de l'installation de 'libegl1:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get -y install libegl1:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libegl1:i386' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'libgbm1:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get install libgbm1:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libgbm1:i386' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'libgl1-mesa-dri:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get -y install libgl1-mesa-dri:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libgl1-mesa-dri:i386' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'libgl1:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get -y install libgl1:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libgl1:i386' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'libgl1:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get -y install libgl1:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libgl1:i386' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'steam-libs-i386:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt-get -y install steam-libs-i386:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'steam-libs-i386:i386' qui est une dépendance de 'steam-launcher' !\n"  		        
	        	
		        	# Fin des dépendances 32 bits
		        	
		        	# Début des dépendances 64 bits
		        	
		        	echo -e "Début de l'installation de 'steam-libs-amd64:amd64' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt -y install steam-libs-amd64:amd64
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'steam-libs-amd64:amd64' qui est une dépendance de 'steam-launcher' !\n"    		        	

		        	echo -e "Début de l'installation de 'libglx-mesa0:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt -y install libglx-mesa0:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libglx-mesa0:i386' qui est une dépendance de 'steam-launcher' !\n"   

		        	echo -e "Début de l'installation de 'mesa-vulkan-drivers:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt -y install mesa-vulkan-drivers:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'mesa-vulkan-drivers:i386' qui est une dépendance de 'steam-launcher' !\n"    

		        	echo -e "Début de l'installation de 'libgl1-mesa-dri:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt -y install libgl1-mesa-dri:i386
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libgl1-mesa-dri:i386' qui est une dépendance de 'steam-launcher' !\n"    		        	
		        	
		        	# Fin des dépendances 64 bits
		        	
		        	# Début des dépendances Ubuntu manquantes (qui apparaissent dans l'icone d'update en haut à droite
		        	
		        	echo -e "Début de l'installation de 'steam-libs-i386:i386' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt -y install steam-libs-i386:i386
		        	
		        	echo -e ""
		        	
		        	sudo apt update
		        	
		        	sudo apt -y full-upgrade
		        	
		        	echo -e "Fin de l'installation de 'steam-libs-i386:i386' qui est une dépendance de 'steam-launcher' !\n"			        	
		        	
		        	echo -e "Début de l'installation de 'libinput-bin' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt -y install libinput-bin
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libinput-bin' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	echo -e "Début de l'installation de 'libinput10' qui est une dépendance de 'steam-launcher' :\n"
		        	
		        	sudo apt -y install libinput10
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation de 'libinput10' qui est une dépendance de 'steam-launcher' !\n"
		        	
		        	
		        	
		        	echo -e "Fin de l'installation des dépendances !"
		        	
		        	echo -e "Début de l'installation du dépôt local 'steam-launcher' appelé $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH :\n"
		        	
		        	sudo dpkg -i $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH
		        	
		        	echo -e ""
		        	
		        	echo -e "Fin de l'installation du dépôt local 'steam-launcher' appelé $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH !\n"
		        	
		        	echo -e "Fin de l'installation du fichier $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH via 'dpkg -i' !\n"
		        else
		        	echo -e "❌ Le fichier local $STEAM_LAUNCHER_LATEST_STABLE_AMD64_LOCAL_DEB_FILENAME_FULLPATH n'est pas présent à côté du script dans le dossier $BASH_CONFIG_ADDITIONNAL_FILES_FOLDER !\n"
		        fi 
	        fi
	        
	        echo -e "Fin de la procédure d'installation de $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE !\n"        
        ;;
        # DEB - Fin setup type DEB

        *)
                echo -e "❌ Le type d'installation TXT_SETUP_TYPE n'a pas été défini dans le code !\n"

		echo -e "❌ Aucune installation n'a été effectuée !\n"
        ;;
        # Default case - Fin setup type Default
esac





echo -e "Quelques informations supplémentaires sur steam : \n"

echo -e "Site officiel de Steam : 						https://store.steampowered.com/about/download"
echo -e "Lien direct du dernier dépôt installer steam (fichier .deb) : 		https://cdn.fastly.steamstatic.com/client/installer/steam.deb"
echo -e "Lien de la page ubuntu.fr sur steam : 					https://doc.ubuntu-fr.org/steam\n"

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation de la plateforme de jeu $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## STEAM ####################################
fi # if $INSTALL_STEAM; then


############################### JEUX (FIN) ###############################


############################### SCAN ###############################
if $SCAN_PYTHON_INFOS;then
############################## PYTHON INFOS ####################################
echo -e $TEXT_BLUE
echo "PYTHON INFORMATIONS - Scan et affichage des informations de version de python, python pip..."
echo -e $TEXT_RESET

echo -e "Affichage des paquets dpkg nvidia installés via la commande 'dpkg -l | grep -i python3' :\n"

if dpkg -l | grep -i python3 >/dev/null 2>&1; then
	echo -e "✅ Des paquets 'python3' sont installés !\n"

	echo -e "Liste des paquets installés de 'python3' :\n\n"
	
	dpkg -l | grep -i python3
	
	echo -e ""
else
	echo -e "❌ La commande 'dpkg -l | grep -i nvidia' ne répond pas !"
fi

echo -e "Affichage de la version de python installé via la commande 'python3 --version' :\n"

python3 --version

echo -e ""

echo -e "Affichage de la version de python pip installé via la commande 'python3 -m pip --version' :\n"

# python3 -m pip --version

if python3 -m pip --version >/dev/null 2>&1; then
	echo -e "✅ Le pip python est installé !\n"
	
	python3 -m pip --version
	
	echo -e ""
else
	echo -e "❌ Le pip python n'est pas installé ! La commande 'python3 -m pip --version' ne répond pas !"
fi

echo -e ""



echo -e $TEXT_BLUE
echo "PYTHON INFORMATIONS - Fin du scan et affichage des informations de version de python, python pip, cuda version..."
echo -e $TEXT_RESET
############################## PYTHON INFOS (FIN) ####################################
fi

if $SCAN_NVIDIA_INFOS;then
############################## PYTHON INFOS ####################################
echo -e $TEXT_BLUE
echo "NVIDIA INFORMATIONS - Scan et affichage des informations de version de nvidia driver, cuda version..."
echo -e $TEXT_RESET

echo -e "Affichage des paquets dpkg nvidia installés via la commande 'dpkg -l | grep -i nvidia' :\n"

if dpkg -l | grep -i nvidia >/dev/null 2>&1; then
	echo -e "✅ Des paquets 'nvidia' sont installés !\n"

	echo -e "Liste des paquets 'nvidia' installés :\n"
	
	dpkg -l | grep -i nvidia
	
	echo -e ""
else
	echo -e "❌ La commande 'dpkg -l | grep -i nvidia' ne répond pas !"
fi

echo -e "Affichage de la version de 'Nvidia CUDA' installé via la commande 'nvidia-smi' :\n"

if nvidia-smi >/dev/null 2>&1; then
	nvidia-smi
	
	echo -e ""
else
	echo -e "❌ La commande 'nvidia-smi' ne répond pas !"
fi

echo -e $TEXT_BLUE
echo "NVIDIA INFORMATIONS - Fin du scan et affichage des informations de version de python, python pip, cuda version..."
echo -e $TEXT_RESET
############################## PYTHON INFOS (FIN) ####################################
fi

############################### SCAN (FIN) ###############################

if $INSTALL_TEMPLATE || $INSTALL_ALL; then
############################## MODELE ####################################
#################

# Nom texte de l application à installer, pour l affichage terminal
TXT_APP_TO_INSTALL="Template_appname"

# Type d installation (APT, Flatpak, snap, dpkg)
TXT_SETUP_TYPE=$TXT_SETUP_TYPE_APT

# Options d'analyse
SHOW_ANALYSE_LINES=false

echo -e $TEXT_BLUE
echo -e "${TXT_APP_TO_INSTALL^^} - Installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

# Chemin des fichier(s) et/ou dossier(s) pour contrôler leur présence
APPNAME_USR_BIN_FILENAME="/usr/bin/app_bin_template"
APPNAME_USR_SHARE_FOLDER="/usr/share/app_template"
# Booléens associés
APPNAME_USR_BIN_FILENAME_FOUND=false
APPNAME_USR_SHARE_FOLDER_FOUND=false
# Tailles (nécessaire si fichier et/ou dossier absent)
TAILLE_APPNAME_USR_BIN_FILENAME=""
TAILLE_APPNAME_USR_SHARE_FOLDER=""


# Contrôle de fichier
if Recherche_fichier $APPNAME_USR_BIN_FILENAME; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le fichier $APPNAME_USR_BIN_FILENAME existe !\n"; fi
	APPNAME_USR_BIN_FILENAME_FOUND=true
	TAILLE_APPNAME_USR_BIN_FILENAME=$(du -sh "$APPNAME_USR_BIN_FILENAME" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le fichier $APPNAME_USR_BIN_FILENAME n'existe pas !\n"; fi
	APPNAME_USR_BIN_FILENAME_FOUND=false
fi

# Contrôle du dossier 
if Recherche_dossier $APPNAME_USR_SHARE_FOLDER; then
	if $SHOW_ANALYSE_LINES; then echo -e "✅ Le dossier $APPNAME_USR_SHARE_FOLDER existe !\n"; fi
	APPNAME_USR_SHARE_FOLDER_FOUND=true
	TAILLE_APPNAME_USR_SHARE_FOLDER=$(du -sh "$APPNAME_USR_SHARE_FOLDER" | cut -f1)
else
	if $SHOW_ANALYSE_LINES; then echo -e "❌ Le dossier $APPNAME_USR_SHARE_FOLDER n'existe pas !\n"; fi
	APPNAME_USR_SHARE_FOLDER_FOUND=false
fi


declare -A tableau

# Simuler un tableau de 2 "dictionnaires"
typeset -i tab_ind=0

tab_ind=0
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$APPNAME_USR_BIN_FILENAME_FOUND
tableau[$tab_ind,taille]=$TAILLE_APPNAME_USR_BIN_FILENAME
tableau[$tab_ind,chemin]=$APPNAME_USR_BIN_FILENAME
tableau[$tab_ind,commentaires]=""

# Incrémentation de l'indice de ligne
tab_ind=$tab_ind+1

# Définition et init de la ligne
tableau[$tab_ind,apt]="  X"
tableau[$tab_ind,snap]=""
tableau[$tab_ind,flatpak]=""
tableau[$tab_ind,existe]=$APPNAME_USR_SHARE_FOLDER_FOUND
tableau[$tab_ind,taille]=$TAILLE_APPNAME_USR_SHARE_FOLDER
tableau[$tab_ind,chemin]=$APPNAME_USR_SHARE_FOLDER
tableau[$tab_ind,commentaires]=""

if $SHOW_ANALYSE_LINES; then echo "Nombre d'éléments : ${#tableau[@]}"; fi

# Récupération de l'indice max 'tab_ind' (1ère valeur du tableau, qui correspond au numéro de ligne
i_max=$tab_ind

if $SHOW_ANALYSE_LINES; then echo -e "Indice max de ligne dans le tableau des résultats des fichiers et/ou dossiers recherchés : $i_max"; fi

TABLEAU_COMMENTAIRES_SIZE_PLUS_1=$(expr $TABLEAU_COMMENTAIRES_SIZE + 1)

echo -e "Affichage des résultats des fichiers et/ou dossiers recherchés :"
printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"
printf "|%-17s|%-${TAB_EXISTE_TAILLE_CHEMIN_WIDTH_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" "  F&D attendus" "$TAB_TITLE_F_ET_D_RECHERCHES" "$TABLEAU_INFORMATIONS_SUPPLEMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"
printf "|%-5s|%-5s|%-5s|%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s|%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|%-${TABLEAU_COMMENTAIRES_SIZE}s|\n" " APT" " SNA" " FLA" " Existe" " Taille" "$TAB_SUBTITLE_CHEMIN" "$TABLEAU_COMMENTAIRES_WITH_SPACES"
printf "$TABLEAU_BORDER_SUBTITLE_LINE_PREFIX" "$TABLEAU_BORDER_SUBTITLE_LINE_1_3" "$TABLEAU_BORDER_SUBTITLE_LINE_2_3" "$TABLEAU_BORDER_SUBTITLE_LINE_3_3"

for ((i=0; i<=i_max; i++)); do
		printf "|%-5s|%-5s|%-5s|" "${tableau["$i,apt"]}" "${tableau["$i,snap"]}" "${tableau["$i,flatpak"]}"
		
		if ${tableau["$i,existe"]}; then
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;32m" "  ${tableau["$i,existe"]}" "\033[0m"
		else
			printf "%b%-${TAB_SUBTITLE_EXISTE_COL_SIZE}s%b|" "\033[0;31m" "  ${tableau["$i,existe"]}" "\033[0m"
		fi
		
		printf "%-${TAB_SUBTITLE_TAILLE_COL_SIZE}s|" "  ${tableau["$i,taille"]}"
		
		printf "%-${TAB_SUBTITLE_CHEMIN_COL_SIZE}s|" " ${tableau["$i,chemin"]}"
		
		printf " %-${TABLEAU_COMMENTAIRES_SIZE_MOINS_1}s|\n" "${tableau["$i,commentaires"]}"
done

printf "$TABLEAU_BORDER_FIRST_LINE_PREFIX" "$TABLEAU_BORDER_FIRST_LINE_1_3" "$TABLEAU_BORDER_FIRST_LINE_2_3"  "$TABLEAU_BORDER_FIRST_LINE_3_3"

echo -e ""






case $TXT_SETUP_TYPE in
	$TXT_SETUP_TYPE_APT)
		# Si tous les fichiers et/ou dossiers recherchés ont été trouvés
		if $APPNAME_USR_BIN_FILENAME_FOUND && $APPNAME_USR_SHARE_FOLDER_FOUND; then
			echo -e "L'application $TXT_APP_TO_INSTALL est déja installée !\n"

			# sudo dpkg -i Setup.deb
		fi

		# S'il manque un ou plusieurs fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND || ! $APPNAME_USR_SHARE_FOLDER_FOUND ; then
			echo -e "L'application $TXT_APP_TO_INSTALL n'est pas correctement installée !\n"
		fi

		# S'il manque tous les fichiers et/ou dossiers recherchés
		if ! $APPNAME_USR_BIN_FILENAME_FOUND && ! $APPNAME_USR_SHARE_FOLDER_FOUND ; then
			echo -e "Installation de l'application $TXT_APP_TON_INSTALL"
			# yes "" | sudo apt install -y gnome-sudoku
		fi	
	;;
	
	$TXT_SETUP_TYPE_FLATPAK)
	
	;;

	$TXT_SETUP_TYPE_SNAP)
	
	;;

	*)
	
	;;
esac

echo -e $TEXT_YELLOW
echo -e "${TXT_APP_TO_INSTALL^^} - Fin de l'installation du logiciel $TXT_APP_TO_INSTALL via $TXT_SETUP_TYPE"
echo -e $TEXT_RESET

#################
############################## MODELE (FIN) #################################### 
fi # if $INSTALL_TEMPLATE || $INSTALL_ALL; then

# Récupération de la liste acutelle des apps épinglées et rajoute les applis renseignées --> Marche dans un terminal, mais pas à la fin de ce script
# sudo gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/\\]$/,'org.wireshark.Wireshark.desktop']/")"
# sudo gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/\\]$/,'org.gnome.DiskUtility.desktop']/")"

# Marche pas 
# gsettings set org.gnome.shell favorite-apps "['org.wireshark.Wireshark.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.gedit.desktop']"



################# INSTALLATION DES LOGICIELS (FIN) ########################

echo -e "Fin du script d'installation des applications courantes pour Ubuntu version $BASH_UBUNTU_25_10_CONFIGURATION_VERSION_SCRIPT daté du $BASH_UBUNTU_25_10_CONFIGURATION_DATE_SCRIPT !\n"

echo -e "💡 Liste des dépôts Ubuntu (.deb) sur le site d'archives Ubuntu						● https://fr.archive.ubuntu.com/ubuntu/pool/multiverse/"
echo -e "💡 Pour rechercher un paquet sur le site internet							● https://packages.ubuntu.com/\n"

# Capture du temps de fin et calcul
TIMER_SCRIPT_END=$(date +%s%3N)
TIMER_SCRIPT_DURATION_MS=$((TIMER_SCRIPT_END - TIMER_SCRIPT_START))

echo -e "Durée totale du script d'installation des applications courantes pour Ubuntu (26.04.1 / 25.10 / 24.04) : $TIMER_SCRIPT_DURATION_MS ms\n"



#######################################

#!/bin/bash



