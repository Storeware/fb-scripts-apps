
    


grant select on wba_formpgto to publicweb;
grant select on WBA_FP_MEIO to publicweb;


grant select on fechacx to publicweb;
grant select, insert,update on sigbco_saldos to publicweb;
grant select, insert, update, delete on sigcx_resumo to publicweb;
grant execute on procedure FIMMES to publicweb;

grant select,update, insert on sigcx to publicweb;
grant select, insert, update on sigflu to publicweb;

grant select,insert,update on sigbco to publicweb;
grant select,insert, update on sig01 to publicweb;

grant select,insert,update,delete on SIGCX_TOTAL_DIA to publicweb  ;

/*
-- reconstruir os saldos
insert into SIGBCO_SALDOS
  select banco,sum(case when codigo<'200' then  valor else -valor end),'now' from sigcx group by banco
  */



SET TERM ^ ;

CREATE or alter TRIGGER tr_sigcx_saldos FOR SIGCX
ACTIVE before INSERT OR UPDATE OR DELETE POSITION 0
AS 
declare variable fator integer;
declare variable saldoant double precision;
BEGIN 
	/* enter trigger code here */
	if (inserting or updating) then 
	begin
	/* enter trigger code here */ 
	   new.HIST_ = coalesce(new.hist_,substring(new.historico from 1 for 34 ));
	   new.data_ = coalesce(new.data_,new.data);
	   new.prtserie = coalesce(new.prtserie,'DB');
	   new.registrado = coalesce(new.registrado,'N');
	   new.dctook = coalesce(new.dctook,'N');
   	   new.COMPENSADO = coalesce(new.COMPENSADO,'N');
	   new.ordem = coalesce(new.ordem,1);
	   select valor from sigbco_saldos 
	   where codigo = new.codigo
	   into :saldoant;
	   new.SALDOANT = coalesce(:saldoant,0); 
    end

	if (updating or deleting) then
	begin
	  fator = case when new.codigo<200 then -1 else 1 end;
	  in autonomous TRANSACTION do
	    update sigbco_saldos
	      set dtatualiz = 'now', valor= valor+ (old.valor * :fator)
	      where codigo = old.banco; 
	
	end

	if (inserting or updating) then
	begin
	  fator = case when new.codigo<200 then 1 else -1 end;
	  in autonomous TRANSACTION do
	  update sigbco_saldos
	    set dtatualiz = 'now', valor= valor+ (new.valor * :fator)
	    where codigo = new.banco; 
	  if (row_count =0) then
	  in autonomous TRANSACTION do
	    insert into sigbco_saldos
	     (codigo,valor,dtatualiz)
	     values
	     (new.banco,new.valor*:fator,'now'); 
	end
	
	
END^

SET TERM ; ^ 



/* monta saldos diarios de caixa */
SET TERM ^ ;

CREATE or alter TRIGGER tr_sigcx_saldos_diario FOR SIGCX
ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 0
AS 
declare variable entrada double precision;
declare variable saida double precision;
BEGIN 
    entrada = 0;
    saida = 0;
	/* estorna o valor antigo */ 
	if ( updating or deleting) then 
	begin
	  if (old.codigo>='200') then
	     saida = - old.valor;
	  else
	     entrada = - old.valor;   
	  update sigcx_total_dia
	     set entradas = entradas + :entrada,
	         saidas = saidas + :saida
	  where banco = old.BANCO
	        and data = old.data;          
	end
	
	/* incluir o valor novo */ 
	if (inserting or updating ) then 
	begin
	
	  if (old.codigo>='200') then
	     saida =  new.valor;
	  else
	     entrada =  new.valor;   
	  update sigcx_total_dia
	     set entradas = entradas + :entrada,
	         saidas = saidas + :saida
	  where banco = new.BANCO
	        and data = new.data;    
	        
	        
	  if (row_count=0) then
	    insert into sigcx_total_dia
	      (banco,data,entradas,saidas)
	    values
	      (new.banco,new.data,:entrada,:saida);
	                  
	end
	
	
	
END^

SET TERM ; ^ 

Commit work;


SET TERM ^ ;
CREATE OR ALTER PROCEDURE SP_SIGBCO_SALDO
 (P_BANCO VARCHAR(10),P_DATA timestamp)
RETURNS (
	BANCO Varchar(15),
	DATA timestamp,
	ANTERIOR DOUBLE PRECISION,
	ENTRADAS Numeric(15,2),
	SAIDAS Numeric(15,2),
	FINAL DOUBLE PRECISION
	)
