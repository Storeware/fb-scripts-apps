/*
 objetos utilizados para montar modelo de notifica��o
   eventos_grupos -> tipos de eventos
   eventos_estados -> estados que um grupo pode percorrer;
   eventos_auto -> eventos possiveis de serem assinados;
   eventos_assinar -> quem assinou para receber eventos (a pessoa)
   eventos_item -> eventos gerados para notificar os assinantes
   registra_evento_ex -> procedure de cria��o e atualiza��o dos eventos;
   
 quando uma pessoa deseja assinar (receber) uma notifia��o ele se registra
 na tablea eventos_assinar;
 Uma assinatura esta limitada as dispon�veis em "eventos_auto"  que indica quais eventos 
 est�o implementados para enviar notifica��o
 Quando ocorre um evento, o banco checa quem assinou aquele evento e gera as 
 notifica��es para as pessoas;
*/



update or INSERT INTO EVENTOS_ESTADOS (CODIGO, NOME, IDGRUPO_ESTADO, FINALIZADO, MOSTRAR_GRADE, INATIVO, ORDEM) VALUES ('1.000000', 'Gerado', '1.000000', 'N', 'N', 'N', '1.000000')
matching (codigo);

update or INSERT INTO EVENTOS_GRUPO (CODIGO, NOME, MOSTRAR_GRADE, INATIVO, PUBLICO, GRUPO, LINK, TOTALIZAR) 
VALUES ('1', 'Gerado pelo Sistema', 'N', 'N', 'S', 'N', 'link', 'N') matching (codigo);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO, INATIVO,pessoa ) VALUES ('ABERTURA-CAIXA', 'Abertura de caixa no PDV', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('FECHAMENTO-CAIXA', 'Caixa fechado no PDV', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('NOVO-PRODUTO', 'Cadastro de novo produto', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('NOVO-CLIENTE', 'Cadastro de novo cliente', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('NOVO-VENDEDOR', 'Cadastro de novo vendedor', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('VENDA-FECHADA', 'Venda fechada', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('VENDA-CANCELADA', 'Venda cancelada', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('VENDA-ITEM-CANCELADO', 'Item de venda cancelado', '1.000000', '1.000000',  'N','')
matching (nome);


update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('VENDA-DEVOLUCAO', 'Devolução de Venda', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('ESTOQUE-MINIMO', 'Atingiu estoque minimo', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('INFO-CAST', 'Assinar INFO-CAST', '1.000000', '1.000000',  'N','')
matching (nome);

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('ALTERACAO-USUARIO', 'Cadastro de usuarios', '1.000000', '1.000000',  'N','')
matching (nome);



--update or INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID) VALUES ('15.02.2021', 'ABERTURA-CAIXA', '1.000000', '1.000000', 'm5', 'N', '81EE0444-B165-4195-AB0E-F9466F064275')
--matching (gid);

--update or INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID) VALUES ('15.02.2021', 'FECHAMENTO-CAIXA', '1.000000', '1.000000', 'm5', 'N', '81EE0444-B165-4195-AB0E-F9466F064277')
--matching (gid);

commit work;


SET TERM ^ ;
create or ALTER PROCEDURE REGISTRA_EVENTO_EX (
        TIPO Integer,
        EVENTO Varchar(20),
        AUTOR Varchar(30),
        TITULO Varchar(128),
        HISTORICO Varchar(128),
        CLIENTE Integer,
        DCTO Varchar(15),
        TABELA Varchar(128),
        IDTABELA Integer,
        ORDEMTABELA Integer,
        VALOR Float,
        USUARIO VARCHAR(20), 
        MASTER VARCHAR(128),
        MASTER_GID VARCHAR(38),
        TABELA_GID VARCHAR(38),
        LEU VARCHAR(1) 
    )
AS
declare variable pessoa varchar(30);
declare variable ev_descricao varchar(128);
declare variable ev_grupo integer;
declare variable ev_estado integer;
declare variable conta integer;
declare variable est_atual integer;
declare variable grupo_atual integer;
declare variable pos_atual integer;
declare variable pos_futura integer;
declare variable agora timestamp;
declare variable eventoid integer;
declare variable obs blob sub_type 0 segment size 80;
declare variable oldestado integer;
declare variable oldgrupo_estado integer;
BEGIN



-- 0 - Insert
-- 1 - update
-- 2 - insert or update muda estado
-- 3 - insert or update - altera historico e estado
-- 4 - Update altera estado se o estado novo for uma ordem superior ao anterior
-- 5 - se nao existir inclui. se existir adiciona uma nota ao evento.
-- 6 - faz update com base no master


-- pega as pessoas que assinaram o evento
for select pessoa,ev_grupo,  ev_estado from
    eventos_assinar where ev_nome=:evento and (inativo is null or inativo='N')
    INTO :pessoa,:ev_grupo ,:ev_estado 
do 
    begin

          select descricao from eventos_auto where nome = :evento
          into :ev_descricao;

          eventoid=0;

          -- checar se os grupos e estados estao marcados
          -- mecanismo para cortar grupos que nao deve gerar eventos
          if ((:ev_grupo>=0) and (:ev_estado>=0)) THEN
          begin

                conta=0;

                select a.data from dummy a into :agora;


                if (:tipo>0) then
                begin
                    -- linha ja existe, pega os dados dela            
                    select first 1 id,  a.idestado,a.idgrupo_estado from eventos_item a
                       where tabela=:tabela
                           and idtabela=:idtabela
                    INTO :conta,:oldestado ,:oldgrupo_estado;  /* retorna o ID encontrado para o registro */
                    if (:conta is null) then conta=0;
                    eventoid = :conta;
                end


                if (:tipo=0 or ((:conta=0) and (:tipo  in (2,3,4,5) ))) THEN
                begin  -- insere um registro novo 
                    if (usuario is null) then
                      select usuario from sp_codigo_usuario  into :usuario;

                    insert into
                      eventos_item 
                      (id,pessoa,tabela,idtabela,data, obs,inativo,titulo,
                       autor, arquivado,datalimite,idestado, 
                       idgrupo_estado,cliente,dcto,EVENTOS_AUTO_NOME,
                       ordemtabela,
                       valor,usuario,leu )
                      values(GEN_ID(EVENTOS_ITEMID,1),:pessoa,:tabela,:idtabela, :agora,:historico,'N',:titulo,
                             :autor,'N',:agora+2,:ev_estado,
                             :ev_grupo,:cliente,:dcto,:evento,
                             :ordemtabela,:valor ,:usuario,coalesce(:leu,'N') );

                end

                if ((:conta>0)  and (:tipo=1 or :tipo=2)) THEN /* atualiza um registro existente */
                begin
                    update eventos_item set pessoa=:pessoa, idestado=:ev_estado,
                                        idgrupo_estado=:ev_grupo, leu = :leu
                        where tabela=:tabela and idtabela=:idtabela;
                end

                if ((:conta>0)  and (:tipo=3)) THEN /* muda o estado de um registro ja existente */
                begin

                    update eventos_item set pessoa=:pessoa, idestado=:ev_estado,
                                            idgrupo_estado=:ev_grupo,
                                            obs=:historico, leu = coalesce(:leu,leu)
                            where tabela=:tabela and idtabela=:idtabela;

                end

                if ((:conta>0)  and (:tipo=6)) THEN /* muda o estado de um registro ja existente */
                begin

                    update eventos_item set pessoa=:pessoa, idestado=:ev_estado,
                                            idgrupo_estado=:ev_grupo,
                                            obs=:historico, leu = coalesce(:leu,leu)
                            where master=:master and master_gid=:master_gid;

                end

              if ((:conta>0)  and (:tipo=4))     THEN
              if (:oldEstado<>:ev_estado or (:oldgrupo_estado <>:ev_grupo)) then
              begin   /* muda o estado caso o estado solicitado for superior ao atual */

               select  FIRST 1 idgrupo_estado,idestado,obs from eventos_item
                   where tabela=:tabela
                   and idtabela=:idtabela
               INTO :grupo_atual,:est_atual,:obs ;


               select ordem from eventos_grupos_estados /* pega estado atual do registro */
               where estado=:est_atual and grupo=:grupo_atual
               INTO :pos_atual;

               select ordem from eventos_grupos_estados /* pega estado futuro - proximo */
               where estado=:ev_estado and grupo=:ev_grupo
               INTO :pos_futura;

               if (:pos_futura>:pos_atual) THEN /* se o proximo estado for superior, altera para proximo estado */
               begin
                obs=substring(:obs from 1)||'<br>'||:autor||':'||:titulo;
                update eventos_item set pessoa=:pessoa,
                                        idestado=:ev_estado,
                                        idgrupo_estado=:ev_grupo,
                                        obs=:obs, leu = coalesce(:leu,leu)
                        where tabela=:tabela and idtabela=:idtabela;
               end 
              end


              if ((:conta>0) and (:tipo in (4,5))) then
              if (:oldEstado<>:ev_estado or (:oldgrupo_estado <>:ev_grupo)) then
              begin
                  select usuario from sp_codigo_usuario  into :usuario;
                 /* inserir uma nota relativo ao evento */
                  insert into eventos_item_notas (data,eventosid,texto,pessoa,usuario)
                   values(:agora ,:eventoid,:titulo||'<br>'||:historico,:pessoa,:usuario );
               --  update eventos_item set obs = obs||'<br>'||:titulo where id=:eventoid;

              end
           suspend;
        end
    end
END^
SET TERM ; ^



SET TERM ^ ;

CREATE or alter TRIGGER tr_ctprod_notificacoes FOR CTPROD
ACTIVE BEFORE INSERT POSITION 0
AS 
declare variable pv double precision;
BEGIN 
	/* enter trigger code here */ 
	select first 1 precovenda from ctprod_filial
	where codigo = new.codigo
	into :pv;
	
	if (pv is null) then
	  pv = new.precovenda;
	
		if (INSERTING) then

	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'NOVO-PRODUTO', 
	       
	      'AUTO', 
	      'Novo Produto - '||new.nome, 
	      extract(day from new.DTATUALIZ)||'/'||extract( month from new.DTATUALIZ)||' - '||new.codigo,  
	      0, 
	      '', 
	      'CTPROD', 
	      0, 
	      1, 
	      :pv, 
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      NEW.codigo , -- tabela_gid
	      'N' -- leu
	      );

END^

SET TERM ; ^ 



SET TERM ^ ;

CREATE OR ALTER TRIGGER tr_pdvlogin_notificacoes FOR PDVLOGIN
ACTIVE AFTER INSERT OR UPDATE POSITION 99
AS 
DECLARE VARIABLE VALOR DOUBLE PRECISION;
declare variable nome varchar(50);
BEGIN 
   VALOR = 0;
   select first 1 nome from sigbco
   where codigo = new.caixa
   into :nome;
   if (:nome is null) then nome=:new.caixa;
	/* enter trigger code here */ 
	if (INSERTING) then
	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'ABERTURA-CAIXA', 
	       
	      'AUTO', 
	      '', 
	      :nome ||' abriu o caixa '||new.caixa||' em '||extract(day from new.data)||'/'||extract( month from new.data),  
	      0, 
	      NEW.DCTOINICIO, 
	      'PDVLOGIN', 
	      NEW.ID, 
	      1, 
	      :VALOR,
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      null, -- tabela_gid
	      'N' -- leu
	      );
	if (UPDATING) then
	  IF (NEW.FECHAMENTO IS NOT NULL AND OLD.FECHAMENTO IS NULL) THEN
	  BEGIN
	     SELECT SUM(CASE WHEN CODIGO < '200' THEN VALOR ELSE -VALOR END) FROM SIG02
	     WHERE PRTSERIE = NEW.PRTSERIE
	           AND DATA >=NEW.DATA
	           AND DATAMVTO = NEW.DATAMVTO
	           AND FILIAL = NEW.FILIAL
	           AND DCTO BETWEEN NEW.DCTOINICIO AND NEW.DCTOFINAL
	     INTO :VALOR;      
	     EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'FECHAMENTO-CAIXA', 
	       
	      'AUTO', 
	      'CAIXA '||new.caixa,
	      :nome ||' fechou o caixa '||extract(day from new.data)||'/'||extract( month from new.data),  
	      0, 
	      NEW.DCTOINICIO, 
	      'PDVLOGIN', 
	      NEW.ID, 
	      1, 
	      :VALOR,
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      null, -- tabela_gid
	      'N' -- leu
	      );
	  END 
END^

SET TERM ; ^ 


SET TERM ^ ;

CREATE or alter TRIGGER tr_sigcad_notificacoes FOR sigcad
ACTIVE BEFORE INSERT POSITION 99
AS 

BEGIN 
	/* enter trigger code here */ 
		if (INSERTING) then

	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'NOVO-CLIENTE', 
	       
	      'AUTO', 
	      'Novo Cliente - '||new.nome, 
	      'Em: '||extract(day from new.DATA)||'/'||extract( month from new.DATA)||' - '||cast(new.codigo as integer)||' '||coalesce(new.cidade,''),  
	      new.codigo, 
	      '', 
	      'SIGCAD', 
	      NEW.CODIGO,  -- ID 
	      1, 
	      new.DEBITO, 
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      null , -- tabela_gid
	      'N' -- leu
	      );

END^

SET TERM ; ^ 

SET TERM  ^; 

CREATE or alter TRIGGER tr_sigven_notificacoes FOR sigven
ACTIVE BEFORE INSERT POSITION 99
AS 
declare variable data timestamp;
BEGIN 
    data = cast('now' as timestamp);
	/* enter trigger code here */ 
    if (INSERTING) then

	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'NOVO-VENDEDOR', 
	       
	      'AUTO', 
	      'Novo Vendedor - '||new.nome, 
	      extract(day from :DATA)||'/'||extract( month from :DATA)||' - '||new.codigo,  
	      0, 
	      '', 
	      'SIGVEN', -- tabela
	      0, --NEW.CODIGO,  -- ID 
	      1, -- ordem
	      0,  -- valor
	      null ,--usuario
	      NULL, -- master
	      NULL, -- master_gid
	      NEW.codigo , -- tabela_gid
	      'N' -- leu
	      );

END^

SET TERM ; ^ 



SET TERM  ^; 

CREATE or alter TRIGGER tr_sig02_notificacoes FOR sig02
ACTIVE BEFORE INSERT POSITION 99
AS 
declare variable data timestamp;
declare variable nome varchar(50);
declare variable nomeOperacao varchar(50);
declare variable somaVendas integer;

BEGIN 
    data = cast('now' as timestamp);
    select first 1 nome, somaVendas from estoper
    where codigo=new.codigo
    into :nomeOperacao, :somaVendas;

    IF (:nomeOperacao is null) then
        select nome from sig01 where codigo = new.codigo 
        into :nomeOperacao;
    
    select nome from sigbco
    where codigo = new.banco
    into :nome;
    
	/* enter trigger code here */ 
    if (INSERTING) then
    begin
	 if (somaVendas=1) then
	 begin
      if (new.codigo<'200' and new.valor>0) then
	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'VENDA-FECHADA', 
	       
	      'AUTO', 
	      'Venda - '||nomeOperacao, 
	      'Vendas efetuada por ('||trim(new.banco)||')'||coalesce(:nome,new.banco)||'-'||coalesce(new.ecf,''),  
	      new.clifor, -- cliente 
	      NEW.dcto, 
	      'SIG02', -- tabela
	      new.id, --NEW.CODIGO,  -- ID 
	      1, -- ordem
	      new.valor,  -- valor
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      null , -- tabela_gid
	      'N' -- leu
	      );
	  if (new.codigo='231') then    
	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'VENDA-DEVOLUCAO', 
	       
	      'AUTO', 
	      'Devolucao - '||new.historico, 
	      'Devolucao efetuada por '||coalesce(:nome,new.banco)||'-'||coalesce(new.ecf,'')||' do cliente ('||cast(new.clifor as integer)||') '||coalesce(new.EMITENTE,''),  
	      new.clifor, -- cliente 
	      NEW.dcto, 
	      'SIG02', -- tabela
	      new.id, --NEW.CODIGO,  -- ID 
	      1, -- ordem
	      new.valor,  -- valor
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      null , -- tabela_gid
	      'N' -- leu
	      );
	  if (new.codigo<'200' and new.valor<=0) then    
	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'VENDA-CANCELADA', 
	       
	      'AUTO', 
	      'Vda Cancelada - '||new.historico, 
	      'Cancelamento em '||extract(day from :DATA)||'/'||extract( month from :DATA)|| ' por '||coalesce(:nome,new.banco)||'-'||coalesce(new.ecf,'')||' cliente: '||cast(new.clifor as integer)||'-'||coalesce(new.EMITENTE,''),  
	      new.clifor, -- cliente 
	      NEW.dcto, 
	      'SIG02', -- tabela
	      new.id, --NEW.CODIGO,  -- ID 
	      1, -- ordem
	      new.valor,  -- valor
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      null , -- tabela_gid
	      'N' -- leu
	      );
    end
    if (coalesce(somaVendas,0)=0) then
    BEGIN
      if ( new.valor>0) then
	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'VENDA-FECHADA', 
	       
	      'AUTO', 
	      ''||nomeOperacao, 
	      'Efetuado por ('||trim(new.banco)||')'||coalesce(:nome,new.banco)||'-'||coalesce(new.ecf,''),  
	      new.clifor, -- cliente 
	      NEW.dcto, 
	      'SIG02', -- tabela
	      new.id, --NEW.CODIGO,  -- ID 
	      1, -- ordem
	      new.valor,  -- valor
	      null ,--usuario
	      null, -- master
	      null, -- master_gid
	      null , -- tabela_gid
	      'N' -- leu
	      );
    END
   end
