#!/bin/bash
# arquivo de LOGs
arq_log="scripts_`date +\%Y\%m\%d`.log"
# lista de bancos para executar
declare -a bancos=(
                # "13245" 
		#           "c:\dados\store.fdb"
                 "servidor/porta:banco"
                )
usuario="SYSDBA"
senha="masterkey"
#loop bancos
for bco in "${bancos[@]}"
  do  
	  echo "$bco"
#loop scripts
  for arq_sql in ./*.sql; do
    echo $bco "$(basename "$arq_sql")"
<<<<<<< Updated upstream
    #sudo 
    ./isql.exe $bco  -u $usuario -p $senha -s 1  -o $arq_log -i $arq_sql
=======
      isql.exe $bco -u $usuario -p $senha -s 1  -o $arq_log -i $arq_sql -ch utf8
>>>>>>> Stashed changes
    echo "========================================="
  done
done