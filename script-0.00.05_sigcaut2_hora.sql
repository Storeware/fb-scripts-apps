
/* passa a coluna para o storesetup */

SET TERM ^ ;

CREATE or alter TRIGGER SIGCAUT2_MVTO_HORA FOR SIGCAUT2
ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 0



AS 
declare variable mudou boolean;
declare variable qtde double precision;
declare variable total double precision;
declare variable fator double precision;
BEGIN 
    fator = 1;
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
      update or insert into sigcaut2_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(old.codigo,old.data,old.filial,substr(old.hora,1,2),coalesce(:qtde,0) - old.qtde*:fator,coalesce(:total,0)+old.valor*:fator, ( 
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
      update or insert into sigcaut2_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(new.codigo,new.data,new.filial,substr(new.hora,1,2), coalesce(:qtde,0) +  new.qtde*:fator,coalesce(:total,0)+new.valor*:fator,  (
         select grupo from ctprod where codigo = new.codigo
         ) )
         matching (codigo,data,filial,hora);     	     
    end     
  end     
	
END^


SET TERM ; ^


grant select on sigcaut2_hora to publicweb;
select '05 - Completado' from dummy;
