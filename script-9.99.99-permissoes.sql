grant select on wba_ctprod_unidade to publicweb;
grant select on wba_ctprod_unidade to wba;
grant select on kpi_vendas to publicweb;
grant all on sigcaut1 to publicweb;
grant select on sigcauth to publicweb;
--grant select,update,delete on sigcaut1estados to publicweb;
grant select,update,delete on sigcaut1armaz to publicweb;
grant select on wba_sigcauth to publicweb;
grant select on wba_sigcaut1 to publicweb;

GRANT INSERT, SELECT, UPDATE
 ON WBA_SIGCAUT1EST TO  publicweb WITH GRANT OPTION;

GRANT SELECT,INSERT,UPDATE ON CTPROD TO PROCEDURE ESTAPP_SP_PROD_INSERIR;
GRANT SELECT,INSERT,UPDATE ON CTPROD_FILIAL TO PROCEDURE ESTAPP_SP_PROD_INSERIR;
GRANT EXECUTE ON PROCEDURE ESTAPP_SP_PROD_INSERIR TO publicweb;

grant select on ESTAPP_CONS_PROD to publicweb;

grant select on ESTAPP_CONS_CATEG to publicweb;



GRANT SELECT,INSERT,UPDATE ON ctprod_atalho_titulo TO PROCEDURE ESTAPP_SP_CATEG_INSERIR;
grant execute on procedure ESTAPP_SP_CATEG_INSERIR to publicweb;

grant select on ESTAPP_CONS_CATEGITEMS to publicweb;


grant execute on procedure WEB_REG_PEDIDO_ITEM to  publicweb;

GRANT  SELECT
 ON SIGCAUT1_HORA TO   publicweb ;



grant select on sigcaut2resmes to publicweb;
grant select,update,insert,delete on metas_vendas to publicweb;
grant update,insert, delete, select  on sigcaut1_hora to publicweb;

grant execute on procedure ENCODEDECODETIME TO publicweb;


grant select on sigcaut2_hora to publicweb;

grant select,update,insert,delete on  EVENTOS_ITEM to publicweb;



grant select on wba_sigcad to publicweb;
grant select,update,insert,delete on sigcad to publicweb;

grant select, insert, update, delete on ctprod to publicweb;
grant select , update, insert , delete on ctprod_atalho_itens to publicweb;
grant select , update, insert , delete on ctprod_atalho_titulo to publicweb;


grant select,insert,update,delete on formpgto to publicweb;
grant select on FILIAL_TODAS to publicweb;
grant select, update, delete, insert on fp_meio to publicweb;
grant select, update, delete, insert on meiopgto to publicweb;


grant select,insert,update,delete on sigcautp to publicweb;

grant select, update, delete, insert on AGENDA_RECURSO to publicweb;
grant select,update,insert, delete on agenda to publicweb;
grant select, update,insert,delete on agenda_tipo to publicweb;
grant select on dummy to publicweb;
grant select, insert, update, delete on pet_animal to publicweb;


grant select,update, insert, delete on pet_agenda to publicweb;

grant delete,update,insert,select on ctprod_unidade to publicweb;



GRANT SELECT
 ON WEB_USUARIOS TO  PUBLICWEB;



 grant select, insert, update,delete on CTPROD_FILIAL_PROMOCAO to publicweb;
 grant select on WF_PRODUTOS_PROMOCAO to publicweb;
 grant select, insert,delete,update on CN_PROTOCOLO to publicweb;
 grant select,insert,delete,update on cn_saida_servidor to publicweb;
 grant select, insert, delete, update on CN_ESTADO_MENSAGEM to publicweb;
 grant select, insert, delete, update on cn_saida_titulo to publicweb;
 grant select, update on templates to publicweb;



grant select, update, insert on estoper to publicweb;
grant select, insert on estmvto to publicweb;

grant select,insert,update on ctprodsd_lote to publicweb;
grant select,insert,update on ctprodsd_serie to publicweb;
grant select,insert,update on ESTMVTO_DEMANDA_DIARIA to publicweb;
grant select,insert,update on SIGCAUT2_DATA_GRADE to publicweb;

grant execute  on procedure  ABRE_NOVOPRODUTO_ESTOQUE to publicweb;

grant execute  on procedure  REGISTRA_GRADE to publicweb;
grant execute  on procedure  REGISTRA_ESTOQUE to publicweb;
grant execute  on procedure  Reg_serie to publicweb;
grant execute  on procedure  Reg_lote to publicweb;

