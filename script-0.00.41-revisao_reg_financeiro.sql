



SET TERM ^ ;
CREATE OR ALTER PROCEDURE PROC_REG_FINANCEIRO111 (
    ID Double precision,
    CONTROL Double precision )
RETURNS (
    CONTA Integer )
AS
DECLARE VARIABLE DATA timestamp;
DECLARE VARIABLE DCTO VARCHAR(10);
DECLARE VARIABLE FILIAL DOUBLE PRECISION;
DECLARE VARIABLE CODIGO VARCHAR(10);
DECLARE VARIABLE VALOR DOUBLE PRECISION;
DECLARE VARIABLE CLIFOR DOUBLE PRECISION;
DECLARE VARIABLE RESULT DOUBLE PRECISION;
DECLARE VARIABLE IDREFER DOUBLE PRECISION;
DECLARE VARIABLE PRTSERIE VARCHAR(10);
DECLARE VARIABLE VCTO timestamp;
DECLARE VARIABLE BANCO VARCHAR(10);
DECLARE VARIABLE VENDEDOR VARCHAR(10);
DECLARE VARIABLE HISTORICO VARCHAR(50);
DECLARE VARIABLE ORDEM INT;
declare variable registrado varchar(1);
begin
   CONTA = 0;
   -- processa venda em dinheiro
   -- TODO: o registro de dinheiro poderia ser sintetico
   FOR SELECT CAIXA,DATA, FILIAL,CODIGO,VALOR,CLIENTE,IDREFER,PRTSERIE,VCTO, ORDEM, REGISTRADO
   FROM SIG02CP WHERE ID =:ID
   INTO :BANCO,:DATA,:FILIAL,:CODIGO,:VALOR,:CLIFOR,:IDREFER,:PRTSERIE,:VCTO,:ORDEM,:REGISTRADO
   DO
   begin
   
   
     IF (:REGISTRADO='S') then 
       EXCEPTION ERRO 'Registro lancado nao pode ser lancado novamente';

     SELECT FIRST 1 DCTO, HISTORICO,VENDEDOR FROM SIG02 WHERE IDREFER=:IDREFER AND DATA =:DATA AND FILIAL=:FILIAL
     INTO :DCTO,:HISTORICO,:VENDEDOR;
     
     SELECT CTRL FROM 
      REG_SIGCX(:CONTROL ,:BANCO , :DATA , :FILIAL , 
        :CODIGO , :DCTO ,:VENDEDOR ,:VCTO ,
        :VALOR ,:CLIFOR ,:HISTORICO ,:PRTSERIE , :ORDEM, 'S' )
     INTO :RESULT;

    IF (RESULT IS NOT NULL) then
    begin
      CONTA =  CONTA + row_count;  
      update sig02cp set ctrl_reg = :RESULT, registrado = 'S' where id=:id;
    end  
     
   end
   
   suspend;

end^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO111 TO PROCEDURE PROC_REG_FINANCEIRO;

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO111 TO  SYSDBA WITH GRANT OPTION;




SET TERM ^ ;
CREATE OR ALTER PROCEDURE PROC_REG_FINANCEIRO112 (
    ID Double precision,
    CONTROL Double precision )
RETURNS (
    CONTA Integer )
AS
declare variable CTRL double precision;
declare variable FILIAL double precision;
declare variable EMISSAO timestamp;
declare variable VCTO timestamp;
declare variable PRTSERIE varchar(10);
declare variable CLIFOR double precision;
declare variable CODIGO varchar(10);
declare variable DCTO varchar(10);
declare variable NOTAFISCAL double precision;
declare variable NFSEQ double precision;
declare variable HISTORICO varchar(50);
declare variable VALOR double precision;
declare variable VENDEDOR varchar(10);
declare variable ORDEM double precision;
declare variable DCTOOK varchar(1);
declare variable BANCO varchar(10);
declare variable DATA timestamp;
declare variable IDREFER double precision;
declare variable DTCONTABIL timestamp;
declare variable registrado varchar(1);


