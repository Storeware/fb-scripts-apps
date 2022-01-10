--rollback;



SET TERM ^ ;
create or ALTER PROCEDURE WEB_REG_PEDIDO_PAGO 
(
    P_OPERADOR Varchar(10),
    CAIXA Varchar(10),
    P_PRTSERIE Varchar(10),
    OPERACAO Varchar(10),
    FILIAL Integer,
    P_DATA Timestamp,
    P_DCTO Varchar(10),
    VALORPEDIDO Double precision,
    P_LOTE Double precision )
RETURNS (
    STATUSCODE Integer,
    MENSAGEM Varchar(255),
    DATA Timestamp,
    TOTAL Numeric(15,2),
    ITENS Integer,
    IDREFER Double precision,
    DCTO Varchar(20),
    PRTSERIE Varchar(10),
    VITENS Double precision,
    VPARCELAS Numeric(15,2),
    CONTROL Double precision )
AS
declare variable qtde double precision;
declare variable preco double precision;
declare variable vitem double precision;
declare variable codigo varchar(18);
declare variable cOperacao varchar(10);
declare variable diff double precision;
declare variable ordem integer;
declare variable id numeric(18,0);
declare variable sigcauthId numeric(18,0);
declare variable codicms varchar(10);
declare variable nome varchar(50);
declare variable cliente numeric(15,0);
declare variable vendedorFinalizou varchar(10);
declare variable vendedor varchar(10);
declare variable vparcela numeric(15,2);
declare variable vcto timestamp;
declare variable idmeio numeric(10,0);
declare variable inicio timestamp;
declare variable fim timestamp;
declare variable lote numeric(15,0);
declare variable cupomhr varchar(8);
declare variable impresso varchar(10);
declare variable n_dcto numeric(15,0);
declare variable sControl varchar(10);
declare variable codTrans varchar(10);


