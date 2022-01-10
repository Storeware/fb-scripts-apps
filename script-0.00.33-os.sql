
grant update on ctprod_filial to publicweb;
grant update, select, insert, delete on PET_ATENDIMENTO_ITENS to publicweb;

SET TERM ^ ;
create or ALTER  PROCEDURE WEB_REG_PEDIDO (
    P_CD_FILIAL Integer,
    P_DT_DATA Timestamp,
    P_CD_CLIENTE Double precision,
    P_NR_PEDIDO Varchar(10),
    P_NR_LOTE Integer,
    P_OPERACAO varchar(10) )
RETURNS (
    ID Integer )
AS
declare variable P_CPF char(19);
begin
  /* Procedure Text */
   select cnpj from sigcad where codigo=:p_cd_cliente
  into :p_cpf;

   insert into wba$log (texto) values('teste log');
   insert into wba$log (texto) values('INSERE PEDIDO: '||:p_nr_pedido||' Filial: '||:p_cd_filial|| ' Data: '||:p_dt_data||' Cliente: '||:p_cd_cliente|| ' CPF: '||:p_cpf||' lote: '||:p_nr_lote);

  update or insert into
      sigcauth
      (dcto,data,cliente,cpf,lote,filial,operacao)
      values
      (:p_nr_pedido,:p_dt_data,:p_cd_cliente,:p_cpf,:p_nr_lote,:p_cd_filial,:p_operacao)
      matching (dcto,data,cliente,filial)
      returning new.id into :id;

  suspend;
end^
SET TERM ; ^




grant select, update, delete, insert on sigven to publicweb;
grant select, update, insert on sigcauth to publicweb;
grant insert on repl_itens to publicweb;
grant USAGE on sequence REPL_ITENS_GEN_ID to publicweb;
grant select,delete on sigven_faixa to publicweb;
grant select,delete on SIGVEN_FAIXAVALORES to publicweb;
grant select,delete on SIGVEN_MEIOPGTO to publicweb;
grant execute  on procedure  WEB_REG_PEDIDO to publicweb;



SET TERM ^ ;
create or ALTER PROCEDURE WEB_REG_PEDIDO_ENTREGA_DIGITAL (
    P_CD_FILIAL Integer,
    P_CD_CLIENTE Float,
    P_DT_DATA Timestamp,
    P_DS_CONTATO Varchar(50),
    P_NR_PEDIDO varchar(10),
    P_CEP Varchar(10),
    P_DT_ENTREGA Timestamp,
    P_DS_ENDERECO Varchar(50),
    P_DS_NUMERO Varchar(15),
    P_DS_BAIRRO Varchar(25),
    P_DS_CIDADE Varchar(20),
    P_DS_ESTADO Varchar(2),
    P_NR_CNPJ Varchar(18),
    P_NR_IE Varchar(14),
    P_OBS Varchar(254),
    P_IN_ENTREGA Varchar(1) )
RETURNS (
    NR_LINHAS_AFETADAS Integer,
    TX_MSG Varchar(255) )
AS
declare variable L_DATA timestamp;
declare variable CONTA integer;
declare variable ORDEM integer;
declare variable P_CPF char(19);
begin
  
  select cnpj from sigcad where codigo=:p_cd_cliente
    into :p_cpf;
  nr_linhas_afetadas = 0;
  if (:p_dt_data is null) then
  begin
    tx_msg = 'Erro. Não foi informado o campo data.';
    suspend;
    exit;
  end
  select * from encodedecodedate(:p_dt_data) into :l_data;
  update sigcauth
  set endEntr = coalesce(:p_ds_endereco,'') ||', '|| coalesce(:p_ds_numero,''),
      bairroEntr = :p_ds_bairro,
      cliente = :p_cd_cliente,
      cidadeEntr = :p_ds_cidade,
      estadoEntr = :p_ds_estado,
      cnpjEntr = :p_nr_cnpj,
      ieEntr = :p_nr_ie,
      dtEnt_Ret = :p_dt_entrega,
      entrega = :p_in_entrega,
      obs = coalesce(obs,'') || coalesce(:p_obs,'') || coalesce(:p_ds_contato,'') ,
      cpf= :p_cpf
  where
     dcto_integracao = :p_nr_pedido
     and data = :l_data
     and filial=:p_cd_filial; 

  nr_linhas_afetadas = row_count;

  if (nr_linhas_afetadas>0) then
  begin
    select count(*) from sigcad_ender
    where codigo = :P_CD_CLIENTE and tipo ='ENTR'
    into :conta; 
    if (:conta = 0) then
    begin 
     -- select max(ordem)+1 from sigcad_ender
      select coalesce(max(ordem),0) +1 from sigcad_ender
      where codigo = :P_CD_CLIENTE 
      into ORDEM;

      insert into sigcad_ender (
         codigo,ordem,tipo,principal,
         ender,numero,cidade,
         estado,cep,cnpj,ie,
         bairro,contato,obs)
        values (
         :P_CD_CLIENTE,:ordem,'ENTR','N',
         :P_DS_ENDERECO,:P_DS_NUMERO,:P_DS_CIDADE,
         :P_DS_ESTADO,:P_CEP,:P_NR_CNPJ,:P_NR_IE,
         :P_DS_BAIRRO,:P_DS_CONTATO,:P_OBS);
    end
  end

  nr_linhas_afetadas = nr_linhas_afetadas + row_count;
  if (nr_linhas_afetadas in (1,2)) then
    tx_msg = 'OK';
  if ((nr_linhas_afetadas>1) and (tx_msg is null)) then
    tx_msg = 'Alerta. Foram alterados multiplos pedidos com o mesmo número informado.';
  if (tx_msg is null) then tx_msg = 'Não processado ('||:p_nr_pedido||','||:l_data||','||:p_cd_filial||')';  
  suspend;

