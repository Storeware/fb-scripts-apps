/* Suporte ao controle de estados no kanban do console
   DONE: mover para os scripts do StoreSetup */

update or insert into pet_atendimento_estados (gid,nome) values('1','Entrada') matching(gid);
update or insert into pet_atendimento_estados (gid,nome) values('2','Executando') matching(gid);
update or insert into pet_atendimento_estados (gid,nome) values('3','Concluído') matching(gid);

 grant select,insert,update,delete on pet_atendimento_estados to publicweb;

 

