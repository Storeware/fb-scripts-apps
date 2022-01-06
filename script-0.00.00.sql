/*
  grants
*/

create  role publicweb;

  
grant select on wba_ctprod_unidade to publicweb;
grant select on wba_ctprod_unidade to wba;
grant select on kpi_vendas to publicweb;
grant all on sigcaut1 to publicweb;
grant select on sigcauth to publicweb;
grant select,update,delete on sigcaut1estados to publicweb;
grant select,update,delete on sigcaut1armaz to publicweb;

/*
  Codigos
*/



CREATE OR ALTER VIEW WBA_SIGCAUTH(
    ID,
    DCTO,
    FILIAL,
    CLIENTE,
    VENDEDOR,
    TOTAL,
    OBS,
    TABELA,
    CCUSTO,
    CCUSTOAUX,
    FORMPGTO,
    NRPARC,
    CODTAB,
    AGENTE,
    DTENT_RET,
    ENTREGA,
    PZOSTRING,
    ENDENTR,
    BAIRROENTR,
    CIDADEENTR,
    ESTADOENTR,
    CNPJENTR,
    IEENTR,
    VALORIPI,
    FILIALRETIRA,
    EXPEDICAO,
    IMPRESSO,
    DTCANCELADO,
    HORA,
    SINCRONIZADO,
    PLACA,
    PLACALOCAL,
    TRANSP,
    VALORTROCO,
    QTDEPESSOA,
    CONTROL,
    OPERADOR,
    LOTE,
    COBRATAXA,
    CONTATRAVADA,
    CONTROLEIMPRESSAO,
    ENTREGADOR,
    OPERACAO,
    DATA,
    DAV,
    CEPENTR,
    CPF,
    DCTO_INTEGRACAO,
    CFOP,
    REGISTRADO,
    VOLQTDE,
    VOLESPECIE,
    VOLMARCA,
    VOLNUMERO,
    VOLBRUTO,
    VOLLIQUIDO,
    PREVENDA,
    BASEICMSSUBST,
    ICMSSUBST,
    TRFRETE,
    NUMEROENTR,
    COMPLEMENTOENTR,
    MOEDA_EX,
    CONSUMACAOMINIMA,
    FONE,
    CRM_ORIGEM_GID,
    EXPLCOD,
    EXPLCOD_QTDE,
    REFERENCIAENTR,
    AGENDADO)
AS
select ID,
    DCTO,
    FILIAL,
    CLIENTE,
    VENDEDOR,
    TOTAL,
    OBS,
    TABELA,
    CCUSTO,
    CCUSTOAUX,
    FORMPGTO,
    NRPARC,
    CODTAB,
    AGENTE,
    DTENT_RET,
    ENTREGA,
    PZOSTRING,
    ENDENTR,
    BAIRROENTR,
    CIDADEENTR,
    ESTADOENTR,
    CNPJENTR,
    IEENTR,
    VALORIPI,
    FILIALRETIRA,
    EXPEDICAO,
    IMPRESSO,
    DTCANCELADO,
    HORA,
    SINCRONIZADO,
    PLACA,
    PLACALOCAL,
    TRANSP,
    VALORTROCO,
    QTDEPESSOA,
    CONTROL,
    OPERADOR,
    LOTE,
    COBRATAXA,
    CONTATRAVADA,
    CONTROLEIMPRESSAO,
    ENTREGADOR,
    OPERACAO,
    DATA,
    DAV,
    CEPENTR,
    CPF,
    DCTO_INTEGRACAO,
    CFOP,
    REGISTRADO,
    VOLQTDE,
    VOLESPECIE,
    VOLMARCA,
    VOLNUMERO,
    VOLBRUTO,
    VOLLIQUIDO,
    PREVENDA,
    BASEICMSSUBST,
    ICMSSUBST,
    TRFRETE,
    NUMEROENTR,
    COMPLEMENTOENTR,
    MOEDA_EX,
    CONSUMACAOMINIMA,
    FONE,
    CRM_ORIGEM_GID,
    EXPLCOD,
    EXPLCOD_QTDE,
    REFERENCIAENTR,
    AGENDADO from sigcauth
;
grant select on wba_sigcauth to publicweb;


CREATE OR ALTER VIEW WBA_SIGCAUT1(
    CODIGO,
    DATA,
    DCTO,
    ID,
    PRECO,
    FILIAL,
    QTDE,
    BAIXADO,
    CLIFOR,
    COMPL,
    EMPRESA,
    ESTACAO,
    FORMAPGTO,
    HORA,
    HRBAIXA,
    ICMS,
    IPI,
    IRF,
    ISS,
    MESA,
    NOME,
    OLDCTO,
    OPERACAO,
    PERC_DESC,
    PRECOBASE,
    PRECO_BASE,
    QTDEBAIXA,
    QTDE_ORIGI,
    REGISTRADO,
    SAIDA,
    TERMINAL,
    VENDEDOR,
    CODTAB,
    ORDEM,
    ESTADO,
    FIL_PROD,
    FIL_ENTR,
    DATA_ENTR,
    HORA_ENTR,
    LOCAL_ARMAZ,
    FILIALPROD,
    ESTPROD,
    LOCALARMAZENAMENTO,
    OBS,
    DATAPROD,
    DCTOID,
    HRESTADO,
    TOTAL,
    REMESSA,
    IMPRESSO,
    CODIGOREFER,
    MESAANTERIOR,
    APL_SERVICO,
    IDGRADECOR,
    IDGRADETAM,
    SIGCAUTHLOTE,
    IMPRIMEIMEDIATO,
    DESCRATEIO,
    ACRESRATEIO,
    NUMPEDCLI,
    CODPRODCLI,
    DCTO_INTEGRACAO,
    COD_IPI,
    PERC_IPI,
    VALOR_IPI,
    CTPRODX_CODIGO,
    NUMDAV,
    CANCELADO,
    USUARIO,
    QTDECANC,
    LOCALTERMINAL,
    MOEDA_EX,
    PRECOVENDA_EX,
    COTACAO_MOEDA,
    OLDDCTO,
    CRM_ORIGEM_GID,
    NOME_LONGO)
