
rollback work;



set term ^;
create or alter procedure dimtempo_datas_semelhantes
( p_data timestamp, p_dias int )
returns (datas varchar(1024),diasemana int, 
         feriado varchar(1), temperatura float, 
         umidade varchar(10) 
         
          )
as
declare variable data timestamp;
declare variable hoje timestamp;
begin
----------------------------------------------------------------------------
-- levanta os dias semelhantes a data de hoje (dias da semana e temperatura)
-- retorna as datas validas para a sele��o
-- params:
--   p_data -> dia de referencia para a semelhan�a
--   p_dias -> quantos dias retroceder no levantamento
-- as datas retornadas correpondem as ultimas 10 datas encontradas
----------------------------------------------------------------------------
  hoje = cast('today' as timestamp);
  
  p_data = coalesce(p_data,hoje);
    
  -- parametros de hoje
  select diasemana,temperatura,feriado, umidade from dimtempo
  where data = :p_data 
  into :diasemana, :temperatura, :feriado,:umidade;
 
 
  -- scala informacoes faltantes
  if (diasemana is null) then
     diasemana = extract (weekday from hoje) + 1;
  if (temperatura is null) then
     select avg(temperatura) from 
       (select first 10 temperatura 
        from dimtempo
        order by data desc
       ) x    
     into :temperatura; 
     
  feriado = coalesce(:feriado,'N');    
      
  
  
  -- levantar os atributos da matriz (tempo, dia semana)
  select '("'||list(data,'","')||'")' from (select first 10 data,diasemana,feriado,temperatura, umidade  from dimtempo a
  where data between (:p_data - :p_dias) and :p_data
        and diasemana = :diasemana and temperatura between (:temperatura * 0.8) and (:temperatura * 1.2)
  order by data desc)
  into :datas;
  suspend;
    
end^

set term ;^
commit work;

--==============================================================================

set term ^;

create or alter procedure md_sigcaut2_dt_medias
(p_filial float, p_codigo varchar(18) )
returns (codigo varchar(18),diasemana int,temperatura float, 
         qtde_media float,ocorrencias int,qtde float, valor float, 
         min_data timestamp, max_data timestamp,
         min_qtde float, max_qtde float,
         datas varchar(1024), qry varchar(2048))
as
declare variable filial_de float;
declare variable filial_ate float;
begin
---------------------------------------------------------------------------
-- levantar os dados medios
-- obtem a quantidade m�dia de venda para o produto na filial 
-- com base nas datas com semelhasm em dia da semana e temperatura
-- params:
--    p_filial -> filial a que se refere o levantamento
--    p_codigo -> codigo do produto a levantar
-- como usar:
--    fazer uma combina��o no select para pegar os produto desejados
--    ex:   
/*  select first 10 a.codigo, a.grupo, b.QTDE_MEDIA 
    from ctprod a , md_sigcaut2_medias(1,a.codigo) b
    --where a.grupo = '002' 
*/
---------------------------------------------------------------------------

    codigo = :p_codigo;
    select datas,diasemana,temperatura from dimtempo_datas_semelhantes(null,1800)
    into :datas,:diasemana,:temperatura;

    if (:p_filial is null) then
       select min(codigo) from filial
       into :p_filial;
    

    filial_de = :p_filial;
    filial_ate = :p_filial;            
    if (:p_filial <= 0 ) then
    begin
      filial_de = 0;
      filial_ate = 999;
    end      


    qry =  'select min(data), max(data), count(*), avg(qtde), sum(qtde), sum(valor), min(qtde), max(qtde) from sigcaut2 where codigo = "'||:p_codigo||'" and (filial between '||:filial_de||' and '||:filial_ate||') and data in '|| :datas ;      
    
    execute statement qry into :min_data, :max_data, :ocorrencias, :qtde_media, :qtde, :valor, :min_qtde, :max_qtde;
    
    suspend;
end^
set term ;^
--==============================================================================


set term ^;

create or alter procedure md_sigcaut2_data_dt_medias
(p_filial float, p_codigo varchar(18) )
returns (codigo varchar(18),diasemana int,temperatura float, 
         qtde_media float,ocorrencias int,qtde float, valor float, 
         min_data timestamp, max_data timestamp,
         min_qtde float, max_qtde float,
         datas varchar(1024), qry varchar(2048))
as
declare variable filial_de float;
declare variable filial_ate float;