GRANT EXECUTE
 ON PROCEDURE PROC_REG_ESTOQUE TO PUBLICWEB; 
grant select, insert, update, delete on AGENDA_ESTADO to publicweb;


grant select on wba_formpgto to publicweb;
grant select on WEB_MEIOS_PAGAMENTO to publicweb;
grant select on WBA_FP_MEIO to publicweb;


grant select on fechacx to publicweb;
grant select, insert,update on sigbco_saldos to publicweb;
grant select, insert, update, delete on sigcx_resumo to publicweb;
grant execute on procedure FIMMES to publicweb;

grant select,update, insert on sigcx to publicweb;
grant select, insert, update on sigflu to publicweb;

grant select,insert,update on sigbco to publicweb;
grant select,insert, update on sig01 to publicweb;

grant select,insert,update,delete on SIGCX_TOTAL_DIA to publicweb  ;

GRANT EXECUTE ON PROCEDURE SP_SIGBCO_SALDO TO PUBLICWEB;
GRANT EXECUTE ON PROCEDURE SP_SIGBCO_SALDO TO WBA;

GRANT SELECT ON SIGBCO TO PROCEDURE SP_SIGBCO_SALDO;
GRANT SELECT, INSERT, UPDATE ON SIGCX_TOTAL_DIA TO PROCEDURE SP_SIGBCO_SALDO;
GRANT EXECUTE
 ON PROCEDURE SP_SIGBCO_EXTRATO TO  PUBLICWEB;
GRANT SELECT ON SIGCX TO PROCEDURE SP_SIGBCO_EXTRATO;


GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO111 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO112 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO113 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO114 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO115 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO116 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO117 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO118 TO PROCEDURE proc_reg_financeiro;
GRANT EXECUTE ON PROCEDURE PROC_REG_FINANCEIRO11x TO PROCEDURE proc_reg_financeiro;

grant select,insert,delete,update on acgrupos to publicweb;
grant select, update, insert on senhas to publicweb;
grant select,insert,delete,update on METAS_VENDAS_VENDEDOR to publicweb;
grant select,insert,update,delete on estados to publicweb;
grant select,insert,update on CTPROD_FILIAL to publicweb;


grant execute on procedure web_reg_pedido_pago to publicweb;
grant all on sigcaut1 to procedure WEB_REG_PEDIDO_PAGO;
grant all on sigcaut2 to procedure WEB_REG_PEDIDO_PAGO;
grant all on sig02 to procedure WEB_REG_PEDIDO_PAGO;
grant all on sig02cp to procedure WEB_REG_PEDIDO_PAGO;
grant all on sig02cph to procedure WEB_REG_PEDIDO_PAGO;
grant all on sigcautp to procedure WEB_REG_PEDIDO_PAGO;
grant all on sigcauth to procedure WEB_REG_PEDIDO_PAGO;

grant select on sig02 to publicweb;

grant select,insert,delete,update on  ATEND_HORA to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  ATEND_HR_PROD to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  sigcaut2_hora to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  sigcaut2_data to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant select,insert,delete,update on  inifiles to publicweb, procedure WEB_REG_PEDIDO_PAGO;
grant execute on procedure REG_RATEIO_CUPOM_VENDA to publicweb;
grant execute on procedure REG_APONTAMENTO_PRODUCAO to publicweb;

grant select on sig02obs to publicweb;
grant select on sigcaut2 to publicweb;
grant select on PRTREDE_LOCAIS to publicweb;
grant select,delete,insert on PRODUCAO_IMPRIMIR to publicweb;

grant select,insert,update,delete on sigcautp to publicweb;
grant select,insert,update on prod_ctprodsd_celula to publicweb;

GRANT USAGE ON SEQUENCE PACOTE_SERVICOID TO publicweb WITH GRANT OPTION ;
GRANT SELECT,INSERT ON PACOTE_SERVICO TO PUBLICWEB WITH GRANT OPTION;
GRANT SELECT,INSERT ON PACOTE_SERVICO_ITEM TO PUBLICWEB WITH GRANT OPTION;
GRANT SELECT ON PET_CTPROD TO PUBLICWEB WITH GRANT OPTION;
GRANT SELECT ON SIGCAUT2_CESTA TO PUBLICWEB WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE GET_ID_CESTA_CORRENTE TO publicweb;


