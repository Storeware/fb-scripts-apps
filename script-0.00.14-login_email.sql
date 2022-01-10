CREATE or alter VIEW WEB_USUARIOS (CODIGO, NOME, CAIXA, FILIAL, FUNCAO, GRUPO, VENDEDOR, CLIFOR, email )
AS select codigo,nome,caixa,filial,funcao,grupo,vendedor,clifor,email from senhas;

GRANT SELECT
 ON WEB_USUARIOS TO  PUBLICWEB;



 grant select, insert, update,delete on CTPROD_FILIAL_PROMOCAO to publicweb;
 grant select on WF_PRODUTOS_PROMOCAO to publicweb;
 grant select, insert,delete,update on CN_PROTOCOLO to publicweb;
 grant select,insert,delete,update on cn_saida_servidor to publicweb;
 grant select, insert, delete, update on CN_ESTADO_MENSAGEM to publicweb;
 grant select, insert, delete, update on cn_saida_titulo to publicweb;
 grant select, update on templates to publicweb;
