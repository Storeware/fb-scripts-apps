rollback work;
SET TERM ^ ;

CREATE or alter PROCEDURE relatorio_fluxo_caixa 
 ( P_FILIAL float, p_data timestamp, p_ate timestamp ) 
RETURNS 
 ( id double precision, data timestamp, dcto varchar(10),ctrl_id double precision,
   codigo varchar(10),clifor double precision,
   historico varchar(50),filial float, valor double precision, saldo double precision )
AS 
--DECLARE VARIABLE variable_name < datatype>; 
declare variable anterior double precision;
declare variable entradas double precision;
declare variable saidas double precision;
declare variable fil_de double precision;
declare variable fil_ate double precision;
BEGIN
  saldo = 0;
  fil_de = :p_filial;
  fil_ate = 9999;
  if (:p_filial>0) then
     fil_ate = :p_filial;
  
   SELECT sum(coalesce(SIGBCO.SALDOANT,0)) FROM SIGBCO 
   INTO :anterior;
   data = :p_data;
   codigo = '000';
   historico = 'Saldo anterior';
   dcto='SDO';
   filial = :p_filial;
 
	SELECT  SUM(a.ENTRADAS) , SUM(a.SAIDAS)
	    FROM SIGCX_TOTAL_DIA a join sigbco b on (b.codigo=a.BANCO)
	    WHERE a.DATA <:P_DATA and 
	          b.FILIAL >= :fil_de  and b.filial <= :fil_ate
	    INTO  :ENTRADAS, :SAIDAS;
	ENTRADAS = COALESCE(ENTRADAS,0);
	SAIDAS = COALESCE(SAIDAS,0);
    SALDO = COALESCE(:ANTERIOR,0) + COALESCE(:ENTRADAS,0) - COALESCE(:SAIDAS,0);
	
    valor = :saldo;
	suspend;
  
  
  /* write your code here */ 
  for select id,data,dcto,ctrl_id,codigo,historico,filial,valor , clifor
  from sigflu
  where filial between 
               (case when :p_filial=0 then 0 else :p_filial end)  and 
               (case when :p_filial=0 then 9999 else :p_filial end) 
        and banco = ''   
        and data <= :P_ATE    
  order by data,codigo      
  into :id,:data,:dcto,:ctrl_id,:codigo,:historico,:filial,:valor , :clifor
  do             
  begin
      saldo = saldo + (case when :codigo<'200' then :valor else -:valor end);
      suspend;
  end
END^

SET TERM ; ^

grant execute on procedure relatorio_fluxo_caixa to publicweb;


commit work;
--select * from relatorio_fluxo_caixa(1,'today', cast('today' as timestamp) + 90);


