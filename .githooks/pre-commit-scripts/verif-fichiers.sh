#!/bin/bash;D:/tools/shell/bash.exe

#recup du repertoire du projet git
DIR_PROJET_GIT_LINUXPATH="$(git rev-parse --show-toplevel)"

#recup du repertoire d'execution du script
DIR_CURRENT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR_PRECOMMIT_SCRIPTS="$DIR_CURRENT"


#flag erreur verif fichiers
#declare 


#recup des fichiers du commit
declare -a FILE_TO_CHECK
while read -r line
do
	FILE_TO_CHECK[${#FILE_TO_CHECK[@]}]="$line"
done < <(git diff --staged --name-only) #substitution process pour recuperer output 'git diff' listant fichier a commiter


#extraction noms des scripts sql
declare -a SQL_FILES
for filename in "${FILE_TO_CHECK[@]}"
do
	if echo "$filename" | grep -iq '\.sql$'
	then
		SQL_FILES[${#SQL_FILES[@]}]="$filename"
	fi
done


#verif des scripts SQL
declare WRONG_SYNTAX=0
for filename in "${SQL_FILES[@]}"
do
	#verif encodage script
	echo Appel script de vérification de l\'encodage: \["$DIR_PRECOMMIT_SCRIPTS"/verif-encodage.sh \""$filename"\"\]
	bash "$DIR_PRECOMMIT_SCRIPTS"/verif-encodage.sh "$DIR_PROJET_GIT_LINUXPATH/$filename"
	RESULT=$?
	
	if [ $RESULT -ne 0 ];
	then
		cat <<EOF
--------------------------
ERREUR: Erreur d'encodage (attendu: UTF8 sans BOM) pour "$filename"
--------------------------
EOF
		WRONG_SYNTAX=1
	fi 
	
	#verif fins de ligne
	echo Appel script de vérification des fins de ligne: \["$DIR_PRECOMMIT_SCRIPTS"/verif-EOL.sh \""$filename"\"\]
	bash "$DIR_PRECOMMIT_SCRIPTS"/verif-EOL.sh "$DIR_PROJET_GIT_LINUXPATH/$filename"
	RESULT=$?
	
	if [ $RESULT -ne 0 ];
	then
		cat <<EOF
--------------------------
ERREUR: Fins de ligne au format CR ou CRLF (attendu: LF) dans "$filename"
--------------------------
EOF
		WRONG_SYNTAX=1
	fi 

done

#rejet du commit si une erreur a ete detectee
exit $WRONG_SYNTAX
