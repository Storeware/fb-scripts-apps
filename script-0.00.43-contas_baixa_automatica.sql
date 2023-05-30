set term ^;
create or alter procedure 
Proc_contas_baixa_automatica()
returns (filial double precision,clifor double precision,baixa_dcto varchar(10), ctrl_id double precision ,valor double precision, baixa_banco varchar(10),
baixa_dtpgto timestamp,baixa_juros double precision, baixa_valor double precision, items integer )
as
declare variable data timestamp;
declare variable id double precision;
declare variable codigo varchar(10);
declare variable dcto varchar(10);
declare variable historico varchar(50);
declare variable dctook varchar(1);




begin
  -- pega os lancamentos ate a data atual (nao baixados)
  for select  clifor,filial,codigo,historico,dctook, ctrl_id,data,id,valor, baixa_banco,baixa_dtpgto,baixa_valor, baixa_dcto,dcto from sigflu
  where data<='today' and coalesce(banco,'')='' and baixa_automatica=1
  into :clifor,:filial, :codigo,:historico,:dctook, :ctrl_id,:data,:id,:valor,:baixa_banco,:baixa_dtpgto,:baixa_valor,:baixa_dcto,:dcto
  do 
  begin
    baixa_juros = coalesce(:baixa_valor - :valor,0);
    baixa_dcto = coalesce(:baixa_dcto,:dcto);
  
  -- efetua a baixa 
  if (:codigo<'200') then
   begin
     -- eh um contas a receber
     select count(*) from PROC_RECEBIMENTO_CONTA(:FILIAL, :DATA, :CTRL_ID, :CLIFOR, 
       :baixa_banco, 
       :valor, :baixa_dtpgto, :baixa_dcto, :historico, :DCTOOK, :baixa_valor, 
       (case when :baixa_juros>0 then :baixa_juros else 0 end ), 0, 
       (case when :baixa_juros<0 then -:baixa_juros else 0 end ), 0, 'AUTO') 
     into :items;  
     suspend;  
   end
   else
   begin
     -- eh um conta a pagar
     select count(*) from PROC_PAGAMENTO_CONTA(:FILIAL, :DATA, :CTRL_ID, :CLIFOR, 
       :baixa_banco, 
       :valor, :baixa_dtpgto, :baixa_dcto, :historico, :DCTOOK, :baixa_valor, 
       (case when :baixa_juros>0 then :baixa_juros else 0 end ), 0, 
       (case when :baixa_juros<0 then -:baixa_juros else 0 end ), 0, 'AUTO') 
     into :items;  
   
    suspend;
   end


    
  end
end^
set term ;^

commit work;


update or INSERT  
   INTO PROCSERVICE (PROCNAME, INATIVO, INICIO, PROXEXEC, TIPOEXEC, INTERVALO, ULTDATA, ORDEM ) 
   VALUES ('PROC_CONTAS_BAIXA_AUTOMATICA', 'S', '01.01.2021, 00:00:00.000', '01.01.2021, 00:00:00.000', '2.000000', '1.0000', '01.01.2021, 00:00:00.000', '2.0000')
   matching (procname);
commit work;


--select * from REG_EXECUTE_PROCSERVICE;



/*
alter table sigflu add baixa_automatica integer;
alter table sigflu add baixa_banco varchar(10);
alter table sigflu add baixa_dtpgto date;
alter table sigflu add baixa_valor float;
alter table sigflu add baixa_dcto varchar(10);
*/

--update sigflu set baixa_banco = '101'

