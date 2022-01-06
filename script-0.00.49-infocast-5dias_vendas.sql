
-- gerar item para assinar
update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) 
          VALUES ('PROC_TOP5_DIAS_VDAS', 'Ultimos 5 dias de vendas', '1.000000', '1.000000',  'N','')
matching (nome);




update or INSERT  
   INTO PROCSERVICE (PROCNAME, INATIVO, INICIO, PROXEXEC, TIPOEXEC, INTERVALO, ULTDATA, ORDEM ) 
   VALUES ('PROC_TOP5_DIAS_VDAS', 'N', '01.01.2021, 00:00:00.000', '01.01.2021, 00:00:00.000', '2.000000', '1.0000', '01.01.2021, 00:00:00.000', '2.0000')
   matching (procname);
commit work;


set term ^;

create or alter procedure PROC_TOP5_DIAS_VDAS
returns
  (conta int, texto varchar(4096))
as 
declare variable valor double precision;
declare variable data date;
declare variable total double precision;
declare variable servicos double precision;
declare variable pa double precision;
declare variable tpa double precision;
declare variable tservicos double precision;
declare variable tprodutos double precision;
declare variable id double precision;
begin
 --
 conta = 0;
 
 total = 0;
 texto = '';
 tservicos = 0;
 tpa = 0;
 data = cast('today' as date);
 id = cast(extract(year from data)||lpad(extract(month from data),2,'0')||lpad(extract(day from data),2,'0') as integer);
 for select data 
            , sum(case when operacao<'200' then valor else -valor end)  valor
            , sum( case when c.inservico='S' then (case when operacao<'200' then valor else -valor end) else 0 end )  servicos
            , sum( case when c.inservico<>'S' then (qtde*pa* case when operacao<'200' then 1 else -1 end) else 0 end )  pa
     from sigcaut2 b join ctprod c on (c.codigo=b.codigo)
 where data >= 'today' - 5
 group by data
 into :data,:valor, :servicos, :pa
 do
 begin
    
    total = total + coalesce(:valor,0);
    tpa = tpa + coalesce(pa,0);
    tservicos = tservicos + coalesce(servicos,0);

   -- monta dia
    if (valor>0) then begin
      texto = texto ||'* '|| extract(day from :data)||'/'||extract(month from :data)||' - ';
      texto = texto || round(:valor,2);
      texto = texto || '\n';
    end
    conta = conta + 1;
 end
 tprodutos = total - tservicos;
 
 texto = texto ||'Total $: <b>'||round(total,2)||'</b>';
 
 if (tservicos>0) then
   texto = texto ||'\nServicos: '|| round(tservicos,2);
 if ((tprodutos>0) and (tservicos>0)) then
    texto = texto ||'\nProdutos: '|| round(tprodutos,2);
    
 if ((tprodutos>0) and (tpa>0)) then
 begin
    --texto = texto ||'|Custo: '||round(tpa,2);
    texto = texto ||'\nMargem: <b>'||round((tprodutos-tpa) / tpa * 100 ,1)|| ' %</b>';   
 end   
 
 
  EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      2,
	      'PROC_TOP5_DIAS_VDAS', 
	      'INFO-CAST', 
	      '5 dias de venda', 
	      texto,  
	      0, -- cliente 
	      0, 
	      'TOP5_DIAS_VDAS', -- tabela
	      :id,   -- ID 
	      0, -- ordem
	      :total,  -- valor
	      null ,--usuario
	      NULL, -- master
	      NULL, -- master_gid
	      NULL , -- tabela_gid
	      'N' -- leu
	      );
 
 
 suspend;
 
end^
set term ;^ 
commit work;

-- teste
select * from proc_top5_dias_vdas

