set term ^;
execute block
as
BEGIN

execute procedure RDB$DROP_PROCEDURE('sp_saldoanterior_sigbco');
execute procedure RDB$DROP_PROCEDURE('sp_saldoatual_sigbco');
 if (exists_table('SIGBCO_SALDO')=1) THEN
    execute statement 'drop table SIGBCO_SALDO';
when any do
BEGIN

end


end^
set term ;^

/* passar para o StoreSetup */
select executeIf_not_exists(exists_table('SIG02_TICKETMEDIO_DATA'),
'CREATE TABLE SIG02_TICKETMEDIO_DATA
(
  DATA Timestamp NOT NULL,
  FILIAL Float NOT NULL,
  VALOR Float NOT NULL,
  OCORRENCIAS Float,
  TICKET_MEDIO Float,
  CONSTRAINT PK_SIG02_TICKETMEDIO_DATA PRIMARY KEY (DATA,FILIAL)
);') from dummy;

commit;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIG02_TICKETMEDIO_DATA TO  SYSDBA WITH GRANT OPTION;



/* estao no StoreSetup */
select executeif_not_exists(exists_column('CTPROD_FILIAL','ESTMINIMO'),
          'ALTER TABLE CTPROD_FILIAL ADD ESTMINIMO DOUBLE PRECISION; -- Estoque minimo digitado para a Filial')
FROM DUMMY;          

select executeif_not_exists(exists_column('EVENTOS_ITEM','LEU'),          
    'ALTER TABLE EVENTOS_ITEM ADD LEU VARCHAR(1); -- permite marcar se uma mensagem foi lida - S ou N')
FROM DUMMY;
    
select executeif_not_exists(exists_column('SIGCX','TIPO'),    
        'ALTER TABLE SIGCX ADD TIPO VARCHAR(1);  -- compatibilidade com a SIG02')
FROM DUMMY;        

select executeif_not_exists(exists_table('SIGCAUT1_HORA'),
'CREATE TABLE SIGCAUT1_HORA
(
  CODIGO varChar(18) NOT NULL,
  DATA date NOT NULL,
  HORA varChar(2) NOT NULL,
  QTDE Double precision,
  GRUPO varChar(10),
  total double precision default 0,
  FILIAL Double precision DEFAULT 0 NOT NULL,
  CONSTRAINT PK_SIGCAUT1_HORA PRIMARY KEY (CODIGO,DATA,HORA,FILIAL)
);') FROM DUMMY;

select executeIf_not_exists(exists_indice('SIGCAUT1_HORA_IDX1'),  
    'CREATE INDEX SIGCAUT1_HORA_IDX1 ON SIGCAUT1_HORA (CODIGO,DATA,HORA);') from dummy;
    
    
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIGCAUT1_HORA TO  SYSDBA WITH GRANT OPTION;

SELECT createColumn_not_exists('SIGCAUT2_HORA','TOTAL','double precision') ,
       executeif_not_exists(exists_indice('sigcaddata_desc'), 'create desc index  sigcaddata_desc on sigcad (data);'),
       executeif_not_exists(exists_indice('ctprod_dtatualiz_desc'), 'create desc index ctprod_dtatualiz_desc on ctprod(dtatualiz);'),

       createColumn_not_exists('CTPROD_ATALHO_TITULO','conta','int'),

       createColumn_not_exists('agenda_tipo','requerContato', 'varchar(1)'),

       createColumn_not_exists('agenda_recurso','intervalo', 'numeric(10,2)'),
       createColumn_not_exists('estmvto' ,'qestant', 'double precision')
    ,executeif_not_exists( exists_primary_Key('pet_agenda'),
            'alter table  pet_agenda add primary key (gid)')

    ,executeif_not_exists(exists_table('sigbco_saldos'),
    'create table sigbco_saldos
   (codigo varchar(10) not null,
    valor double precision,
    dtatualiz date,
    primary key  (codigo)
    );')

,createColumn_not_exists('sigcx','saldoAnt', 'double precision')   



FROM DUMMY;

/*   
revoke all on all from publicweb;   
revoke all on all from role publicweb;   
create role PUBLICWEB;
*/

GRANT INSERT, SELECT, UPDATE
 ON SIGBCO_SALDOS TO ROLE PUBLICWEB;



select 
  createColumn_not_exists('sigflu','baixa_automatica', 'integer')
,createColumn_not_exists('sigflu','baixa_banco', 'varchar(10)')
,createColumn_not_exists('sigflu','baixa_dtpgto', 'date')
,createColumn_not_exists('sigflu' ,'baixa_valor', 'float')
,createColumn_not_exists('sigflu', 'baixa_dcto', 'varchar(10)')

,createColumn_not_exists('eventos_item', 'master_gid', 'varchar(38)')
,createColumn_not_exists('eventos_item', 'tabela_gid','varchar(38)')
,createColumn_not_exists('eventos_item','leu', 'varchar(1)')
,createColumn_not_exists('eventos_item','master' ,'varchar(128)')

,createColumn_not_exists('SIGCAUTP' ,'codTrans', 'varchar(10)')

,createColumn_not_exists('PET_ATENDIMENTO_ITENS', 'gid', 'varchar(38)')
,createColumn_not_exists('PET_ATENDIMENTO','gid', 'varchar(38)')


,executeif_not_exists(exists_table('PET_ATENDIMENTO_ESTADOS'),
'CREATE TABLE PET_ATENDIMENTO_ESTADOS
(
  GID Varchar(38) NOT NULL,
  NOME Varchar(32),
  PRIMARY KEY (GID)
)')

from dummy;


GRANT DELETE, INSERT, SELECT, UPDATE
 ON PET_ATENDIMENTO_ESTADOS TO PUBLICWEB;


select

-- alter table pet_atendimento add gid varchar(38); 
 executeif_not_exists(exists_indice('idx_pet_atendimentoGid'),  'create index idx_pet_atendimentoGid on pet_atendimento(gid)')

, createColumn_not_exists('PET_ATENDIMENTO_ITENS','gid', 'varchar(38)')
, executeif_not_exists(exists_indice('idx_pet_atendimentoItensGid'), 'create index idx_pet_atendimentoItensGid on pet_atendimento_itens(gid)')

, executeif_not_exists(exists_table('SIGCAD_ENDER'),
'CREATE TABLE SIGCAD_ENDER
(
  CODIGO Double precision NOT NULL,
  ORDEM Integer NOT NULL,
  TIPO Varchar(10),
  PRINCIPAL Varchar(1),
  ENDER Varchar(50),
  NUMERO Varchar(20),
  CIDADE Varchar(50),
  ESTADO Varchar(10),
  CEP Varchar(10),
  CNPJ Varchar(18),
  IE Varchar(18),
  BAIRRO Varchar(50),
  CONTATO Varchar(50),
  OBS Varchar(128),
  PRIMARY KEY (CODIGO,ORDEM)
)')
from dummy;



alter table sigcautp alter  dcto set not null;
alter table sigcautp alter data set not null;
alter table sigcautp alter ordem set not null;
alter table sigcautp alter filial set not null;
alter table sigcautp alter sigcauthlote set not null;

select 
  executeif_not_exists(exists_primary_key('sigcautp'), 'ALTER TABLE sigcautp ADD CONSTRAINT PK_sigcautp PRIMARY KEY (dcto,data,filial,ordem,sigcauthlote)')
, createColumn_not_exists('eventos_assinar', 'descricao', 'varchar(128)')
from dummy;  


alter table sigcauth alter bairroentr type varchar(128);


ALTER EXCEPTION JA_EXISTE_CNPJ '\O CNPJ Indicado encontra-se cadastrado para outra pessoa';

commit;




select 
 executeif_not_exists(exists_table('ctprodsd_consignado'),
'create table ctprodsd_consignado
  (codigo varchar(18) not null,
   clifor double precision not null,
   qtde double precision,
   primary key( codigo,clifor )
  ) 
')
,createColumn_not_exists('ctprodsd_consignado','dtatualiz', 'date')

, executeif_not_exists(exists_table('sigbco_saldos'),
'create table sigbco_saldos
   (codigo varchar(10) not null,
    valor double precision,
    dtatualiz date,
    primary key  (codigo)
    )')
, createColumn_not_exists('sigcx', 'saldoAnt' ,'double precision')   
from dummy;



select 
-- pet_atendimento 
 createColumn_not_exists('pet_atendimento','estado_gid', "varchar(38) default '1'")
,createColumn_not_exists('pet_atendimento','ordem_lista', 'integer default 0')



--tabela de estados 
,executeif_not_exists( exists_table('pet_atendimento_estados'),   
"create table pet_atendimento_estados (
    gid varchar(38) not null, 
    nome varchar(32),
    concluido varchar(1) default 'N',
    primary key (gid)
  )")

,createColumn_not_exists('sigcad','nome_upper', 'computed by (upper(nome))')
,createColumn_not_exists('ctprod' ,'nome_upper', 'computed by (upper(nome))')
,executeif_not_exists(exists_indice('sigcad_uppercase_nome'),'create index sigcad_uppercase_nome on sigcad computed by (upper(nome))')
,executeif_not_exists(exists_indice('ctprod_uppercase_nome'),'create index ctprod_uppercase_nome on ctprod computed by (upper(nome))')

from dummy;

commit;
  update pet_atendimento set ordem_lista=9999 where ordem_lista is null;
  update pet_atendimento set estado_gid='1' where  estado_gid is null;
commit;




CREATE or alter VIEW WBA_CTPROD_FAVORITOS
AS select * from ctprod_favoritos;

CREATE or alter VIEW WBA_CTPROD_ATALHO_TITULO 
AS select * from ctprod_atalho_titulo;

CREATE or alter VIEW WEB_CLIENTES (CODIGO, NOME, CNPJ, CIDADE, BAIRRO, NUMERO, COMPL, ENDER, ESTADO, CEP, CELULAR, CPFNA_NOTA, EMAIL)
AS select codigo,nome,cnpj,
       cidade,bairro,numero,compl,ender,estado,
       cep,celular,cpfna_nota,email from sigcad;