AS
select CODIGO,
    DATA,
    DCTO,
    ID,
    PRECO,
    FILIAL,
    QTDE,
    BAIXADO,
    CLIFOR,
    COMPL,
    EMPRESA,
    ESTACAO,
    FORMAPGTO,
    HORA,
    HRBAIXA,
    ICMS,
    IPI,
    IRF,
    ISS,
    MESA,
    NOME,
    OLDCTO,
    OPERACAO,
    PERC_DESC,
    PRECOBASE,
    PRECO_BASE,
    QTDEBAIXA,
    QTDE_ORIGI,
    REGISTRADO,
    SAIDA,
    TERMINAL,
    VENDEDOR,
    CODTAB,
    ORDEM,
    ESTADO,
    FIL_PROD,
    FIL_ENTR,
    DATA_ENTR,
    HORA_ENTR,
    LOCAL_ARMAZ,
    FILIALPROD,
    ESTPROD,
    LOCALARMAZENAMENTO,
    OBS,
    DATAPROD,
    DCTOID,
    HRESTADO,
    TOTAL,
    REMESSA,
    IMPRESSO,
    CODIGOREFER,
    MESAANTERIOR,
    APL_SERVICO,
    IDGRADECOR,
    IDGRADETAM,
    SIGCAUTHLOTE,
    IMPRIMEIMEDIATO,
    DESCRATEIO,
    ACRESRATEIO,
    NUMPEDCLI,
    CODPRODCLI,
    DCTO_INTEGRACAO,
    COD_IPI,
    PERC_IPI,
    VALOR_IPI,
    CTPRODX_CODIGO,
    NUMDAV,
    CANCELADO,
    USUARIO,
    QTDECANC,
    LOCALTERMINAL,
    MOEDA_EX,
    PRECOVENDA_EX,
    COTACAO_MOEDA,
    OLDDCTO,
    CRM_ORIGEM_GID,
    NOME_LONGO from sigcaut1
;
grant select on wba_sigcaut1 to publicweb;




CREATE or alter VIEW WBA_SIGCAUT1EST (ID, CODIGO, NOME, ESTCONCLUIDO, QTDEESTADOPARA, PDVESTADOPARA, PDVPODEFECHAR)
AS 
SELECT   ID, CODIGO, NOME, ESTCONCLUIDO, QTDEESTADOPARA, PDVESTADOPARA, PDVPODEFECHAR
               FROM SIGCAUT1ESTADOS;


GRANT INSERT, SELECT, UPDATE
 ON WBA_SIGCAUT1EST TO  publicweb WITH GRANT OPTION;



/*
  muda os estado de produtos
*/
SET TERM ^ ;
CREATE or alter TRIGGER SIGCAUT1_MUDA_ESTADO FOR SIGCAUT1 ACTIVE
BEFORE UPDATE POSITION 0
AS
  declare  novoEstado integer;
  
begin
  /* Trigger text */
  IF (updating) THEN
  begin
  
      if (new.LOCALARMAZENAMENTO<>coalesce(old.LOCALARMAZENAMENTO,''))
      then
      begin
         select first 1 estado from sigcaut1armaz z
           where new.LOCALARMAZENAMENTO between z.de and z.ate
           and filial = new.filial
           into :novoestado;
         if ( (coalesce(:novoestado,0)>0) and (new.estprod<:novoestado )) then
            new.estprod = :novoestado;
      
        if (novoestado is null) then
         select first 1 estado from sigcaut1armaz z
           where new.LOCALARMAZENAMENTO between z.de and z.ate
           and filial = 0
           into :novoestado;
         if ( (coalesce(:novoestado,0)>0) and (new.estprod<:novoestado )) then
            new.estprod = :novoestado;

      end
         
      if (new.qtdebaixa>=new.qtde) then
      begin
        select first 1 pdvEstadoPara from sigcaut1estados
           where codigo=new.estprod and estConcluido='S'
           into :novoestado  ;
        if ((:novoestado>0) and (new.estprod<:novoestado)) then
          new.estprod = :novoestado;
      end
  
      IF (NEW.estprod <> OLD.ESTPROD) THEN
         NEW.HRESTADO = 'NOW';
  
  end
  
  
  IF (inserting) THEN NEW.HRESTADO='NOW';
  if (new.id = 0) then
     new.id = gen_id(sigcaut1id, 1);
  
end^
SET TERM ; ^
