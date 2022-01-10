/*

AL - incluido para por o dctoid o numero pedido.
     dctoid como dado permante do item, imutavel

*/

SET TERM ^ ;
create or ALTER PROCEDURE WEB_REG_PEDIDO_ITEM (
    P_CD_ACAO Integer,
    P_CD_FILIAL Integer,
    P_DT_DATA Timestamp,
    P_NR_PEDIDO Integer,
    P_ID_CLIENTE Integer,
    P_CD_CODIGO Varchar(18),
    P_DS_COMPL Varchar(30),
    P_VL_QTDE Numeric(15,4),
    P_VL_PRECOUNITARIO Numeric(15,4),
    P_NR_ITEM Integer,
    P_CD_VENDEDOR Varchar(10),
    P_NR_LOTE Integer,
    P_NR_PEDIDO_INTEGRA Varchar(20),
    P_COD_FORMPGTO Numeric(15,4),
    P_NR_PARC Numeric(15,4) )
RETURNS (
    TX_MSG Varchar(255),
    NR_PEDIDO Integer,
    NR_LOTE Integer,
    NR_LINHAS_AFETADAS Integer )
AS
declare variable l_conta integer; /* Conta o numero de itens do pedido */
declare variable l_ds_nome varchar(50); /* DescriÃÂ·ÃÂ³o do produto vendido */
declare variable l_cd_prod varchar(18);
declare variable l_cd_filial integer;
declare variable l_data timestamp;
declare variable nr_dav varchar(13);
begin
  nr_linhas_afetadas = 0;

  if (:p_dt_data is null) then
  begin
    tx_msg = '\*Erro. Nao foi informado o campo data.';
    suspend;
    exit;
  end
  --Retorna data sem hora
  select * from encodedecodedate(:p_dt_data) into :l_data;
  --Retorna hora apenas
  --select * from encodedecodetime(:p_dt_data) into :l_time;
  if ( not :p_cd_acao in (0,1,8,9) or (:p_cd_acao is null) ) then
  begin
    tx_msg = '\*Erro. Nao foi indicado a acao a ser processada (0,1,8,9).';
    suspend;
    exit;
  end
  if (:p_cd_acao in (8,9)) then
  begin
    if ((:p_nr_item is null ) or (:p_nr_item=0))  then
    begin
      tx_msg = '\*Erro. Nao foi informado o numero do item a ser excluido.';
      suspend;
      exit;
    end
    if (:p_nr_pedido_integra is null) then
    begin
      tx_msg = '\*Erro. Nao foi informado o pedido a ser excluido.';
      suspend;
      exit;
    end
    if (:p_cd_filial is null) then
    begin
      tx_msg = '\*Erro. Nao foi informado a filial do pedido a ser excluido.';
      suspend;
      exit;
    end
  end

  tx_msg = '';

  --nr_item = :p_nr_item;
  nr_pedido = :p_nr_pedido;
  nr_lote = :p_nr_lote;

  if (p_cd_acao in (8,9) ) then
  begin
    if (p_cd_acao = 9) then
    begin /* Exclusao de Item */
      delete from sigcaut1 where dcto_integracao = :p_nr_pedido_integra
        and data = :l_data
        and sigcaut1.ordem = :p_nr_item
        and filial = :p_cd_filial;
    end
    if (p_cd_acao = 8) then
    begin  /* Exclusao do pedido em todas as suas linhas */
      delete from sigcaut1 where dcto_integracao = :p_nr_pedido_integra
        and data = :l_data
        and  filial = :p_cd_filial;
      delete from sigcauth where dcto_integracao = :p_nr_pedido_integra
        and data = :l_data
        and  filial = :p_cd_filial;
    end
    if (row_count = 0) then
      tx_msg = '\*Erro. Nao foi encontrado item a ser excluido.';
    if (row_count = 1) then
      tx_msg = 'OK';
    if (p_cd_acao = 9) then
      if (row_count > 1) then
        tx_msg = '\*Alerta. Foram excluidos multiplos itens com o mesmo numero informado.';
    nr_linhas_afetadas = row_count;
    suspend;
    exit;
  end

  if (p_cd_acao=1) then
  begin  /* alterar o item indicado */
    update sigcaut1 set clifor = :p_id_cliente, compl = :p_ds_compl,
      qtde = :p_vl_qtde, preco = :p_vl_precounitario, total = :p_vl_precounitario * :p_vl_qtde
      where dcto_integracao = :p_nr_pedido_integra
        and codigo = :p_cd_codigo
        and data = :l_data
        and ordem = :p_nr_item
        and filial = :p_cd_filial;

    if (row_count = 0) then
      tx_msg = '\*Erro. Nao foi encontrado item a ser alterado.';
    if (row_count = 1) then
      tx_msg = 'OK';
    if (row_count > 1) then
      tx_msg = '\*Alerta. Foram alterados multiplos itens com o mesmo numero informado.';
    nr_linhas_afetadas = row_count;
    suspend;
    exit;
  end

  if (p_cd_acao=0) then /* inserir novo item na lista de pedidos */
  begin
     l_cd_prod = '';
     l_cd_filial = 0;
     l_conta = 0;
     -- Verifica filial cadastrada
     select codigo from filial where codigo = :p_cd_filial
        into :l_cd_filial;
     if (:l_cd_filial is null) then
     begin
       tx_msg = '\*Erro. Filial: ' || trim(:p_cd_filial) || ', nao cadastrada.';
       suspend;
       exit;
     end
     -- Checa data nula
     if (:l_data is null) then
     begin
       tx_msg = '\*Erro. Nao foi informada a data do pedido a ser incluido.';
       suspend;
       exit;
     end
     -- Verifica produto cadastrado
     select codigo,nome from ctprod where codigo = :p_cd_codigo
        into :l_cd_prod, :l_ds_nome;
     if (:l_cd_prod = '') then
     begin
       tx_msg = '\*Erro. Produto: ' || trim(:p_cd_codigo) || ' nao cadastrado.';
       suspend;
       exit;
     end
     -- Verifica cliente cadastrado
     /*select codigo from sigcad where oldcodigo = :p_id_cliente
        into :l_cd_cliente;
     if ((:l_cd_cliente = '') or (:l_cd_cliente is null)) then
     begin
       p_id_cliente = 0;
     end
     else
     begin
       p_id_cliente = :l_cd_cliente;
     end*/
     -- Checa quantidade
     if (:p_vl_qtde is null) then
     begin
       tx_msg = '\*Erro. Nao foi informado a quantidade do item: ' || trim(:p_cd_codigo) || ' no pedido.';
       suspend;
       exit;
     end
     -- Checa preÃÂ·o
     if (:p_vl_precounitario is null) then
     begin
       tx_msg = '\*Erro. Nao foi informado o preco do item: ' || trim(:p_cd_codigo) || '';
       suspend;
       exit;
     end
     select count(*) from sigcaut1 where dcto_integracao = :p_nr_pedido_integra
       and data = :l_data
       and filial = :p_cd_filial
       into :l_conta;

     if ((:l_conta = 0) or (:l_conta is null)) then
     begin

       if ((:nr_pedido is null) or (:nr_pedido = 0)) then
       begin
         select numero from obter_id('PEDIDO') into :nr_pedido;
         if (:p_cd_filial > 0) then
            nr_pedido = (:nr_pedido * 1000) + :p_cd_filial;
       end

       select lpad(numero, 13, '0') from obter_id('DAV' || cast(:p_cd_filial as char(3))) into :nr_dav;

       if ((:nr_lote is null) or (:nr_lote = '0')) then
        begin         
         select numero from obter_id('LOTE') into :nr_lote;
         if (:p_cd_filial > 0) then
         nr_lote = (:nr_lote * 1000) + :p_cd_filial;
       end

       insert into sigcauth (operacao,entrega,data,cliente,vendedor,dcto,filial,
        lote, dav, dcto_integracao,formpgto,nrparc) values('129', '0', :l_data, :p_id_cliente,
        :p_cd_vendedor, :nr_pedido, :p_cd_filial, :nr_lote, :nr_dav,
        :p_nr_pedido_integra,:p_cod_formpgto,:p_nr_parc);

     end
     else
     begin
       select count(*) from sigcaut1 where dcto_integracao = :p_nr_pedido_integra
         and data = :l_data
         and filial = :p_cd_filial
         and ordem = :p_nr_item
         into :l_conta;
       if ((:nr_lote is null) or (:nr_lote = 0)) then
         select dcto, lote from sigcauth where dcto_integracao = :p_nr_pedido_integra
           and data = :l_data
           and filial = :p_cd_filial
           into :nr_pedido, :nr_lote;
       if (:l_conta > 0) then
       begin
         tx_msg = '\*Erro. Item: ' || :p_cd_codigo || ' ja incluido no pedido: ' ||
            :nr_pedido || '.';
         suspend;
         exit;
       end
     end

     --select nome from ctprod where codigo = :p_cd_codigo into :l_ds_nome;

     insert into sigcaut1 (registrado,baixado,qtde_origi,qtdebaixa, total,ordem,
       operacao,filial,data, clifor, dcto,dctoid, codigo, nome, compl, qtde, preco,
       sigcauthlote, vendedor, dcto_integracao, imprimeimediato) values
       ('N','N',:p_vl_qtde,0,:p_vl_precounitario*:p_vl_qtde, :p_nr_item,'129',
       :p_cd_filial, :l_data,:p_id_cliente, :nr_pedido,:nr_pedido, :p_cd_codigo,
       :l_ds_nome,:p_ds_compl,:p_vl_qtde,:p_vl_precounitario,:nr_lote,
       :p_cd_vendedor, :p_nr_pedido_integra, null);

     NR_LINHAS_AFETADAS = row_count;
     if (nr_linhas_afetadas=2) then
        tx_msg = 'OK';
  end
  suspend;
end^
SET TERM ; ^
grant execute on procedure WEB_REG_PEDIDO_ITEM to publicweb;

commit;