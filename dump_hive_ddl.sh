#!/bin/bash
JDBC_URL="jdbc:hive2://master2:10000"
DB_NAME=$1".hql"
rm -f tableNames.txt
rm -f $DB_NAME
beeline -u $JDBC_URL --showHeader=false --outputformat=tsv2 -e "use $1; show tables;" > tableNames.txt
#hive -e "use $1; show tables;" > tableNames.txt  
wait
echo -e "create database if not exists $1; use $1;" >>$DB_NAME
cat tableNames.txt |while read LINE
   do
   echo -e "drop table if exists $LINE;\n" >>$DB_NAME
   beeline -u $JDBC_URL --showHeader=false --outputformat=tsv2 -e "use $1; show create table $LINE;" | sed "s/\"/\\\\\"/g" >>$DB_NAME
   echo -e ";\n" >>$DB_NAME
   done
rm -f tableNames.txt
echo "Table DDL generated"

