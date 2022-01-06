/*create table ctprodsd_consignado
  (codigo varchar(18) not null,
   clifor double precision not null,
   qtde double precision,
   primary key( codigo,clifor )
  ) 
;
alter table ctprodsd_consignado add dtatualiz date;
*/

grant select on ctprodsd_consignado to publicweb; 

SET TERM ^ ;

CREATE or alter TRIGGER tr_estmvto_somaconsig FOR ESTMVTO
ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 0
AS 
declare variable somaconsig int;
declare variable fator int;
BEGIN 
  somaconsig = 1;
   
   
  if (updating and old.operacao=new.operacao and old.codigo=new.codigo and old.clifor=new.clifor and old.qtde=new.qtde) then
  begin
    somaconsig = 0;
  end 

  if (somaconsig=1) then
  begin
	/* enter trigger code here */ 
    if ((updating or deleting) and (old.clifor >0) ) then
    begin
      select somaconsig from estoper
      where codigo=old.OPERACAO
      into :somaconsig;
      -- estorno
      fator = case when old.operacao<'200' then -1 else 1 end;
      if (somaconsig=1) then
        update ctprodsd_consignado  set  qtde = qtde + (old.qtde * :fator   ), dtatualiz = 'now'
        where codigo = old.codigo and clifor = old.clifor;
    
    end
    
	if ((inserting or updating) and (new.clifor >0)) then
	begin
	  -- lancar
      select somaconsig from estoper
      where codigo=new.OPERACAO
      into :somaconsig;
      -- estorno
      fator = case when new.operacao<'200' then 1 else -1 end;
      if (somaconsig=1) then
      begin
        update ctprodsd_consignado  set  qtde = qtde + (new.qtde * :fator   )
        where codigo = new.codigo and clifor = new.clifor;
        if (ROW_COUNT=0) then
           insert into ctprodsd_consignado (codigo,clifor,qtde, dtatualiz)
                    values(new.codigo,new.clifor,new.qtde*:fator,'now');
      end  
	
	end
  end	
END^

SET TERM ; ^ 

commit work;

--select * from ctprodsd_consignado