end^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE WEB_REG_PEDIDO_ENTREGA_DIGITAL TO  PUBLICWEB;

SET TERM ^ ;
create or ALTER PROCEDURE WEB_REG_OS_ITEM_EX (
    P_CD_ACAO Integer,
    P_CD_FILIAL Double precision,
    P_DT_DATA Timestamp,
    P_NR_PEDIDO Varchar(10),
    P_ID_CLIENTE Double precision,
    P_CD_CODIGO Varchar(18),
    P_DS_COMPL Varchar(30),
    P_VL_QTDE Numeric(15,4),
    P_PRECO_BASE Numeric(15,4),
    P_VL_PRECOUNITARIO Numeric(15,4),
    P_NR_ITEM Double precision,
    P_CD_VENDEDOR Varchar(10),
    P_NR_LOTE Double precision,
    P_NR_PEDIDO_INTEGRA Varchar(20),
    P_COD_FORMPGTO Numeric(15,4),
    P_NR_PARC Numeric(15,4),
    P_REGISTRADO Varchar(1),
    P_OPERACAO Varchar(10) )
RETURNS (
    ID Double precision,
    TX_MSG Varchar(255),
    NR_PEDIDO Integer,
    NR_LOTE Integer,
    NR_DAV Varchar(13),
    NR_LINHAS_AFETADAS Integer )
