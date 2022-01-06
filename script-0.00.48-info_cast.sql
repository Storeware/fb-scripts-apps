

update or INSERT INTO EVENTOS_AUTO (NOME, DESCRICAO, EV_GRUPO, EV_ESTADO,  INATIVO,pessoa) VALUES ('INFO-CAST', 'Assinar INFO-CAST', '1.000000', '1.000000',  'N','')
matching (nome);



update or INSERT INTO PROCSERVICE (PROCNAME, INATIVO, INICIO, PROXEXEC, TIPOEXEC, INTERVALO, ULTDATA, ORDEM) VALUES (
'PROC_INFO_CAST', 'N', '01.01.2021, 00:00:00.000', '04.02.2021, 00:00:00.000', '2.000000', '1.0000', '03.02.2021, 21:59:41.477', '1.0000')
matching (PROCNAME);


set term ^;
create or alter procedure proc_info_cast
returns (conta int,tipo varchar(20), nome varchar(50),valor float,data timestamp )
as
declare variable codigo varchar(18);
declare variable qtde float;
--declare variable valor float;
--declare variable nome varchar(50);
--declare variable data date;
declare variable clifor float;
declare variable rank_valor float;
declare variable p_dias int;
declare variable n int;
declare variable unidade varchar(5);
begin
   data = cast('today' as timestamp);
   conta = 0;
   -- ler rank de 7 sugestoes de produtos em vendas
   select first 1 ctprod_codigo, qtde, valor  from MD_ESTOQUE_SEM_VENDA(0,null,null,1)
   into :codigo,:qtde,:valor;
   
   if (qtde is not null) then
   begin
     tipo ='Produtos';
     select nome,unidade from ctprod where codigo = :codigo
     into :nome, :unidade;
     EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
	      0,
	      'INFO-CAST', 
	      'INFO-CAST', 
	      'Sugestão para promoção de produto '||:nome, 
	      'em '||extract(day from :DATA)||'/'||extract( month from :DATA)||' - Ref: '||trim(:codigo)|| ' Estoque: '||cast(:qtde as integer)||'/'||:unidade,  
	      0, -- cliente 
	      :codigo, 
	      'CTPROD', -- tabela
	      null,   -- ID 
	      0, -- ordem
	      :valor,  -- valor
	      null ,--usuario
	      NULL, -- master
	      NULL, -- master_gid
	      NULL , -- tabela_gid
	      'N' -- leu
	      );
	  conta = conta + row_count;    
      suspend;
   end


   
    p_dias = 35;
    n = 10;
    for select c.nome,a.sigcad_codigo, a.valor, a.rank_valor, 
        (select max(data) from sig02 where data>cast('today' as timestamp)- :p_dias and  clifor = a.sigcad_codigo) ultdata 
        from MD_SIG02_RANK_CLIENTE(0,cast('today' as timestamp) - :p_dias - 40, cast('today' as timestamp) - :p_dias - 10 ,:n) a
             join sigcad c on (c.codigo = a.sigcad_codigo)
        where a.sigcad_codigo>1 and not exists (
              select clifor 
              from sig02 b 
              where data>cast('today' as timestamp) - :p_dias and a.sigcad_codigo=b.clifor)
    into :nome,:clifor, :valor, :rank_valor ,:data         
    do
    begin
      if (valor is not null) then
           begin
             tipo = 'Clientes';
             EXECUTE PROCEDURE REGISTRA_EVENTO_Ex(
                  0,
                  'INFO-CAST', 
                  'INFO-CAST', 
                  'Sugestão fidelização de cliente - '||:nome, 
                  'O cliente com potencial de compras $ '||cast(:valor as integer)||'/mês, esta no rank na posição '||cast(:rank_valor as integer)||' -  não comprou nos últimos 35 dias',  
                  :clifor, -- cliente 
                  :clifor,   -- tabelaid
                  'SIGCAD', -- tabela
                  null,   -- ID 
                  0, -- ordem
                  :valor,  -- valor
                  null ,--usuario
                  NULL, -- master
                  NULL, -- master_gid
                  NULL , -- tabela_gid
                  'N' -- leu
                  );
              conta = conta + row_count;   
              suspend; 
           end


    end

  if (conta=0) then
  begin
   tipo ='NADA';
   suspend;
  end 
end^
set term ;^

commit work;

select '46 - Completado' from dummy;

-- select * from proc_info_cast;
--  select * from eventos_item where data>='today'
--  select * from eventos_assinar




