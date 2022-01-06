grant select, insert, update, delete on ctprod to publicweb;
grant select , update, insert , delete on ctprod_atalho_itens to publicweb;
grant select , update, insert , delete on ctprod_atalho_titulo to publicweb;
commit work;

select '07 - Completado' from dummy;