AS
declare variable l_conta integer; /* Conta o numero de itens do pedido */
declare variable l_ds_nome varchar(50); /* Descri????????o do produto vendido */
declare variable l_cd_prod varchar(18);
declare variable l_cd_filial integer;
declare variable l_data timestamp;
declare variable hora varchar(8);
declare variable preco_base double precision;
declare variable perc_desc double precision;
begin
  perc_desc = 0;
  hora = lpad( substring(cast('now' as timestamp) from 13 for 8)  ,8,'0');
  
  nr_linhas_afetadas = 0;
  P_OPERACAO = coalesce(P_OPERACAO,'126');
  P_REGISTRADO = coalesce(P_REGISTRADO,'N');
  nr_lote = :p_nr_lote;
  
  preco_base = coalesce(P_PRECO_BASE,0);
  
  if (preco_base is null) then
  select precovenda from CTPROD_FILIAL
  where codigo = :P_CD_CODIGO AND
        filial = : P_CD_FILIAL
  into :preco_base;  
  
  if (preco_base is null) THEN 
     select precovenda from ctprod
     where codigo = :P_CD_CODIGO
     into :preco_base;
     
  if (preco_base is null or preco_base < p_vl_precounitario) THEN
    preco_base = p_vl_precounitario;   
    
  if (preco_base > 0 and preco_base > p_vl_precounitario) THEN
     perc_desc = (preco_base - p_vl_precounitario) / preco_base * 100;   


  if (:p_dt_data is null) then
  begin
    tx_msg = '\*Erro. Não foi informado o campo data.';
    suspend;
    exit;
  end
  --Retorna data sem hora
  select * from encodedecodedate(:p_dt_data) into :l_data;
  --Retorna hora apenas
  --select * from encodedecodetime(:p_dt_data) into :l_time;
  if ( not :p_cd_acao in (0,1,8,9) or (:p_cd_acao is null) ) then
  begin
    tx_msg = '\*Erro. Não foi indicado a acao a ser processada (0,1,8,9).';
    suspend;
    exit;
  end
  if (:p_cd_acao in (8,9)) then
  begin
    if ((:p_nr_item is null ) or (:p_nr_item=0))  then
    begin
      tx_msg = '\*Erro. Não foi informado o número do item a ser excluído.';
      suspend;
      exit;
    end
    if (:p_nr_pedido_integra is null) then
    begin
      tx_msg = '\*Erro. Não foi informado o pedido a ser excluído.';
      suspend;
      exit;
    end
    if (:p_cd_filial is null) then
    begin
      tx_msg = '\*Erro. Não foi informado a filial do pedido a ser excluído.';
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
    begin 
      delete from sigcaut1 where dcto_integracao = :p_nr_pedido_integra
        and data = :l_data
        and sigcaut1.ordem = :p_nr_item
        and filial = :p_cd_filial;
    end
    if (p_cd_acao = 8) then
    begin  
      delete from sigcaut1 where dcto_integracao = :p_nr_pedido_integra
        and data = :l_data
        and  filial = :p_cd_filial;
      delete from sigcauth where dcto_integracao = :p_nr_pedido_integra
        and data = :l_data
        and  filial = :p_cd_filial;
    end
    if (row_count = 0) then
      tx_msg = '\*Erro. Não foi encontrado item a ser excluído.';
    if (row_count = 1) then
      tx_msg = 'OK';
    if (p_cd_acao = 9) then
      if (row_count > 1) then
        tx_msg = '\*Alerta. Foram excluídos multiplos itens com o mesmo número informado.';
    nr_linhas_afetadas = row_count;
    suspend;
    exit;
  end

  if (p_cd_acao=1) then
  begin  
    update sigcaut1 set clifor = :p_id_cliente, compl = :p_ds_compl,
      qtde = :p_vl_qtde, preco = :p_vl_precounitario, total = :p_vl_precounitario * :p_vl_qtde
      where dcto_integracao = :p_nr_pedido_integra
        and codigo = :p_cd_codigo
        and data = :l_data
        and ordem = :p_nr_item
        and filial = :p_cd_filial;

    if (row_count = 0) then
      tx_msg = '\*Erro. Não foi encontrado item a ser alterado.';
    if (row_count = 1) then
      tx_msg = 'OK';
    if (row_count > 1) then
      tx_msg = '\*Alerta. Foram alterados multiplos itens com o mesmo número informado.';
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
       tx_msg = '\*Erro. Filial: ' || trim(:p_cd_filial) || ', não cadastrada.';
       suspend;
       exit;
     end
     -- Checa data nula
     if (:l_data is null) then
     begin
       tx_msg = '\*Erro. Não foi informada a data do pedido a ser incluído.';
       suspend;
       exit;
     end
     -- Verifica produto cadastrado
     select codigo,nome from ctprod where codigo = :p_cd_codigo
        into :l_cd_prod, :l_ds_nome;
     if (:l_cd_prod = '') then
     begin
       tx_msg = '\*Erro. Produto: ' || trim(:p_cd_codigo) || ' não cadastrado.';
       suspend;
       exit;
     end
     -- Checa quantidade
     if (:p_vl_qtde is null) then
     begin
       tx_msg = '\*Erro. Não foi informado a quantidade do item: ' || trim(:p_cd_codigo) || ' no pedido.';
       suspend;
       exit;
     end
     -- Checa pre????o
     if (:p_vl_precounitario is null) then
     begin
       tx_msg = '\*Erro. Não foi informado o preço do item: ' || trim(:p_cd_codigo) || '';
       suspend;
       exit;
     end
     
     if (:p_nr_pedido_integra is not null) then
       select count(*) from sigcauth where dcto_integracao = :p_nr_pedido_integra
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

       
       if ((:nr_lote is null) or (:nr_lote = '0')) then
        begin         
         select numero from obter_id('LOTE') into :nr_lote;
         if (:p_cd_filial > 0) then
         nr_lote = (:nr_lote * 1000) + :p_cd_filial;
       end

       if (coalesce(:l_conta,0) = 0 ) then
          select count(*) from sigcauth where dcto=:p_nr_pedido and filial=:p_cd_filial and lote = :nr_lote
          into :l_conta;  
          
       if (coalesce(:l_conta,0) = 0) then
         begin
           select lpad(cast(numero as integer), 13, '0') from obter_id('DAV' || cast(1.0 as char(3))) into :nr_dav;
           insert into sigcauth (operacao,entrega,data,cliente,vendedor,dcto,filial,
             lote, dav, dcto_integracao,formpgto,nrparc) values(:P_OPERACAO, '0', :l_data, :p_id_cliente,
             :p_cd_vendedor, :nr_pedido, :p_cd_filial, :nr_lote, :nr_dav,
             :p_nr_pedido_integra,:p_cod_formpgto,:p_nr_parc);
         end  

     end
     else
     if (p_nr_pedido_integra is not null) then
     begin
       select count(*) from sigcaut1 where dcto_integracao = :p_nr_pedido_integra
         and data = :l_data
         and filial = :p_cd_filial
         and codigo = :p_cd_codigo
         and ordem = :p_nr_item
         into :l_conta;
       if ((:nr_lote is null) or (:nr_lote = 0)) then
         select dcto, lote from sigcauth where dcto_integracao = :p_nr_pedido_integra
           and data = :l_data
           and filial = :p_cd_filial
           into :nr_pedido, :nr_lote;
       if (:l_conta > 0) then
       begin
         tx_msg = '\*Erro. Item: ' || :p_cd_codigo || ' já incluído no pedido: ' ||
            :nr_pedido || '.';
         suspend;
         exit;
       end
     end
  
     --select nome from ctprod where codigo = :p_cd_codigo into :l_ds_nome;

     insert into sigcaut1 (registrado,baixado,qtde_origi,qtdebaixa, total,ordem,
       operacao,filial,data, clifor, dcto, codigo, nome, compl, qtde, preco, preco_base,perc_desc,
       sigcauthlote, vendedor, dcto_integracao, imprimeimediato,hora) values
       (:P_REGISTRADO,'N',:p_vl_qtde,0,:p_vl_precounitario*:p_vl_qtde, :p_nr_item,:P_OPERACAO,
       :p_cd_filial, :l_data,:p_id_cliente, :nr_pedido, :p_cd_codigo,
       :l_ds_nome,:p_ds_compl,:p_vl_qtde,:p_vl_precounitario,:preco_base,:perc_desc,
       :nr_lote,
       :p_cd_vendedor, :p_nr_pedido_integra, null,:hora) returning id into :ID ;

     NR_LINHAS_AFETADAS = row_count;
     if (nr_linhas_afetadas>0) then
        tx_msg = 'OK';
        
  end
  suspend;
