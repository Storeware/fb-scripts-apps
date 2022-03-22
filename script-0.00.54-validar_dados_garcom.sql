set term ^;
execute block
as
declare variable conta integer;
declare variable result varchar(200);
begin
 -- checa se existe mesa cadastrada
select count(*) from PRODUCAO_MESA into :conta;
executeIf_not_exists(:conta, 'insert into PRODUCAO_MESA (codigo, filial) values (1,1)');

select count(*) from comandas into :conta;
executeIf_not_exists(:conta,"insert comanda (comanda) values('1')");



end^
set term ;^