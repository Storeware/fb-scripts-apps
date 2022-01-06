

/* passar para o StoreSetup */
CREATE TABLE SIG02_TICKETMEDIO_DATA
(
  DATA Timestamp NOT NULL,
  FILIAL Float NOT NULL,
  VALOR Float NOT NULL,
  OCORRENCIAS Float,
  TICKET_MEDIO Float,
  CONSTRAINT PK_SIG02_TICKETMEDIO_DATA PRIMARY KEY (DATA,FILIAL)
);

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIG02_TICKETMEDIO_DATA TO  SYSDBA WITH GRANT OPTION;



/* estao no StoreSetup */
ALTER TABLE CTPROD_FILIAL ADD ESTMINIMO DOUBLE PRECISION; -- Estoque minimo digitado para a Filial
ALTER TABLE EVENTOS_ITEM ADD LEU VARCHAR(1); -- permite marcar se uma mensagem foi lida - S ou N
ALTER TABLE SIGCX ADD TIPO VARCHAR(1);  -- compatibilidade com a SIG02

CREATE TABLE SIGCAUT1_HORA
(
  CODIGO varChar(18) NOT NULL,
  DATA date NOT NULL,
  HORA varChar(2) NOT NULL,
  QTDE Double precision,
  GRUPO varChar(10),
  total double precision default 0,
  FILIAL Double precision DEFAULT 0 NOT NULL,
  CONSTRAINT PK_SIGCAUT1_HORA PRIMARY KEY (CODIGO,DATA,HORA,FILIAL)
);

CREATE INDEX SIGCAUT1_HORA_IDX1 ON SIGCAUT1_HORA (CODIGO,DATA,HORA);
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIGCAUT1_HORA TO  SYSDBA WITH GRANT OPTION;

 alter table sigcaut2_hora add total double precision;

create desc index  sigcaddata_desc on sigcad (data);
create desc index ctprod_dtatualiz_desc on ctprod(dtatualiz);

alter table CTPROD_ATALHO_TITULO add conta int;

alter table  pet_agenda add primary key (gid);
alter table agenda_tipo add requerContato varchar(1);

alter table agenda_recurso add intervalo numeric(10,2);
alter table estmvto add qestant double precision;

create table sigbco_saldos
   (codigo varchar(10) not null,
    valor double precision,
    dtatualiz date,
    primary key  (codigo)
    );
    
    
alter table sigcx add saldoAnt double precision;   


CREATE TABLE SIGBCO_SALDOS
(
  CODIGO Varchar(10) NOT NULL,
  VALOR Double precision,
  DTATUALIZ Timestamp,
  PRIMARY KEY (CODIGO)
);
GRANT INSERT, SELECT, UPDATE
 ON SIGBCO_SALDOS TO ROLE PUBLICWEB;

alter table sigflu add baixa_automatica integer;
alter table sigflu add baixa_banco varchar(10);
alter table sigflu add baixa_dtpgto date;
alter table sigflu add baixa_valor float;
alter table sigflu add baixa_dcto varchar(10);

alter table eventos_item add master_gid varchar(38);
alter table eventos_item add tabela_gid varchar(38);
alter table eventos_item add leu varchar(1);
alter table eventos_item add master varchar(128);

alter table SIGCAUTP add codTrans varchar(10);

alter table PET_ATENDIMENTO_ITENS add gid varchar(38);
alter table PET_ATENDIMENTO add gid varchar(38);


CREATE TABLE PET_ATENDIMENTO_ESTADOS
(
  GID Varchar(38) NOT NULL,
  NOME Varchar(32),
  PRIMARY KEY (GID)
);
GRANT DELETE, INSERT, SELECT, UPDATE
 ON PET_ATENDIMENTO_ESTADOS TO PUBLICWEB;

-- alter table pet_atendimento add gid varchar(38);
create index idx_pet_atendimentoGid on pet_atendimento(gid);

alter table PET_ATENDIMENTO_ITENS add gid varchar(38);
create index idx_pet_atendimentoItensGid on pet_atendimento_itens(gid);

CREATE TABLE SIGCAD_ENDER
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
);


alter table sigcautp alter  dcto set not null;
alter table sigcautp alter data set not null;
alter table sigcautp alter ordem set not null;
alter table sigcautp alter filial set not null;
alter table sigcautp alter sigcauthlote set not null;
ALTER TABLE sigcautp ADD CONSTRAINT PK_sigcautp PRIMARY KEY (dcto,data,filial,ordem,sigcauthlote);

execute procedure RDB$DROP_PROCEDURE('sp_saldoanterior_sigbco');
execute procedure RDB$DROP_PROCEDURE('sp_saldoatual_sigbco');
drop table SIGBCO_SALDO;


alter table sigcauth alter bairroentr type varchar(128);

alter table eventos_assinar add descricao varchar(128);

commit;