END^

SET TERM ; ^ 


SET TERM  ^; 

CREATE or alter TRIGGER tr_sigcaut2_notificacoes FOR sigcaut2
ACTIVE BEFORE INSERT POSITION 99
AS 
declare variable data timestamp;
BEGIN 
    data = cast('now' as timestamp);
	/* enter trigger code here */ 
    if (INSERTING) then
    begin
     if (new.qtde=0) THEN
	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'VENDA-ITEM-CANCELADO', 
	      'AUTO', 
	      'Item cancelado - '||new.nome, 
	      extract(day from :DATA)||'/'||extract( month from :DATA)||' - '||new.codigo,  
	      new.clifor, -- cliente 
	      '', 
	      'SIGCAUT2', -- tabela
	      NEW.ID,   -- ID 
	      NEW.ORDEM, -- ordem
	      NEW.VALOR,  -- valor
	      null ,--usuario
	      NULL, -- master
	      NULL, -- master_gid
	      NEW.codigo , -- tabela_gid
	      'N' -- leu
	      );
	end      

END^

SET TERM ; ^ 



SET TERM  ^; 

CREATE or alter TRIGGER tr_ctprodsd_notificacoes FOR CTPRODSD
ACTIVE BEFORE INSERT POSITION 99
AS 
declare variable data timestamp;
declare variable nome varchar(50);
declare variable ppedido double precision;
declare variable estminimo double precision;
declare variable estminimo_filial double precision;
BEGIN 
    data = cast('now' as timestamp);
	/* enter trigger code here */ 
    if (updating) then
    begin
    
     select nome, coalesce(estminimo,0) from ctprod where codigo = new.codigo
     into :nome,:estminimo;
    
     select coalesce(ppedido,0), coalesce(estminimo,0) from ctprod_filial
     where codigo=new.codigo and filial=new.filial
     into :ppedido, :estminimo_filial;
     
     
     if (ppedido>estminimo) then
        estminimo = ppedido;
    
     if (estminimo_filial>estminimo) then
        estminimo = estminimo_filial;
     
    
     if ((new.qestfin<=0)  
       or (estminimo>0 and :estminimo >= new.qestfin)
     ) THEN
	   EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'ESTOQUE-MINIMO', 
	      'AUTO', 
	      'Estoque Seguranca - '||:nome, 
	      extract(day from :DATA)||'/'||extract( month from :DATA)||' - '||new.codigo|| ' Estoque: '||cast(new.qestfin as integer)||'/'||cast(coalesce(:ppedido,0) as integer),  
	      0, -- cliente 
	      '', 
	      'CTPRODSD', -- tabela
	      NEW.ID,   -- ID 
	      0, -- ordem
	      0,  -- valor
	      null ,--usuario
	      NULL, -- master
	      NULL, -- master_gid
	      NEW.codigo , -- tabela_gid
	      'N' -- leu
	      );
	end      