begin
   CONTA = 0;
   -- processa venda prazo

   FOR SELECT CAIXA,DATA, FILIAL,CODIGO,VALOR,CLIENTE,IDREFER,PRTSERIE,VCTO, ORDEM, REGISTRADO
   FROM SIG02CP WHERE ID =:ID
   INTO :BANCO,:DATA,:FILIAL,:CODIGO,:VALOR,:CLIFOR,:IDREFER,:PRTSERIE,:VCTO,:ORDEM, :REGISTRADO
   DO
   begin

     IF (:REGISTRADO='S') then 
       EXCEPTION ERRO 'Registro lancado nao pode ser lancado novamente';



     SELECT FIRST 1 DCTO, HISTORICO,VENDEDOR,NOTAFISCAL, NFSEQ FROM SIG02 WHERE IDREFER=:IDREFER AND DATA =:DATA AND FILIAL=:FILIAL
     INTO :DCTO,:HISTORICO,:VENDEDOR, :NOTAFISCAL,:NFSEQ ;

     DTCONTABIL = coalesce(DTCONTABIL, data   );
     EMISSAO = coalesce(EMISSAO,data);
     DCTOOK = coalesce(DCTOOK,'S');
     
     SELECT p.CTRL_ID
     FROM 
     REG_SIGFLU_EX(
       :FILIAL, :EMISSAO, :VCTO, :PRTSERIE, :CLIFOR, :CODIGO, 
       :DCTO, :NOTAFISCAL, :NFSEQ, :HISTORICO, :VALOR, 
       :VENDEDOR, :ORDEM, :DCTOOK, :CONTROL, 
       :IDREFER, :DTCONTABIL
       )   p 
       INTO :CTRL;
    
    IF (CTRL IS NOT NULL) then
    begin
      CONTA =  CONTA + row_count;  
     update sig02cp set ctrl_reg = :ctrl, registrado = 'S' where id=:id;
    end  

   
   END
   suspend;

end^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO112 TO PROCEDURE PROC_REG_FINANCEIRO;

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO112 TO  SYSDBA WITH GRANT OPTION;



SET TERM ^ ;
CREATE or alter PROCEDURE REG_SIGFLU_EX (
    FILIAL Double precision,
    EMISSAO Timestamp,
    VCTO Timestamp,
    PRTSERIE Varchar(10),
    CLIFOR Double precision,
    OPERACAO Varchar(10),
    DCTO Varchar(15),
    NOTAFISCAL Double precision,
    NFSEQ Double precision,
    HISTORICO Varchar(50),
    VALOR Double precision,
    VENDEDOR Varchar(15),
    ORDEM Double precision,
    DCTOOK Varchar(1),
    CONTROL Double precision,
    IDREFER Double precision,
    DTCONTABIL Timestamp )
RETURNS (
    CTRL_ID Integer )
AS
begin
  /* Procedure Text */
  select numero from obter_id('CTRLDCTO') into :ctrl_id;
  insert into sigflu
  (bdregdebito,notafiscal,nfseq,vendedor,prtserie,oldordem,dcto_,
   dtcontabil,digitacao,
   filial,banco,tipo,data,emissao,dcto,codigo,
   clifor,valor,valor_,historico,dctook, control, idrefer,insercao,ctrl_id)
  values
  (1,:notafiscal,:nfseq,substr(:vendedor,1,10),substr(:prtserie,1,10),:ordem,substr(:dcto,1,10),coalesce(:dtContabil,'today'),
    cast('today' as timestamp),
   :filial,'','E',:vcto,coalesce(:emissao,'today'), :dcto,:operacao,
   :clifor, :valor,:valor, substr(:historico,1,34), :dctook,:control, :idrefer, cast('now' as timestamp),:ctrl_id);
  suspend;
end^
SET TERM ; ^

GRANT EXECUTE
 ON PROCEDURE REG_SIGFLU_EX TO PROCEDURE NF_GERAR_ENTRADA_MERC_FATURADA;

GRANT EXECUTE
 ON PROCEDURE REG_SIGFLU_EX TO PROCEDURE PROC_REG_FINANCEIRO112;

GRANT EXECUTE
 ON PROCEDURE REG_SIGFLU_EX TO  SYSDBA;

GRANT EXECUTE
 ON PROCEDURE REG_SIGFLU_EX TO  TESTE;

GRANT EXECUTE
 ON PROCEDURE REG_SIGFLU_EX TO  WBA;







SET TERM ^ ;
create or ALTER PROCEDURE PROC_REG_FINANCEIRO114 (
    ID Double precision,
    CONTROL Double precision )
RETURNS (
    CONTA Integer )
