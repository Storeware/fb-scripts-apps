
/*
  muda os estado de produtos
*/
SET TERM ^ ;
CREATE or alter TRIGGER SIGCAUT1_MUDA_ESTADO FOR SIGCAUT1 ACTIVE
BEFORE UPDATE POSITION 0
AS
  declare  novoEstado integer;
  
begin
  /* Trigger text */
  IF (updating) THEN
  begin
  
      if (new.LOCALARMAZENAMENTO<>coalesce(old.LOCALARMAZENAMENTO,''))
      then
      begin
         select first 1 estado from sigcaut1armaz z
           where new.LOCALARMAZENAMENTO between z.de and z.ate
           and filial = new.filial
           into :novoestado;
         if ( (coalesce(:novoestado,0)>0) and (new.estprod<:novoestado )) then
            new.estprod = :novoestado;
      
        if (novoestado is null) then
         select first 1 estado from sigcaut1armaz z
           where new.LOCALARMAZENAMENTO between z.de and z.ate
           and filial = 0
           into :novoestado;
         if ( (coalesce(:novoestado,0)>0) and (new.estprod<:novoestado )) then
            new.estprod = :novoestado;

      end
         
      if (new.qtdebaixa>=new.qtde) then
      begin
        select first 1 pdvEstadoPara from sigcaut1estados
           where codigo=new.estprod and estConcluido='S'
           into :novoestado  ;
        if ((:novoestado>0) and (new.estprod<:novoestado)) then
          new.estprod = :novoestado;
      end
  
      IF (NEW.estprod <> OLD.ESTPROD) THEN
         NEW.HRESTADO = 'NOW';
  
  end
  
  
  IF (inserting) THEN NEW.HRESTADO='NOW';
  if (new.id = 0) then
     new.id = gen_id(sigcaut1id, 1);
  
end^
SET TERM ; ^

commit;