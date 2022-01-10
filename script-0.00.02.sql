
/*
  TODO:
    ja existe view para categoria; criar outra ?

*/

create or alter view ESTAPP_CONS_CATEG
as
select codigo,nome ,coalesce(codigo_pai,0) codigo_pai,
coalesce(prioridade,0) prioridade  from ctprod_atalho_titulo;  -- TODO: nao deveria ter funcoes, isto impacta no tempo de busca no banco

grant select on ESTAPP_CONS_CATEG to wba; -- TODO: nao tem acesso
grant select on ESTAPP_CONS_CATEG to sysdba; -- TODO: nao tem acesso de manutencao
grant select on ESTAPP_CONS_CATEG to publicweb;


SET TERM ^ ;

create or alter procedure ESTAPP_SP_CATEG_INSERIR (
    CODIGO double precision,
    NOME char(20) not null,
    prioridade double precision,
    codigo_pai double precision )
returns (
    RESULT integer)
as
begin
  result = 0;
  in autonomous transaction do
    update or insert into ctprod_atalho_titulo(codigo,nome, prioridade, codigo_pai,dtatualiz) values (:codigo, :nome,:prioridade, :codigo_pai,'now') matching (codigo);

  result = 1;
  suspend;
end^

SET TERM ; ^

GRANT SELECT,INSERT,UPDATE ON ctprod_atalho_titulo TO PROCEDURE ESTAPP_SP_CATEG_INSERIR;
grant execute on procedure ESTAPP_SP_CATEG_INSERIR to wba; 
grant execute on procedure ESTAPP_SP_CATEG_INSERIR to sysdba;
grant execute on procedure ESTAPP_SP_CATEG_INSERIR to publicweb;

create or alter view ESTAPP_CONS_CATEGITEMS
as
select  a.codprod codigo ,  b.nome,a.prioridade,a.codtitulo from
ctprod_atalho_itens a
join ctprod b on b.codigo = a.codprod;

grant select on ESTAPP_CONS_CATEGITEMS to wba;
grant select on ESTAPP_CONS_CATEGITEMS to sysdba;
grant select on ESTAPP_CONS_CATEGITEMS to publicweb;

 
commit; 