begin
  statusCode = 500;
  mensagem = 'OK';
  itens = 0;
  total = 0;
  vitens = 0;
  inicio = 'now';
  data = 'today';
  
  
  
  cupomhr =  lpad( substring(replace(cast(inicio as varchar(30)),' ','0') from 12 for 8),8,'0');
  
  
  /* checa consistencia dos itens */
  select sum(coalesce((qtde-qtdebaixa)*preco,0)),count(*) from sigcaut1
  where dcto=:p_dcto and data >= :p_data
        and filial=:filial  
         and qtde>qtdebaixa
  into :total,:itens;
  
  
  if (total is null) then
  begin
    statusCode = 404;
    mensagem = 'Nao ha item para faturamento. Filial: '||:filial||' Data: '||:p_data|| ' Dcto: '||:p_dcto;
    suspend;
    exit;
  end
  
  
  diff = coalesce(total,0)-coalesce(valorPedido,0);
  
  if (:diff<0) then diff = diff*-1;
  
  if (diff > (itens/100)) then
     begin
       statusCode = 406;
       mensagem = 'Valor do pedido inconsistente com os itens - '||coalesce(total,0);
       suspend;
       exit;
     
     end
  if (coalesce(total,0)=0) then
  begin
    statusCode = 404;
    mensagem = 'Documento sem valor para pagamento';
    suspend;
    exit;
  
  end   
  
  
  /* checa consistencia das parcelas */   
  select sum(valor) from sigcautp
  where dcto=:p_dcto and sigcauthlote=:p_lote and filial=:filial
  into :vparcelas;   
  
  
  
  
  --if (1=0) then  
  diff = coalesce(total,0)-coalesce(vparcelas,0);
  if (:diff<0) then diff = diff*-1;
  
  if ((diff)>0.01) then
  begin
     statusCode = 402;
     mensagem = 'Valor das parcelas inconsitente com valor do pedido - '||coalesce(vparcelas,0);
     suspend;
     exit;
  end   
     
     
  select first 1 id,cliente,vendedor,lote,impresso from sigcauth
  where dcto = :p_dcto and filial=:filial   and data=:p_data
  into :sigcauthId, cliente,:vendedorFinalizou,:lote,:impresso;
     
  if (coalesce(impresso,'N')='S') then
  begin
    statusCode = 403;
    mensagem = 'O documento foi finalizado, nao esta disponivel para faturamento. Filial:'||:filial||' Data:'||:p_data||' Dcto:'||:p_dcto;
    suspend;
    exit;
  
  end   
  
  if (sigcauthId is null) then
  begin
    statusCode = 404;
    mensagem = 'Nao encontrei o documento para pagamento';
    suspend;
    exit;
  
  end
     
     
     
  /* lancar os pagamentos */
  
  -- gerar a sequencia de referencia
  select numero from obter_id('SECAOID')
  into :idrefer;
  
  
  select numero from obter_id('CTRLDCTO')
  INTO :CONTROL;
  sControl =   lPad(cast(cast(control as integer) as varchar(20)),10,'0');
  
  
  prtserie = :p_prtserie;
  
  
  
  select numero from obter_id('APP_PDV')
  into :n_dcto;
  
  dcto =  lPad(cast(cast(n_dcto as integer) as varchar(20)),10,'0');
  
  
  
  itens = 0;
  ordem = 0;
  -- pegar os itens a baixar
  for select id, operacao, qtde,preco,codigo,total,nome,vendedor from sigcaut1
  where data=:p_data and dcto=:p_dcto   
  into :id, :cOperacao,:qtde,:preco,:codigo, :vitem,:nome,:vendedor
  do
  begin
    vitens = vitens + vitem;
    itens = itens + 1;
    ordem = ordem + 1;
    cOperacao = coalesce(cOperacao,'127');
    -- dados de tributacao
    select nf_codicms from ctprod 
    where codigo=:codigo
    into :codicms;
    
  
  
  
    
    insert into sigcaut2
     (ordem,operacao,prtserie,dcto,filial,codigo,
      nome,data,qtde,preco,valor,vendedor,
      olddcto,oldfilial, codicms,baixado, hora,hr,registrado)
     values
      (:ordem,:cOperacao,:p_prtserie,:dcto,:filial,:codigo,
      :nome,:data,:qtde,:preco,:vitem,:vendedor,
      :p_dcto,:filial,rpad(:codicms,2,'0'),'N', lpad(:cupomhr,8,'0') ,rPad(:cupomhr,2 ,'0'),'N' ) ;
    update sigcaut1 set qtdebaixa = :qtde, remessa = :sControl where id =:id;  
  end
  
  
  
  -- lancar sig02
  insert into sig02
   (control,dcto,idrefer,historico,codigo,data,prtserie,filial,
    clifor,valor,valor_,ordem,banco,registrado,vendedor,sigcauthlote,
    olddcto,oldfilial,dtcontabil,datamvto,operador,datadctovenda,
    cupomhr,data_
    )
   values
   (:control,:dcto,:idrefer,'VDA '||:p_prtserie,:operacao,:data,:p_prtserie,:filial,
    :cliente,:vitens,:vitens,1,:caixa,'N',:vendedorFinalizou,:p_lote,
    :p_dcto,:filial,:data,:data,SUBSTR(:p_operador,1,10),:p_data,
    substr(:cupomhr,1,8),:data
   );
  --lancar os pagamentos sig02cp
  fim = 'now';  
  for select codigo,valor,vcto,id_meio,ordem,codTrans from sigcautp
  where dcto=:p_dcto and data=:p_data and filial=:filial
  into :codigo, :vparcela,:vcto,:idmeio,:ordem,:codTrans
  do
  begin
    -- sig02cp
    insert into sig02cp
      (caixa,cliente,data,filial,codigo,valor,idrefer,datamvto,codTrans,
       registrado,vcto,meiopgto,ordem,prtserie,valorPrincipal,inicio,fim)
      values
      (
       :caixa,:cliente,:data,:filial,:codigo,:vParcela,:idrefer,:data,:codTrans,
       'N',:vcto,:idmeio,:ordem,:p_prtserie, :vParcela,:inicio,:fim  );
  
  end
  
  -- gerar o header de pagamento sig02cph
  if (vitens>0) then
  begin
     insert into sig02cph 
       (idrefer,data,inicio,fim,filial,prtserie,ordem,caixa,registrado,clifor,operador,total,datamvto)
       values
       (:idrefer,:data,:inicio,:fim,:filial,:prtserie,1,:caixa,'N',:cliente,:p_operador,:vitens,:data);
  
  
     update sigcauth set impresso = 'S' where id = :sigcauthId;
     statusCode = 200;
     mensagem = 'Processado OK';
  end
  
  
      
  suspend;
end^
SET TERM ; ^


commit;

grant execute on procedure web_reg_pedido_pago to publicweb;
grant all on sigcaut1 to procedure WEB_REG_PEDIDO_PAGO;
grant all on sigcaut2 to procedure WEB_REG_PEDIDO_PAGO;
grant all on sig02 to procedure WEB_REG_PEDIDO_PAGO;
grant all on sig02cp to procedure WEB_REG_PEDIDO_PAGO;
grant all on sig02cph to procedure WEB_REG_PEDIDO_PAGO;
grant all on sigcautp to procedure WEB_REG_PEDIDO_PAGO;
grant all on sigcauth to procedure WEB_REG_PEDIDO_PAGO;

grant select on sig02 to publicweb;

grant select,insert,delete,update on  ATEND_HORA to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  ATEND_HR_PROD to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  sigcaut2_hora to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  sigcaut2_data to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  inifiles to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant execute on procedure REG_RATEIO_CUPOM_VENDA to publicweb;
grant execute on procedure REG_APONTAMENTO_PRODUCAO to publicweb;

grant select on sig02obs to publicweb;
grant select on sigcaut2 to publicweb;
grant select on PRTREDE_LOCAIS to publicweb;
grant select,delete,insert on PRODUCAO_IMPRIMIR to publicweb;

grant select,insert,update,delete on sigcautp to publicweb;
grant select,insert,update on prod_ctprodsd_celula to publicweb;




--select * from web_reg_pedido_pago('1','99','APP','111',1,'2020-07-16','100019',92.24);
--rollback;



commit;