AS
declare variable CTRL double precision;
declare variable CTRL_DESPESA double precision;
declare variable FILIAL double precision;
declare variable EMISSAO timestamp;
declare variable VCTO timestamp;
declare variable PRTSERIE varchar(10);
declare variable CLIFOR double precision;
declare variable CODIGO varchar(10);
declare variable DCTO varchar(10);
declare variable NOTAFISCAL double precision;
declare variable NFSEQ double precision;
declare variable HISTORICO varchar(50);
declare variable VALOR double precision;
declare variable VENDEDOR varchar(10);
declare variable ORDEM double precision;
declare variable DCTOOK varchar(1);
declare variable BANCO varchar(10);
declare variable DATA timestamp;
declare variable IDREFER double precision;
declare variable DTCONTABIL timestamp;
declare variable OPERADORA varchar(10);
declare variable CLIFOR_CARTAO float;
declare variable TAXAADMIN FLOAT;
declare variable VALOR_DESPESA FLOAT;
declare variable LIQUIDO FLOAT;
declare variable PRAZO_CARTAO FLOAT;
declare variable VCTO_CARTAO timestamp;
declare variable registrado varchar(1);
begin
   CONTA = 0;
   -- processa venda prazo

   FOR SELECT OPERADORA,CAIXA,DATA, FILIAL,CODIGO,VALOR,CLIENTE,IDREFER,PRTSERIE,VCTO, ORDEM, REGISTRADO
   FROM SIG02CP WHERE ID =:ID
   INTO :OPERADORA, :BANCO,:DATA,:FILIAL,:CODIGO,:VALOR,:CLIFOR,:IDREFER,:PRTSERIE,:VCTO,:ORDEM,:REGISTRADO
   DO
   begin
   
     IF (:REGISTRADO='S') then
       EXCEPTION ERRO 'Registro lancado nao pode ser lancado novamente';
   
   
     -- procura o cabecalho do registro da venda
     SELECT FIRST 1 DCTO, HISTORICO,VENDEDOR,NOTAFISCAL, NFSEQ 
     FROM SIG02 
     WHERE IDREFER=:IDREFER AND DATA =:DATA AND FILIAL=:FILIAL
     INTO :DCTO,:HISTORICO,:VENDEDOR, :NOTAFISCAL,:NFSEQ ;
     DTCONTABIL = coalesce(DTCONTABIL, data   );
     EMISSAO = coalesce(EMISSAO,data);
     DCTOOK = coalesce(DCTOOK,'S');
     
     -- procura dados do cartao
     SELECT CLIFOR,TAXAADMIN, PRAZO FROM SIGCCART
     WHERE CODIGO = :OPERADORA
     INTO :CLIFOR_CARTAO,:TAXAADMIN, :PRAZO_CARTAO;
     
     LIQUIDO = :VALOR;
     VCTO_CARTAO = :VCTO;
     VALOR_DESPESA = 0;
     IF (COALESCE(:TAXAADMIN,0)>0) then
     begin
       VCTO_CARTAO = COALESCE(:EMISSAO + :PRAZO_CARTAO,VCTO);
       VALOR_DESPESA = COALESCE(:VALOR * :TAXAADMIN/100,0);
       LIQUIDO = (:VALOR - :VALOR_DESPESA);
     END
     
     

     --exception ERRO 'Operadora: '||:operadora|| ' Taxa: '||coalesce(:taxaadmin,'NULL');     
     
     in autonomous transaction do
     SELECT p.CTRL_ID
     FROM 
     REG_SIGFLU_EX(
       :FILIAL, :EMISSAO, :VCTO_CARTAO, :PRTSERIE, COALESCE(:CLIFOR_CARTAO,:CLIFOR), :CODIGO, 
       :DCTO, :NOTAFISCAL, :NFSEQ, :HISTORICO, :VALOR, 
       :VENDEDOR, :ORDEM, :DCTOOK, :CONTROL, 
       :IDREFER, :DTCONTABIL
       )   p 
       INTO :CTRL;

   
    
    IF (CTRL IS NOT NULL) then
    begin
      CONTA =  CONTA + row_count;  
     in autonomous transaction do
     update sig02cp set ctrl_reg = :ctrl, registrado = 'S' where id=:id;
    end  

   
   
   
    if (VALOR_DESPESA>0) then   
    IF (CONTA>0) then
    begin
     in autonomous transaction do
     SELECT P.CTRL_ID FROM REG_SIGFLU_EX(
       :FILIAL, :EMISSAO, :VCTO_CARTAO, :PRTSERIE, COALESCE(:CLIFOR_CARTAO,:CLIFOR), '501', 
       :DCTO, :NOTAFISCAL, :NFSEQ, :HISTORICO, :VALOR_DESPESA, 
       :VENDEDOR, :ORDEM, :DCTOOK, :CONTROL, 
       :IDREFER, :DTCONTABIL
       )   p 
       INTO :CTRL_DESPESA;
     --exception ERRO ctrl;  
     IF (CTRL IS NOT NULL) then
     begin
       CONTA =  CONTA + row_count;  
       in autonomous transaction do
       update sigflu set sacado = :clifor where ctrl_id = :ctrl and data=:VCTO_CARTAO;
     end  
    end
    
  



    
   END
   suspend;