grant update on ctprod_filial to publicweb;
grant update, select, insert, delete on PET_ATENDIMENTO_ITENS to publicweb;



grant select, update, delete, insert on sigven to publicweb;
grant select, update, insert,delete on sigcauth to publicweb;
grant insert on repl_itens to publicweb;
grant USAGE on sequence REPL_ITENS_GEN_ID to publicweb;
grant select,delete on sigven_faixa to publicweb;
grant select,delete on SIGVEN_FAIXAVALORES to publicweb;
grant select,delete on SIGVEN_MEIOPGTO to publicweb;
grant execute  on procedure  WEB_REG_PEDIDO to publicweb;

GRANT EXECUTE
 ON PROCEDURE WEB_REG_PEDIDO_ENTREGA_DIGITAL TO  PUBLICWEB;
GRANT EXECUTE
 ON PROCEDURE WEB_REG_OS_ITEM_EX TO  PUBLICWEB;

GRANT EXECUTE
 ON PROCEDURE WEB_REG_OS_ITEM_EX TO  SYSDBA WITH GRANT OPTION;

GRANT EXECUTE
 ON PROCEDURE WEB_REG_OS_ITEM_EX TO  WBA;

GRANT EXECUTE
 ON PROCEDURE WEB_REG_PEDIDO_TOTALIZA TO  PUBLICWEB;

grant select,insert, update on pet_atendimento to publicweb;
grant select,insert, update on PET_TIPO_ATENDIMENTO to publicweb;
grant select,insert, update on pet_atendimento to publicweb;


 grant select,insert,update,delete on pet_atendimento_estados to publicweb;


grant select,update,delete,insert on TEMPLATES to publicweb;

grant select on estados to publicweb;


grant select,delete,update,insert on EVENTOS_ITEM_NOTAS to publicweb;

grant select on cprnota to publicweb;
grant select on wf_produtos_novos to publicweb;


GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO119 TO PROCEDURE PROC_REG_FINANCEIRO;

GRANT EXECUTE
 ON PROCEDURE PROC_REG_FINANCEIRO119 TO  SYSDBA WITH GRANT OPTION;


/* 11/01/2021 - incluir manuetencao de contas a receber */
grant select, insert, update on sigflu to publicweb;
grant select on eventos_auto to publicweb;
grant select on alinea to publicweb;
grant insert on workflowfluxo to publicweb;
grant select,insert,update on sigflu_resumo to publicweb;
grant execute on procedure registra_evento to publicweb;


/* 18-jan-2021 */
grant select on EVENTOS_AUTO to publicweb;

/* 19-jan-2021 */
GRANT EXECUTE
 ON PROCEDURE PROC_PAGAMENTO_CONTA TO  PUBLICWEB;

GRANT EXECUTE
 ON PROCEDURE REG_SIGCX_BX_AUTO TO  PUBLICWEB;

GRANT EXECUTE ON PROCEDURE ENCODEDECODEDATE TO PUBLICWEB;

commit work;


/* 01-fev-21 - fluxo de caixa */
grant execute on procedure relatorio_fluxo_caixa to publicweb;
GRANT INSERT ON WBA$LOG TO PUBLICWEB WITH GRANT OPTION;  /* pablo */

/* 08-fev-21 - usado no pagemtno do pedido */
GRANT SELECT,INSERT,UPDATE,DELETE ON CTPRODSD_SALDO_DIARIO TO PUBLICWEB WITH GRANT OPTION;

/* 11-fev-21 - usado para incluir produto - pablo */
GRANT SELECT,DELETE ON PALAVRA_CHAVE_CTPROD TO PUBLICWEB WITH GRANT OPTION;

GRANT EXECUTE ON PROCEDURE PALAVRA_CHAVE_CTPROD_ADD TO PUBLICWEB;

GRANT SELECT,INSERT,UPDATE ON WF_PRODUTOS_NOVOS TO PUBLICWEB;

GRANT SELECT,INSERT ON CTPRODSD TO PUBLICWEB;

GRANT INSERT ON PAF_CTPROD_ALTERADOS TO PUBLICWEB;

GRANT SELECT  ON WBA$LOGIN TO PUBLICWEB;

GRANT INSERT ON CTPROD_LOG TO PUBLICWEB;

GRANT SELECT  ON EXPLCAD TO PUBLICWEB;

GRANT SELECT  ON EXPLITEM TO PUBLICWEB;  

GRANT SELECT  ON  EXPLITEM_BAIXAESTOQUE TO PUBLICWEB;