END^



CREATE or alter TRIGGER tr_senhas_notificacoes FOR senhas
ACTIVE AFTER INSERT or UPDATE POSITION 99
as
begin
  if (inserting) then
     execute procedure REGISTRA_EVENTO_EX(0,'ALTERACAO-USUARIO','AUTO','Novo Usuario',
     'Usuario '|| new.nome || ' foi incluido',
     0,
     new.codigo,
     'SENHAS',
     new.codigo,
     0,
     0,
     null,null,null,new.codigo,'N');
     

  if (updating and (new.md5 <> old.md5 or new.senha <> old.senha) ) then
     execute procedure REGISTRA_EVENTO_EX(0,'ALTERACAO-USUARIO','AUTO','Usuario trocou senha',
     'Usuario '|| new.nome || ' trocou a senha de acesso',
     0,
     new.codigo,
     'SENHAS',
     new.codigo,
     0,
     0,
     null,null,null,new.codigo,'N');

  if (updating and (new.FUNCAO<>old.FUNCAO) ) then
     execute procedure REGISTRA_EVENTO_EX(0,'ALTERACAO-USUARIO','AUTO','Usuario trocou funcao',
     'Usuario '|| new.nome || ' trocou funcao de acesso: '||new.FUNCAO,
     0,
     new.codigo,
     'SENHAS',
     new.codigo,
     0,
     0,
     null,null,null,new.codigo,'N');