end^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO114 TO PROCEDURE PROC_REG_FINANCEIRO;

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO114 TO  SYSDBA WITH GRANT OPTION;
 
 
 
 
SET TERM ^ ;
CREATE or alter PROCEDURE PROC_REG_FINANCEIRO116 (
    ID Double precision,
    CONTROL Double precision )
RETURNS (
    CONTA Integer )
AS
begin
   CONTA = 0;
   -- processa venda em credito
   -- TODO: registro sintetico
   SELECT CONTA FROM PROC_REG_FINANCEIRO114(:ID,:CONTROL)
   INTO :CONTA;
   suspend;

end^
SET TERM ; ^

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO116 TO PROCEDURE PROC_REG_FINANCEIRO;

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO116 TO  SYSDBA WITH GRANT OPTION;


SET TERM ^ ;
CREATE or alter PROCEDURE PROC_REG_FINANCEIRO119 (
    ID Double precision,
    CONTROL Double precision )
RETURNS (
    CONTA Integer )
AS
begin
   CONTA = 0;
   -- processa venda em credito
   -- TODO: registro sintetico
   SELECT CONTA FROM PROC_REG_FINANCEIRO114(:ID,:CONTROL)
   INTO :CONTA;
   suspend;

end^
SET TERM ; ^

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO119 TO PROCEDURE PROC_REG_FINANCEIRO;

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO119 TO  SYSDBA WITH GRANT OPTION;

 


SET TERM ^ ;
CREATE or alter PROCEDURE PROC_REG_FINANCEIRO
RETURNS (
    CONTA Integer )
AS
DECLARE VARIABLE ID double precision;
DECLARE VARIABLE operacao varchar(10);
DECLARE VARIABLE PROCESSADOS INT;
DECLARE VARIABLE CONTROL DOUBLE PRECISION;
BEGIN
  CONTA = 0;
   
  
  for select first 500 id,codigo from sig02cp a join sig01 b on (b.codigo=a.CODIGO)
  where registrado = 'N'
  into :id, :operacao
  do
  in AUTONOMOUS transaction do
  begin
     IF (:CONTROL IS NULL) THEN 
        select numero from obter_id('CTRLDCTO') into :CONTROL; 
     -- registrar um item no financeiro
     if (operacao like '111%') then
       select conta from proc_reg_financeiro111( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
     if (operacao like '112%') then
       select conta from proc_reg_financeiro112( :id, :CONTROL )
       INTO :PROCESSADOS;
     else
     if (operacao like '113%') then
       select conta from proc_reg_financeiro113( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
     if (operacao like '114%') then
       select conta from proc_reg_financeiro114( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
     if (operacao like '115%') then
       select conta from proc_reg_financeiro115( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
     if (operacao like '116%') then
       select conta from proc_reg_financeiro116( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
     if (operacao like '117%') then
       select conta from proc_reg_financeiro117( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
     if (operacao like '118%') then
       select conta from proc_reg_financeiro118( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
     if (operacao like '119%') then
       select conta from proc_reg_financeiro119( :id, :CONTROL )
       INTO :PROCESSADOS;
     else  
       select conta from proc_reg_financeiro11x( :id, :CONTROL )
       INTO :PROCESSADOS;
       
     PROCESSADOS = COALESCE(:PROCESSADOS,0);  
     CONTA = CONTA + :PROCESSADOS;  
     --IF (PROCESSADOS>0) THEN
     --  UPDATE SIG02CP SET REGISTRADO = 'S', CTRL_REG = :CONTROL  WHERE ID =:ID;
  end
  SUSPEND;
END^
SET TERM ; ^

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO TO  SYSDBA WITH GRANT OPTION;


commit work;

--select * from PROC_REG_FINANCEIRO;


