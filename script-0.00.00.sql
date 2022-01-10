
/*
  Codigos
*/
set term ^;
create or alter function exists_role( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$ROLES where rdb$ROLE_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^

create or alter function exists_table( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$RELATIONS where rdb$relation_name = upper(:name) AND RDB$VIEW_BLR IS NULL 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^

create or alter function executeIf_not_exists( condicao integer, stmt varchar(1024))
 returns varchar(1024)
as
BEGIN
  if (condicao=0) then
    execute statement :stmt;
  return null;
  when any do
  begin
     return GDSCODE ||'-'||SQLCODE;
  end  
  
end^

create or alter function exists_column( table_name varchar(128), name varchar(128))
   returns integer
as
declare variable  conta integer;
begin
    
    SELECT count(*)  FROM rdb$relation_fields  
        where rdb$relation_name = upper(:table_name) and RDB$FIELD_NAME = upper(:name)  
    into :conta;
    if (conta>0) then return 1; else return 0;
end^


create or alter function exists_indice( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$INDICES where rdb$index_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^


create or alter FUNCTION createColumn_not_exists(table_name varchar(128),column_name varchar(128),column_type varchar(128))
RETURNS VARCHAR(128)
as
BEGIN
  if (exists_column(:table_name,:column_name)=0) then
     execute statement
        'ALTER TABLE '||:TABLE_NAME||' ADD '||:COLUMN_NAME||' '||:COLUMN_TYPE||';';
  RETURN NULL;      
  when any do
  begin
     return GDSCODE ||'-'||SQLCODE;
  end  

end^

create or alter function exists_procedure( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from RDB$PROCEDURES where rdb$procedure_name = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^


create or alter function exists_primary_key( name varchar(128))
  returns integer
as
declare variable  conta integer;
begin
    select count(*) from rdb$indices ix
        left join rdb$index_segments sg on ix.rdb$index_name = sg.rdb$index_name
        left join rdb$relation_constraints rc on rc.rdb$index_name = ix.rdb$index_name
        where rc.rdb$constraint_type = 'PRIMARY KEY' AND ix.RDB$RELATION_NAME = upper(:name) 
    into :conta;
    if (conta>0) then return 1; else return 0;
end^


execute block
as 
begin
   
   if (exists_role('PUBLICWEB')=0) THEN
   begin  
     execute statement 'revoke all on all from PUBLICWEB; commit;';
           
     execute statement 
       'create role PUBLICWEB;';
   end    
   when any do 
   begin   
   
   end 
end^

set term ;^

COMMIT;