begin
---------------------------------------------------------------------------
-- levantar os dados medios
-- obtem a quantidade m�dia de venda para o produto na filial 
-- com base nas datas com semelhasm em dia da semana e temperatura
-- params:
--    p_filial -> filial a que se refere o levantamento
--    p_codigo -> codigo do produto a levantar
-- como usar:
--    fazer uma combina��o no select para pegar os produto desejados
--    ex:   
/*  select first 10 a.codigo, a.grupo, b.QTDE_MEDIA 
    from ctprod a , md_sigcaut2_data_medias(1,a.codigo) b
    --where a.grupo = '002' 
*/
---------------------------------------------------------------------------

    codigo = :p_codigo;
    select datas,diasemana,temperatura from dimtempo_datas_semelhantes(null,1800)
    into :datas,:diasemana,:temperatura;


    if (:p_filial is null) then
       select min(codigo) from filial
       into :p_filial;
    

    filial_de = :p_filial;
    filial_ate = :p_filial;            
    if (:p_filial <= 0 ) then
    begin
      filial_de = 0;
      filial_ate = 999;
    end      


    qry =  'select min(data), max(data), count(*), avg(qtde), sum(qtde), sum(valor), min(qtde), max(qtde) from sigcaut2_data where codigo = "'||:p_codigo||'" and (filial between '||:filial_de||' and '||:filial_ate||') and data in '|| :datas ;      
    
    execute statement qry into :min_data, :max_data, :ocorrencias, :qtde_media, :qtde, :valor, :min_qtde, :max_qtde;
    
    suspend;
end^
set term ;^

--==============================================================================



set term ^;

create or alter procedure md_sigcaut2_dt_agrupado_medias
(p_filial float, p_codigo varchar(18) )
returns (ctprod_codigo varchar(18),diasemana int,temperatura float, 
         qtde_media float,ocorrencias int,qtde float, valor float, 
         min_data timestamp, max_data timestamp,
         min_qtde float, max_qtde float,ticket_medio float,
         datas varchar(1024), qry varchar(2048))
as
declare variable agrupado varchar(1024);
declare variable filial_de float;
declare variable filial_ate float;

begin
---------------------------------------------------------------------------
-- levantar os dados medios
-- obtem a quantidade m�dia de venda para o produto na filial 
-- com base nas datas com semelhasm em dia da semana e temperatura
-- params:
--    p_filial -> filial a que se refere o levantamento
--    p_codigo -> codigo do produto a levantar
-- como usar:
--    fazer uma combina��o no select para pegar os produto desejados
--    ex:   
/*  select first 10 a.codigo, a.grupo, b.QTDE_MEDIA 
    from ctprod a , md_sigcaut2_agrupado_medias(1,a.codigo) b
    --where a.grupo = '002' 
*/
---------------------------------------------------------------------------

    ctprod_codigo = :p_codigo;
    
    if (:p_filial is null) then
       select min(codigo) from filial
       into :p_filial;
    
    
    select datas,diasemana,temperatura from dimtempo_datas_semelhantes(null,1800)
    into :datas,:diasemana,:temperatura;
    
   filial_de = :p_filial;
   filial_ate = :p_filial;            
   if (:p_filial <= 0 ) then
   begin
     filial_de = 0;
     filial_ate = 999;
   end      

    agrupado = '( select data,sum(qtde) qtde,sum(valor) valor,codigo from sigcaut2 where (filial between '||:filial_de||' and '||:filial_ate||') and codigo = "'||:p_codigo||'" and  data in '||:datas||' group by codigo,data,dcto,prtserie,filial   )';
    qry =  'select min(data), max(data), sum(case when qtde>0 then 1 else 0 end) , avg(qtde), sum(qtde), sum(valor), min(qtde), max(qtde) from '||:agrupado ||' where qtde <> 0 ' ;      
    
    execute statement qry into :min_data, :max_data, :ocorrencias, :qtde_media, :qtde, :valor, :min_qtde, :max_qtde;
    ticket_medio = 0;
    if (:valor <> 0 and :ocorrencias<>0) then
      ticket_medio = :valor / :ocorrencias;
    suspend;
end^
set term ;^

--==============================================================================


set term ^;

create or alter procedure md_sigcaut2_agrupado_medias
(p_filial float, p_codigo varchar(18), p_de timestamp, p_ate timestamp )
returns (ctprod_codigo varchar(18),
         qtde_media float,ocorrencias int,qtde float, valor float, 
         min_data timestamp, max_data timestamp,
         min_qtde float, max_qtde float,ticket_medio float,
         qry varchar(2048))
as
declare variable agrupado varchar(1024);
declare variable filial_de float;
declare variable filial_ate float;

