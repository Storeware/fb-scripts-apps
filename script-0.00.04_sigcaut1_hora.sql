

/* 
  passar para o store setup
*/

/*
   sigcaut1_hora utilziado paa estatisticas e dashboards
*/



GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIGCAUT1_HORA TO  TESTE WITH GRANT OPTION;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIGCAUT1_HORA TO  WBA WITH GRANT OPTION;


/* grant para APP */
GRANT  SELECT
 ON SIGCAUT1_HORA TO   publicweb ;


grant select on sigcaut2resmes to publicweb;
grant select,update,insert,delete on metas_vendas to publicweb;
grant update,insert, delete, select  on sigcaut1_hora to publicweb;

SET TERM ^ ;

CREATE or alter TRIGGER tr_sigcaut1_reg_hora FOR SIGCAUT1
ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 0
AS 
declare variable mudou boolean;
declare variable qtde double precision;
declare variable total double precision;
declare variable fator double precision;
declare variable hora varchar(8);
BEGIN 
  
  
  
  mudou = deleting or inserting;
	if (updating ) then
	  mudou = mudou or (old.data<>new.data) or (old.codigo<>new.codigo) or (new.hora<>old.hora) or
	          (old.qtde<>new.qtde)  or (old.filial<>new.filial);

  in autonomous transaction do
  begin
    if (mudou and (updating or deleting)) then
    begin
          if (old.operacao<200) then fator = 1; else fator = -1;

      select qtde,total from sigcaut1_hora 
           where codigo = old.codigo and data = old.data and filial = old.filial and hora = old.hora
      into :qtde,:total ;      
     if (qtde is not null) then
      update or insert into sigcaut1_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(old.codigo,old.data,old.filial,substr(old.hora,1,2),coalesce(:qtde,0) - old.qtde*:fator,coalesce(:total,0)+old.total*:fator, ( 
            select grupo from ctprod where codigo = old.codigo
         ) )
         matching (codigo,data,filial,hora);     	     
	end  
  	    
    if (mudou and (inserting or updating)) then
    begin
      if (new.operacao<200) then fator = 1; else fator = -1;

      select qtde,total from sigcaut1_hora 
           where codigo = new.codigo and data = new.data and filial = new.filial and hora = new.hora
      into :qtde,:total;      
      update or insert into sigcaut1_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(new.codigo,new.data,new.filial,substr(new.hora,1,2), coalesce(:qtde,0) +  new.qtde*:fator,coalesce(:total,0)+new.total*:fator,  (
         select grupo from ctprod where codigo = new.codigo
         ) )
         matching (codigo,data,filial,hora);     	     
    end     
  end     
	
END^

SET TERM ; ^ 



SET TERM ^ ;
CREATE or alter TRIGGER INSERT_SIGCAUT1 FOR SIGCAUT1 ACTIVE
BEFORE INSERT POSITION 0
as
begin

  if (new.filial is null) then
      new.filial=0;

  new.hrestado = 'now';

  if (new.estado is null) then
     new.estado=0;

  if (new.cancelado is null) then
      new.cancelado = 'N';

  if (new.cancelado='S') then
       new.baixado='S';
       
       
  if (new.hora is null) then
    select hr from ENCODEDECODETIME( new.hrestado  )
    into new.hora;     

end^
SET TERM ; ^


grant execute on procedure ENCODEDECODETIME TO publicweb;

select '04 - Completado' from dummy;

