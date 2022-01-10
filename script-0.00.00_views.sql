CREATE or alter VIEW wba_sigcauth 
AS
select * from sigcauth;
grant select on wba_sigcauth to publicweb;


CREATE or alter VIEW wba_sigcaut1
AS
select * from sigcaut1;
grant select on wba_sigcaut1 to publicweb;


CREATE or alter VIEW WBA_SIGCAUT1EST (ID, CODIGO, NOME, ESTCONCLUIDO, QTDEESTADOPARA, PDVESTADOPARA, PDVPODEFECHAR)
AS 
SELECT   ID, CODIGO, NOME, ESTCONCLUIDO, QTDEESTADOPARA, PDVESTADOPARA, PDVPODEFECHAR
               FROM SIGCAUT1ESTADOS;