grant select,insert,update,delete on sigcaut1estados to publicweb;

/* relativos aos eventos automaticos  */

GRANT EXECUTE
 ON PROCEDURE REGISTRA_EVENTO_ex TO  PUBLICWEB;

GRANT EXECUTE
 ON PROCEDURE REGISTRA_EVENTO_Ex TO  SYSDBA;

GRANT EXECUTE
 ON PROCEDURE REGISTRA_EVENTO_Ex TO  WBA;


grant select on EVENTOS_AUTO to publicweb;

grant select, insert, update,delete on eventos_assinar to publicweb;


/* ranks */
grant execute on procedure MD_SIG02_RANK_CLIENTE to publicweb;
grant execute on procedure md_sigcaut2_data_rank_valor to publicweb;
grant execute on procedure md_ticket_medio_venda to publicweb;
grant execute on procedure md_estoque_sem_venda to publicweb;


GRANT  INSERT, REFERENCES, SELECT, UPDATE
 ON SIG02_TICKETMEDIO_DATA TO  publicweb WITH GRANT OPTION;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIGCAD_ENDER TO PROCEDURE REG_SIGCAD_ENDER;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIGCAD_ENDER TO  SYSDBA WITH GRANT OPTION;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON SIGCAD_ENDER TO PROCEDURE WEB_REG_PEDIDO_ENTREGA_DIGITAL;

grant select, update,insert, delete on ctgrupo to publicweb;

GRANT EXECUTE ON PROCEDURE REG_RESERVA_ESTOQUE TO publicweb;


GRANT SELECT,INSERT,UPDATE ON CTPRODSD_CONSIGNADO TO publicweb;

grant select on sig02cp to publicweb;


GRANT SELECT
 ON WBA_CTPROD_FAVORITOS TO ROLE PUBLICWEB;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON WBA_CTPROD_FAVORITOS TO  SYSDBA WITH GRANT OPTION;

GRANT SELECT
 ON WBA_CTPROD_FAVORITOS TO  WBA;

GRANT SELECT
 ON WBA_CTPROD_FAVORITOS TO  WEB;


GRANT SELECT
 ON WBA_CTPROD_ATALHO_TITULO TO ROLE PUBLICWEB;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON WBA_CTPROD_ATALHO_TITULO TO  SYSDBA WITH GRANT OPTION;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON WBA_CTPROD_ATALHO_TITULO TO  WBA;


GRANT SELECT
 ON WEB_CLIENTES TO ROLE PUBLICWEB;

GRANT SELECT
 ON WEB_CLIENTES TO  PUBLIC_WEB;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON WEB_CLIENTES TO  SYSDBA WITH GRANT OPTION;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON WEB_CLIENTES TO  WBA;

GRANT SELECT
 ON WEB_CLIENTES TO  WEB;

GRANT SELECT
 ON WEB_CLIENTES TO PROCEDURE WEB_PROCURAR_CLIENTECELULAR;
  
grant select on wba_ctprod_unidade to publicweb;
grant select on wba_ctprod_unidade to wba;
grant select on kpi_vendas to publicweb;
grant all on sigcaut1 to publicweb;
grant select on sigcauth to publicweb;
grant select,update,delete on sigcaut1estados to publicweb;
grant select,update,delete on sigcaut1armaz to publicweb;

GRANT INSERT, SELECT, UPDATE
 ON WBA_SIGCAUT1EST TO  publicweb WITH GRANT OPTION;

GRANT SELECT, INSERT, UPDATE ON PAT_CADASTRO TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_LOCAL TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_TIPO TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_ESTADO TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_SITUACAO TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_TIPO_ACAO TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_TIPO_ACESSO TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_TIPO_MVTO TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_ATRIB_GERAL TO publicweb;
GRANT SELECT, INSERT, UPDATE ON PAT_ATRIB_VEICULO TO publicweb;


GRANT SELECT ON COMANDAS TO publicweb;
GRANT SELECT ON PRODUCAO_IMPRIMIR TO publicweb;
GRANT SELECT ON PRODUCAO_MESA TO publicweb;
GRANT SELECT ON CTPROD_COMPL TO publicweb;

grant execute on procedure COMANDA_PRECOPRODUTO to publicweb;
grant select on CTPRODX to procedure COMANDA_PRECOPRODUTO;

GRANT SELECT ON CTLOCAL TO PUBLICWEB;

