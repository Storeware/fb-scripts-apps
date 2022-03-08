SET TERM ^ ;
Create or ALTER PROCEDURE COMANDA_PRECOPRODUTO (
    P_CODIGO varchar(18),
    P_FILIAL float,
    P_QTDE numeric(15,4),
    P_TABELAPRECO integer )
RETURNS (
    ACHOU integer,
    CODIGO varchar(18),
    UNIDADE varchar(5),
    NOME varchar(50),
    EHBALANCA integer,
    PRECOVENDA numeric(15,4),
    QTDE numeric(15,4) )

AS
DECLARE VARIABLE dummy_precovenda numeric(15,4); 
DECLARE VARIABLE precoBalanca numeric(15,4);
DECLARE VARIABLE precoweb numeric(15,4);
DECLARE VARIABLE precoPromocao numeric(15,4);
DECLARE VARIABLE agora DATE;
DECLARE VARIABLE precovda2 numeric(15,4);
DECLARE VARIABLE qtvarejo numeric(15,4);
DECLARE VARIABLE TEXTO VARCHAR(255);
DECLARE VARIABLE valorBalanca numeric(15,4);
BEGIN
  ehBalanca = 0;
  qtde = :p_qtde;
  agora = cast('now' as Date);
  achou = 1;
  
  -- avalia se e um codigo de balanca;
  texto = SUBSTRING(:p_codigo FROM 1 FOR 1);
  if (( texto='2') and (strlen(:p_codigo)=13)) then
  begin
      ehBalanca = 1;  
      valorBalanca = cast(substring(:p_codigo from 6 for 6) as numeric(15,4)) /100;
      codigo = substring(:p_codigo from 1 for 5);
  end    
  
  -- valida codigo de referencia na ctprox
  select codigo from ctprodx where codfinal = :P_CODIGO
  into :codigo;
  codigo = coalesce(codigo,p_codigo);
  
  -- pega parametros no cadastro principal
  select nome,unidade, precovenda, qtvarejo from ctprod where codigo = :codigo
  into :nome,:unidade,:dummy_precovenda, :qtvarejo;
  
  if (nome is null) then
  begin
     nome = 'Nao encontrado';
     achou = 0;
  end
  -- procura preco na filial
  select precovenda, precoweb, precovda2 from ctprod_filial
  where codigo=:p_codigo and filial = :p_filial
  into :precovenda, :precoweb, :precovda2;
  
  -- se nao existe preco na filial, usar do cadastro principal
  precovenda = coalesce(:precovenda,:dummy_precovenda);
  precoBalanca = precovenda;
  
  --texto = dummy_precovenda;
  
    -- para codigo de banlanca, alterar a qtde
  if (ehBalanca=1) then
  begin
     qtde = ROUND( valorBalanca / precoBalanca,3);     
  
  end

  
  -- pega preco de promo??o
  select prompreco from CTPROD_FILIAL_PROMOCAO
  where codigo = :codigo and filial =:p_filial and
        promdtini<=:agora and promdtfim>=:agora
  into :precoPromocao;
  if (precoPromocao is not null) then precovenda = :precoPromocao;
  
  --texto = precoPromocao;
  
  -- se houver preco web, usar precoweb;
  -- if (precoweb is not null) then precovenda=:precoweb;

  -- avalia preco atacarejo
  if ((:precovda2 is not null) and (:precovda2>0) and (:qtvarejo is not null) and (:p_qtde>=:qtvarejo) ) then
  begin
     -- pode usar o preco de atacado
     if (precovda2 < precovenda) then
        precovenda = precovda2;
  
  end
  
  precovenda = coalesce(precovenda,precoweb);

  suspend;
END
^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE COMANDA_PRECOPRODUTO TO ROLE PUBLICWEB;

GRANT EXECUTE
 ON PROCEDURE COMANDA_PRECOPRODUTO TO  SYSDBA WITH GRANT OPTION;


grant select on CTPRODX to procedure COMANDA_PRECOPRODUTO;

commit;
--select a.* from comanda_precoproduto( '2',1,1,null) a;
