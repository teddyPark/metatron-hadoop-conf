#!/bin/bash
JDBC_URL="jdbc:hive2://localhost:10000"
rm -f tableNames.txt
rm -f HiveTableDDL.txt
beeline -u $JDBC_URL --showHeader=false --outputformat=tsv2 -e "use $1; show tables;" > tableNames.txt
#hive -e "use $1; show tables;" > tableNames.txt  
wait
echo -e "create database if not exists $1; use $1" >>HiveTableDDL.txt
cat tableNames.txt |while read LINE
   do
   echo -e "drop table if exists $LINE;\n" >>HiveTableDDL.txt
   beeline -u $JDBC_URL --showHeader=false --outputformat=tsv2 -e "use $1; show create table $LINE;" | sed "s/\"/\\\\\"/g" >>HiveTableDDL.txt
   echo -e ";\n" >> HiveTableDDL.txt
   done
rm -f tableNames.txt
echo "Table DDL generated"