if (updating and (new.grupo<>old.grupo) ) then
     execute procedure REGISTRA_EVENTO_EX(0,'ALTERACAO-USUARIO','AUTO','Usuario trocou grupo',
     'Usuario '|| new.nome || ' trocou grupo de acesso: '||new.grupo,
     0,
     new.codigo,
     'SENHAS',
     new.codigo,
     0,
     0,
     null,null,null,new.codigo,'N');


end^


SET TERM ; ^ 






GRANT EXECUTE
 ON PROCEDURE REGISTRA_EVENTO_ex TO  PUBLICWEB;

GRANT EXECUTE
 ON PROCEDURE REGISTRA_EVENTO_Ex TO  SYSDBA;

GRANT EXECUTE
 ON PROCEDURE REGISTRA_EVENTO_Ex TO  WBA;


grant select on EVENTOS_AUTO to publicweb;

grant select, insert, update,delete on eventos_assinar to publicweb;

commit work;



set term ^;
execute block 
as
declare  conta int ;
begin
  select count(*) x 
  from eventos_assinar where pessoa='1'
  into :conta;
  if (coalesce(conta,0)=0) then
  begin 
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('15.02.2021, 06:00:00.000', 'ABERTURA-CAIXA', '1.000000', '1.000000', '1', 'N', '81EE0444-B165-4195-AB0E-F9466F064275', 'Abertura de caixa no PDV');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 23:08:04.000', 'NOVO-PRODUTO', '1.000000', '1.000000', '1', 'N', 'CC4FC519-3074-42A5-A75E-F9A5907718AF', 'Cadastro de novo produto');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('15.02.2021, 12:00:00.000', 'FECHAMENTO-CAIXA', '1.000000', '1.000000', '1', 'N', '81EE0444-B165-4195-AB0E-F9466F064277', 'Caixa fechado no PDV');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 11:13:43.000', 'NOVO-CLIENTE', '1.000000', '1.000000', '1', 'N', '628acd8a-0bac-4231-8ce8-8f35e11deba3', 'Notificacao cadastro de novo cliente');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 17:13:44.000', 'NOVO-VENDEDOR', '1.000000', '1.000000', '1', 'N', '1e514dae-350e-455a-917e-76c0201ccb9e', 'Cadastro de novo vendedor');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 12:46:30.000', 'VENDA-DEVOLUCAO', '1.000000', '1.000000', '1', 'N', 'c8609b11-2e57-4e09-ad7c-59ebb4fd8b91', 'Devolucao de Venda');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 12:47:51.000', 'ESTOQUE-MINIMO', '1.000000', '1.000000', '1', 'N', 'c2db0b00-2917-49fd-992c-ce786809b854', 'Atingiu estoque minimo');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('19.02.2021, 10:15:03.000', 'INFO-CAST', '1.000000', '1.000000', '1', 'N', '257b6621-ca28-4196-a8e2-8f77d21cbe23', 'Assinar INFO-CAST');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 12:46:55.000', 'VENDA-ITEM-CANCELADO', '1.000000', '1.000000', '1', 'N', '9e11a9e4-f2bc-4ba8-b127-64fc6a1baf45', 'Item de venda cancelado');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 12:46:56.000', 'VENDA-CANCELADA', '1.000000', '1.000000', '1', 'N', '059ee45a-e665-4e58-aee9-7c685517c8c0', 'Venda cancelada');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 12:46:57.000', 'VENDA-FECHADA', '1.000000', '1.000000', '1', 'N', '8c8d4cc8-eaa3-4ae1-9d03-b50b1e58b24c', 'Venda fechada');
    INSERT INTO EVENTOS_ASSINAR (DATA, EV_NOME, EV_GRUPO, EV_ESTADO, PESSOA, INATIVO, GID, DESCRICAO) VALUES ('16.02.2021, 12:46:57.000', 'ALTERACAO-USUARIO', '1.000000', '1.000000', '1', 'N', '8c8d4cc8-eaa3-4ae1-9d03-b50b1e58b24c', 'Alteracao Usuario');
  end  
end^
set term ;^

commit work;



commit work;
