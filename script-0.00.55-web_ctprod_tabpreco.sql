
/* View: WEB_CTPROD_TABPRECO */
CREATE OR ALTER VIEW WEB_CTPROD_TABPRECO(
    CODIGO,
    NOME,
    UNIDADE,
    PRECOVENDA,
    TABELA,
    FILIAL)
AS
select  c.CODIGO, c.nome,c.unidade, coalesce(b.PRECOIND,a.precovenda) PRECOVENDA,
 B.CODTABPRECO TABELA , a.filial
from  ctprod c join ctprod_filial a on (c.codigo=a.codigo)
 join ctprod_tabpreco b on (c.codigo=b.codigo)
;


/* Privileges of users */
GRANT SELECT ON WEB_CTPROD_TABPRECO TO WBA;

/* Privileges of roles */
GRANT SELECT ON WEB_CTPROD_TABPRECO TO PUBLICWEB;