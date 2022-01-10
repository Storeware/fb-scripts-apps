grant select,insert, update on pet_atendimento to publicweb;
grant select,insert, update on PET_TIPO_ATENDIMENTO to publicweb;
grant select,insert, update on pet_atendimento to publicweb;




SET TERM ^ ;

CREATE or alter TRIGGER PET_ATENDIMENTO_GID FOR PET_ATENDIMENTO
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS 
BEGIN 
	/* enter trigger code here */ 
	if (new.gid is null) then
	   new.gid = uuid_to_char(gen_uuid());
END^

SET TERM ; ^ 



SET TERM ^ ;

CREATE or alter TRIGGER PET_ATENDIMENTO_ITENS_GID FOR PET_ATENDIMENTO_ITENS
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS 
BEGIN 
	/* enter trigger code here */ 
	if (new.gid is null) then
	   new.gid = uuid_to_char(gen_uuid());
END^

SET TERM ; ^ 
