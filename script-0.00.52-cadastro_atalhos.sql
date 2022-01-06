
SET TERM ^ ;

CREATE or alter TRIGGER ctprod_atalhos_itens_soma_itens FOR CTPROD_ATALHO_ITENS
ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 1
AS 

declare variable mudou boolean;
declare variable qtde double precision;
BEGIN 
    mudou = deleting or inserting;
	--if (updating ) then
	--  mudou = mudou or (old.codtitulo<>new.codtitulo);

  in autonomous transaction do
  begin
   --if (mudou and (updating or deleting)) then
   -- begin
   --   update  CTPROD_ATALHO_TITULO set conta = coalesce(conta-1,0)
   --      where codigo = old.CODTITULO;     	     
   --      
   -- end  
  	    
    --if (mudou and (inserting or updating)) then
    --begin
      update  CTPROD_ATALHO_TITULO set conta = coalesce( (select count(*) from CTPROD_ATALHO_ITENS where codtitulo = new.CODTITULO),0)
         where codigo = new.CODTITULO;     	     

    --end     
  end     
	
END^

SET TERM ; ^ 

update CTPROD_ATALHO_ITENS set codtitulo = codtitulo;
commit work;
select '08 - Completado' from dummy;