end^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE WEB_REG_OS_ITEM_EX TO  PUBLICWEB;

GRANT EXECUTE
 ON PROCEDURE WEB_REG_OS_ITEM_EX TO  SYSDBA WITH GRANT OPTION;

GRANT EXECUTE
 ON PROCEDURE WEB_REG_OS_ITEM_EX TO  WBA;


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
	begin
	  if ( (old.hora is not null)  and (new.hora is not null)) then
	    mudou = mudou or (old.data<>new.data) or (old.codigo<>new.codigo) or (new.hora<>old.hora) or
	          (old.qtde<>new.qtde)  or (old.filial<>new.filial);
	end          

  in autonomous transaction do
  begin
    if (mudou and (updating or deleting)) then
    begin
          if (old.operacao<200) then fator = 1; else fator = -1;
      hora = lpad( substring(coalesce(old.hora,substring(cast('now' as timestamp) from 13 for 2)) from 1 for 2),2,'0');

      select qtde,total from sigcaut1_hora 
           where codigo = old.codigo and data = old.data and filial = old.filial and hora = :hora
      into :qtde,:total ;      
      if (qtde is not null) then
       update or insert into sigcaut1_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(old.codigo,old.data,old.filial,:hora,coalesce(:qtde,0) - old.qtde*:fator,coalesce(:total,0)+old.total*:fator, ( 
            select grupo from ctprod where codigo = old.codigo
         ) )
         matching (codigo,data,filial,hora);     	     
	end  
  	    
    if (mudou and (inserting or updating)) then
    begin
      if (new.operacao<200) then fator = 1; else fator = -1;
      hora = lpad( substring(coalesce(new.hora,substring(cast('now' as timestamp) from 13 for 2)) from 1 for 2),2,'0');

      select qtde,total from sigcaut1_hora 
           where codigo = new.codigo and data = new.data and filial = new.filial and hora = :hora
      into :qtde,:total;      
      update or insert into sigcaut1_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(new.codigo,new.data,new.filial,:hora, coalesce(:qtde,0) +  new.qtde*:fator,coalesce(:total,0)+new.total*:fator,  (
         select grupo from ctprod where codigo = new.codigo
         ) )
         matching (codigo,data,filial,hora);     	     
    end     
  end     
	