begin
---------------------------------------------------------------------------
-- levantar os dados medios
-- obtem a quantidade m�dia de venda para o produto na filial 
-- com base nas datas com semelhasm em dia da semana e temperatura
-- params:
--    p_filial -> filial a que se refere o levantamento
--    p_codigo -> codigo do produto a levantar
-- como usar:
--    fazer uma combina��o no select para pegar os produto desejados
--    ex:   
/*  select first 10 a.codigo, a.grupo, b.QTDE_MEDIA 
    from ctprod a , md_sigcaut2_agrupado_medias(1,a.codigo) b
    --where a.grupo = '002' 
*/
---------------------------------------------------------------------------

    ctprod_codigo = :p_codigo;
    
    if (:p_filial is null) then
       select min(codigo) from filial
       into :p_filial;
    
    if (p_ate is null) then
      p_ate = cast('today' as timestamp);
    if (p_de is null) then
      p_de = p_ate - 180;  
    
    
    
   filial_de = :p_filial;
   filial_ate = :p_filial;            
   if (:p_filial <= 0 ) then
   begin
     filial_de = 0;
     filial_ate = 999;
   end      

    agrupado = '( select data,sum(qtde) qtde,sum(valor) valor,codigo from sigcaut2 where (filial between '||:filial_de||' and '||:filial_ate||') and codigo = "'||:p_codigo||'" and  (data between "'||:p_de ||'" and "'||:p_ate ||'") group by codigo,data,dcto,prtserie,filial   )';
    qry =  'select min(data), max(data), sum(case when qtde>0 then 1 else 0 end) , avg(qtde), sum(qtde), sum(valor), min(qtde), max(qtde) from '||:agrupado ||' where qtde <> 0 ' ;      
    
    execute statement qry into :min_data, :max_data, :ocorrencias, :qtde_media, :qtde, :valor, :min_qtde, :max_qtde;
    ticket_medio = 0;
    if (:valor <> 0 and :ocorrencias<>0) then
      ticket_medio = :valor / :ocorrencias;
    suspend;
end^
set term ;^


--==============================================================================
set term ^;
create or alter procedure md_ticket_medio_venda
(p_filial float, p_de timestamp, p_ate timestamp, p_dias int)
returns (data timestamp, valor float, ocorrencias float, ticket_medio float )
as
declare variable filial_de float;
declare variable filial_ate float;
declare variable soma_valor float;
declare variable soma_ocorrencias float;
declare variable filial float;
begin
   --   select * from md_ticket_medio_venda(0,null,null,1800);
   soma_valor = 0;
   soma_ocorrencias = 0;
   -- scalar os valores nao informados 
   if (p_dias is null) then
      p_dias = 7;
   if (p_filial is null) then 
      select min(codigo) from filial
      into :p_filial;
               
               
   filial_de = :p_filial;
   filial_ate = :p_filial;            
   if (:p_filial <= 0 ) then
   begin
     filial_de = 0;
     filial_ate = 999;
   end            


   if (p_ate is null) then
      select max(data) from sig02 
      where filial between :filial_de and :filial_ate and data>='today' - 180
      into :p_ate;
      
   if (p_de is null) then 
      p_de = :p_ate - :p_dias;
   


  ticket_medio = 0;
  for select data,filial, count(*) ocorrencias, sum(valor) valor from sig02
  where filial between :filial_de and :filial_ate and
        data between :p_de and :p_ate
  group by data,filial
  order by data       
  into :data, :filial, :ocorrencias, :valor
  do 
  begin
    soma_valor = soma_valor + valor;
    soma_ocorrencias = soma_ocorrencias + ocorrencias;
    ticket_medio = 0;
    if (valor<>0 and ocorrencias>0) then
       ticket_medio = :valor / :ocorrencias;
    if (valor>0) then   
    update or insert into SIG02_TICKETMEDIO_DATA
      (data,filial,ocorrencias,valor,ticket_medio)
      values
      (:data,:filial,:ocorrencias,:valor,:ticket_medio)
      matching (data,filial);
      
  end
  ticket_medio = 0;
  if (soma_valor<>0 and soma_ocorrencias>0) then
       ticket_medio = :soma_valor / :soma_ocorrencias;
  suspend;      


end^
set term ;^





--==============================================================================



set term ^;
create or alter procedure md_sigcaut2_data_rank_valor
( p_filial float, p_de timestamp, p_ate timestamp, p_count int)
returns ( ctprod_codigo varchar(18),valor float,qtde float ,rank_valor int)
as
declare variable filial_de float;
declare variable filial_ate float;

