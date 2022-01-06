SET TERM ^ ;


/*
precisa estudar o funcionamento com Procedure,
se precisar acrescentar um coluna nova, vamos ter problemas,
porque não pode rodar versão velha e nova ao mesmo tempo
com procedure de assinatura diferentes;

*/

create or alter procedure ESTAPP_SP_PROD_INSERIR (
    CODIGO char(18) not null,
    NOME char(50) not null,
    PRECOWEB numeric(15,4) not null,
    UNIDADE char(2) not null,
    OBS char(255),
    SINOPSE char(255),
    PUBLICAWEB char(1),
    FILIAL double precision not null)
returns (
    RESULT integer)
as
begin
  result = 0;
  in autonomous transaction do
    update or insert into ctprod(codigo,nome, unidade, obs, sinopse,publicaweb) values (:codigo, :nome,:unidade, :obs , :sinopse,:publicaweb) matching (codigo);

  in autonomous transaction do
    update or insert into ctprod_filial(codigo, filial,precoweb) values (:codigo, :filial, :precoweb) matching (codigo,filial);
  result = 1;
  suspend;
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,UPDATE ON CTPROD TO PROCEDURE ESTAPP_SP_PROD_INSERIR;
GRANT SELECT,INSERT,UPDATE ON CTPROD_FILIAL TO PROCEDURE ESTAPP_SP_PROD_INSERIR;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE ESTAPP_SP_PROD_INSERIR TO SYSDBA;
GRANT EXECUTE ON PROCEDURE ESTAPP_SP_PROD_INSERIR TO WBA;
GRANT EXECUTE ON PROCEDURE ESTAPP_SP_PROD_INSERIR TO publicweb;



/* View: ESTAPP_CONS_PROD */
/* TODO: view de consulta de produto ja existe, criar outra ? */
CREATE OR ALTER VIEW ESTAPP_CONS_PROD(
    CODIGO,
    NOME,
    UNIDADE,
    OBS,
    SINOPSE,
    FILIAL,
    PRECOWEB)
AS
select a.codigo,a.nome,a.unidade ,a.obs, cast(a.sinopse as char(255)) sinopse,b.filial,b.precoweb from ctprod a

join ctprod_filial b on (b.codigo=a.codigo)
;



GRANT ALL ON ESTAPP_CONS_PROD TO SYSDBA;

/* TODO: nao pode dar grant ALL em VIEW - APP não usa usuario WBA -> nao deveria ter permissão */
GRANT ALL ON ESTAPP_CONS_PROD TO WBA; 

grant select on ESTAPP_CONS_PROD to publicweb;