END^

SET TERM ; ^ 



SET TERM ^ ;
create or ALTER TRIGGER SIGCAUT2_MVTO_HORA for sigcaut2 ACTIVE
AFTER INSERT OR UPDATE OR DELETE POSITION 0
AS 
declare variable mudou boolean;
declare variable qtde double precision;
declare variable total double precision;
declare variable fator double precision;
declare variable hora varchar(8);
BEGIN 
    fator = 1;
    mudou = deleting or inserting;
	if (updating ) then
		  if ( (old.hora is not null)  and (new.hora is not null)) then
       	    mudou = mudou or (old.data<>new.data) or (old.codigo<>new.codigo) or (new.hora<>old.hora) or
	          (old.qtde<>new.qtde)  or (old.filial<>new.filial);

  in autonomous transaction do
  begin
    if (mudou and (updating or deleting)) then
    begin
      if (old.operacao<200) then fator = 1; else fator = -1;
      hora = coalesce(lpad( substring(coalesce(old.hora,substring(cast('now' as timestamp) from 13 for 2)) from 1 for 2),2,'0'),'00');

      select qtde,total from sigcaut1_hora 
           where codigo = old.codigo and data = old.data and filial = old.filial and hora = :hora
      into :qtde,:total ;      
     if (qtde is not null) then
      update or insert into sigcaut2_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(old.codigo,old.data,old.filial,:hora,coalesce(:qtde,0) - old.qtde*:fator,coalesce(:total,0)+old.valor*:fator, ( 
            select grupo from ctprod where codigo = old.codigo
         ) )
         matching (codigo,data,filial,hora);     	     
	end  
  	    
    if (mudou and (inserting or updating)) then
    begin
      if (new.operacao<200) then fator = 1; else fator = -1;
      hora = coalesce(lpad( substring(coalesce(new.hora,substring(cast('now' as timestamp) from 13 for 2)) from 1 for 2),2,'0'),'00');

      select qtde,total from sigcaut1_hora 
           where codigo = new.codigo and data = new.data and filial = new.filial and hora = :hora
      into :qtde,:total;      
      update or insert into sigcaut2_hora(codigo,data,filial,hora,qtde,total,grupo)
         values(new.codigo,new.data,new.filial,:hora, coalesce(:qtde,0) +  new.qtde*:fator,coalesce(:total,0)+new.valor*:fator,  (
         select grupo from ctprod where codigo = new.codigo
         ) )
         matching (codigo,data,filial,hora);     	     
    end     
  end     
	
END^
SET TERM ; ^


/*-------------------------------------------------------------------*/
SET TERM ^ ;
create or ALTER PROCEDURE WEB_REG_PEDIDO_TOTALIZA (
    P_CD_FILIAL Integer,
    P_DT_DATA Timestamp,
    P_NR_PEDIDO Varchar(10),
    P_NR_LOTE Integer )
RETURNS (
    VL_TOTAL Numeric(15,4) )
AS
declare variable l_data timestamp;
declare variable vendedor varchar(10);
declare variable hora varchar(8);
begin

 select * from encodedecodedate(:p_dt_data) into :l_data;

  /* Procedure Text */
  select sum(total), max(vendedor),max(hora) from sigcaut1
  where
     sigcauthlote = :p_nr_lote
     and dcto =:p_nr_pedido
     and data = :l_data
     and filial=:p_cd_filial
  into :vl_total, :vendedor,:hora;

 hora = coalesce(hora, coalesce(lpad( substring(coalesce(hora,substring(cast('now' as timestamp) from 13 for 2)) from 1 for 2),2,'0'),'00'));


  update sigcauth
  set --vendedor = :p_id_vendedor,
      --cliente = :p_id_cliente,
      --obs = :p_ds_obs,
      total = :vl_total,
      vendedor = :vendedor,
      hora = :hora
  where
     lote = :p_nr_lote
     and dcto =:p_nr_pedido
     and data = :l_data
     and filial=:p_cd_filial;
  suspend;
end^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE WEB_REG_PEDIDO_TOTALIZA TO  PUBLICWEB;