begin
--------------------------------------------------------------------------------
--  monta o rank de produtos ordenando decrescente o valor venddido
-- params:
--   p_filial -> codigo da filial desejada
--   p_de -> data referencia de
--   p_ate -> data ate
--   p_count -> quantas ira retornar do rank
--------------------------------------------------------------------------------

   -- scalar os valores nao informados
   if (p_ate is null) then
      p_ate = cast('today' as timestamp);
   if (p_de is null) then 
      p_de = :p_ate - 180;
   if (p_count is null) then
      p_count = 10;
   if (p_filial is null) then 
      select min(codigo) from filial
      into :p_filial;
               
               
   filial_de = :p_filial;
   filial_ate = :p_filial;            
   if (:p_filial <= 0 ) then
   begin
     filial_de = 0;
     filial_ate = 999;
   end            
               
               
   for  select 
      codigo,valor, qtde,
      rank() over (order by valor desc) as rank_valor
    from (select a.codigo,sum(a.qtde) qtde, sum(a.valor) valor from sigcaut2_data a
    where (filial between :filial_de and :filial_ate) and (data between :p_de and :p_ate)
    group by a.codigo rows :p_count)
    into :ctprod_codigo,:valor,:qtde,:rank_valor
    do
    begin
    
      suspend;
    end

end^
set term ;^

--==============================================================================


set term ^;
create or alter procedure md_sig02_rank_cliente
( p_filial float, p_de timestamp, p_ate timestamp, p_count int)
returns ( sigcad_codigo float,valor float,rank_valor int)
as
declare variable filial_de float;
declare variable filial_ate float;
begin
--------------------------------------------------------------------------------
--  monta o rank de vendas por cliente ordenando decrescente o valor venddido
-- params:
--   p_filial -> codigo da filial desejada
--   p_data -> data referencia limite final para os dados data ate
--   p_dias -> quantidade de dias a retroceder para obter a data de
--   p_count -> quantas ira retornar do rank
--------------------------------------------------------------------------------

   -- scalar os valores nao informados
   if (p_ate is null) then
      p_ate = cast('today' as timestamp);
   if (p_de is null) then 
      p_de = :p_ate - 180;
   if (p_count is null) then
      p_count = 10;
   if (p_filial is null) then 
      select min(codigo) from filial
      into :p_filial;
       
   filial_de = :p_filial;
   filial_ate = :p_filial;            
   if (:p_filial <= 0 ) then
   begin
     filial_de = 0;
     filial_ate = 999;
   end            
               
               
   for  select 
      clifor,valor, 
      rank() over (order by valor desc) as rank_valor
    from (select a.clifor, sum(a.valor) valor from sig02 a
    where (filial between :filial_de and :filial_ate) and (data between :p_de and :p_ate)
    group by a.clifor rows :p_count)
    into :sigcad_codigo,:valor,:rank_valor
    do
    begin
    
      suspend;
    end

end^
set term ;^

--==============================================================================

set term ^;
create or alter procedure md_estoque_sem_venda
( p_filial float, p_de timestamp, p_ate timestamp, p_count int)
returns ( ctprod_codigo varchar(18), qtde float,valor float,rank_valor int)
as
declare variable filial_de float;
declare variable filial_ate float;
begin


   -- scalar os valores nao informados
   if (p_ate is null) then
      select max(data) from sigcaut2_data
      where data > 'today'-90
      into :p_ate;
   if (p_de is null) then 
      p_de = :p_ate;
      
   if (p_count is null) then
      p_count = 10;
   if (p_filial is null) then 
      select min(codigo) from filial
      into :p_filial;
       
   filial_de = :p_filial;
   filial_ate = :p_filial;            
   if (:p_filial <= 0 ) then
   begin
     filial_de = 0;
     filial_ate = 999;
   end            
   
   
        for select codigo,qestfin,valor, rank() over (order by valor desc) as rank_valor  from 
        (
        select codigo, qestfin, (qestfin * c.precovenda) valor 
        from ctprodsd a join ctprod_filial c on (c.codigo=a.codigo and c.FILIAL=a.filial) 
        where
        a.QESTFIN >0 and c.precovenda>0 and
        not exists  (select 1 from sigcaut2_data b 
                     where a.codigo=b.codigo and a.filial between :filial_de and :filial_ate
                           and b.data between :p_de and :p_ate and valor >0
                       ) 
        ) x
        rows :p_count
        into :ctprod_codigo, :qtde, :valor, :rank_valor
        do

        begin


          suspend;
        end
   
   
   
   
end^
set term ;^


--     select * from md_estoque_sem_venda(0,null,null,20);

--==============================================================================


commit work;


--select * from md_sigcaut2_medias(0,'1');

/*
-- exemplo de teste
select first 100 a.codigo, a.grupo, b.* 
from ctprod a
   , md_sigcaut2_agrupado_medias(1,a.codigo) b
*/

--select * from md_sigcaut2_medias (1,'1');