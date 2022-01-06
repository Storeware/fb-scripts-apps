CREATE or alter VIEW WEB_MEIOS_PAGAMENTO (CODIGO, INATIVO, ID_MEIO_PAGTO, ID_GRUPO_WBA, DS_MEIO_PAGTO, QT_MAX_PARC)
AS select p.codigo, p.inativo, m.ID_MEIO_PAGTO,m.ID_GRUPO_WBA,m.DS_MEIO_PAGTO, m.QT_MAX_PARC from MEIOPGTO m, fp_meio fm, formPgto p
where 
   m.ID_MEIO_PAGTO = fm.ID_MEIO_PAGTO and p.codigo=fm.ID_COND
   and p.INATIVO='N' and dtAprov < 'now' and dtInicio < 'now';

GRANT SELECT
 ON WEB_MEIOS_PAGAMENTO TO  PUBLICWEB;

