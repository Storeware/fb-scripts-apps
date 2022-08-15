#!/bin/bash
# arquivo de LOGs
arq_log="/scripts/logs/storesetup`date +\%Y\%m\%d`.log"

# lista de bancos para executar
declare -a bancos=(12345 
		store 
		teste)
usuario="SYSDBA"
senha="masterkey"

#loop bancos
for bco in "${bancos[@]}"
   do
     echo "$bco"
#loop scripts
#  for arq_sql in ./sql/storesetup/scripts-0204/*.sql; do
#   for arq_sql in ./sql/storesetup/script-9.99.99-permissoes.sql; do
 for arq_sql in ./sql/storesetup/*.sql; do 

   echo $bco "$(basename "$arq_sql")"
   sudo isql-fb $bco -u $usuario -p $senha -s 1 -i $arq_sql -o $arq_log
  done
done
