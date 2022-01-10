grant select,update,insert,delete on  EVENTOS_ITEM to publicweb;



grant select on wba_sigcad to publicweb;
grant select,update,insert,delete on sigcad to publicweb;


update or insert into eventos_estados (codigo,nome) values (0,'Novo') matching (codigo);
update or insert into EVENTOS_GRUPO (codigo,nome) values( 0,'Novo') matching(codigo);

SET TERM ^ ;

CREATE or alter TRIGGER tr_sigcauth_reg_evento FOR SIGCAUTH
ACTIVE AFTER INSERT or UPDATE POSITION 0
AS 
declare variable texto varchar(255);
BEGIN 
    texto = substring( 'Novo pedido '||coalesce(coalesce(new.OBS,new.ENDENTR),'') from 1 for 255);
	/* enter trigger code here */ 
	if (new.operacao between '129' and '199') then
	 update or insert into eventos_item
	    (data,titulo,obs,datalimite,idestado,idgrupo_estado,
	    autor,pessoa,usuario,
	    cliente,dcto,idtabela,tabela,valor,arquivado,
	    inativo )
	    values
	    (new.data,'Novo Pedido: '||new.dcto,
	      :texto,new.DTENT_RET,0,0,
	      'PEDIDO','AUTO',new.operador,
	      new.cliente,new.dcto,new.id,'SIGCAUTH',new.TOTAL,'N','N')
	    matching (tabela,idtabela);  
END^

SET TERM ; ^ 

commit work;
select '06 - Completado' from dummy;