AS
BEGIN
   SELECT SIGBCO.SALDOANT FROM SIGBCO WHERE CODIGO = :P_BANCO
   INTO :ANTERIOR;
   BANCO = :P_BANCO;
   DATA = :P_DATA;

	SELECT  SUM(a.ENTRADAS) , SUM(a.SAIDAS)
	    FROM SIGCX_TOTAL_DIA a
	    WHERE BANCO = :P_BANCO AND DATA <=:P_DATA
	    INTO  :ENTRADAS, :SAIDAS;
	ENTRADAS = COALESCE(ENTRADAS,0);
	SAIDAS = COALESCE(SAIDAS,0);
    FINAL = COALESCE(:ANTERIOR,0) + COALESCE(:ENTRADAS,0) - COALESCE(:SAIDAS,0);
	SUSPEND;

END^
SET TERM ; ^


GRANT EXECUTE ON PROCEDURE SP_SIGBCO_SALDO TO PUBLICWEB;
GRANT EXECUTE ON PROCEDURE SP_SIGBCO_SALDO TO WBA;

GRANT SELECT ON SIGBCO TO PROCEDURE SP_SIGBCO_SALDO;
GRANT SELECT, INSERT, UPDATE ON SIGCX_TOTAL_DIA TO PROCEDURE SP_SIGBCO_SALDO;

COMMIT WORK;

--SELECT * FROM SP_SIGBCO_SALDO('01','TODAY');


SET TERM ^ ;
CREATE or alter PROCEDURE SIGCX_TOTAL_DIA_recriar
RETURNS (conta int)
as
declare variable	BANCO Varchar(15);
declare variable	DATA timestamp;
declare variable	ENTRADAS Numeric(15,2);
declare variable	SAIDAS Numeric(15,2);

BEGIN
    conta = 0;
    in autonomous transaction do
       delete from SIGCX_TOTAL_DIA;
       
	FOR SELECT a.BANCO, a.DATA, sum(case when codigo <'200' then valor else 0 end) entradas , 
	   sum( case when codigo<'200' then 0 else valor end ) SAIDAS
	    FROM sigcx a
	    group by a.banco,a.data
	    INTO :BANCO, :DATA, :ENTRADAS, :SAIDAS
	DO
	BEGIN
       in autonomous transaction do
		insert into SIGCX_TOTAL_DIA
		  (banco,data,entradas,saidas)
		values
		  (:banco,:data,:entradas,:saidas);  
		conta = conta + row_count;  
	END
	SUSPEND;
END^
SET TERM ; ^


--execute procedure SIGCX_TOTAL_DIA_recriar;
COMMIT WORK;

COMMIT WORK;


SET TERM ^ ;
create or ALTER PROCEDURE SP_SIGBCO_EXTRATO (
    P_BANCO Varchar(10),
    P_DATA_DE timestamp,
    P_DATA_ATE timestamp )
RETURNS (
    BANCO Varchar(10),
    ID Float,
    CODIGO Varchar(10),
    ORDEM Integer,
    DATA timestamp,
    DCTO Varchar(15),
    FILIAL Float,
    CLIFOR Float,
    HISTORICO Varchar(50),
    VALOR numeric(15,2) )
AS
DECLARE VARIABLE SALDO numeric(15,2);

BEGIN
  BANCO = :P_BANCO;
  SELECT COALESCE(FINAL,0) FROM SP_SIGBCO_SALDO(:P_BANCO,:P_DATA_DE-1)
  INTO :SALDO;
  DATA = :P_DATA_DE;
  HISTORICO = 'SALDO ANTERIOR';
  FILIAL = 0;
  VALOR = SALDO;
  ID = 0;
  ORDEM = 0;
  CLIFOR = 0;
  DCTO = 'SDO';
  CODIGO = '';
  SUSPEND;
  FOR SELECT DATA,HISTORICO,FILIAL,VALOR,ID,ORDEM,CLIFOR,DCTO,CODIGO FROM SIGCX 
  WHERE BANCO = :P_BANCO AND DATA BETWEEN :P_DATA_DE AND :P_DATA_ATE
  INTO :DATA,:HISTORICO,:FILIAL,:VALOR,:ID,:ORDEM,:CLIFOR,:DCTO,:CODIGO
  DO
  BEGIN
    SALDO = SALDO + coalesce(CASE WHEN CODIGO<'200' THEN VALOR ELSE -VALOR END,0);
    SUSPEND;
  END  
  DATA = :P_DATA_ATE;
  HISTORICO = 'SALDO';
  FILIAL = 0;
  VALOR = SALDO;
  ID = 0;
  ORDEM = 0;
  CLIFOR = 0;
  DCTO = 'SDO';
  CODIGO = '';
  SUSPEND;
END^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE SP_SIGBCO_EXTRATO TO  PUBLICWEB;

GRANT SELECT ON SIGCX TO PROCEDURE SP_SIGBCO_EXTRATO;


COMMIT WORK;



--SELECT * FROM SP_SIGBCO_EXTRATO('01',CAST('TODAY' AS DATE)-20,'TODAY');


