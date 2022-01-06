create or alter view web_ctprod_atalho_titulo_comb
as
Select case when a.codigo_pai is null then a.codigo else a.codigo_pai end codigo_pai, 
       a.codigo,a.nome, cdpai.eh_pai, a.prioridade, a.QTDE_SELECIONAVEL, a.bmp
  From CTPROD_ATALHO_TITULO a
         left join (Select distinct b.codigo, 'S' eh_pai
                      From CTPROD_ATALHO_TITULO b
                             join ctprod_atalho_titulo c on (b.codigo = c.codigo_pai)) cdpai 
                      on (a.codigo = cdpai.codigo)
  --where a.codigo_pai = 1002                    
  order by codigo_pai;
  
  
  grant select on web_ctprod_atalho_titulo_comb to publicweb;