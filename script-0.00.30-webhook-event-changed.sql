SET TERM ^ ;

CREATE or alter TRIGGER tr_webhook_saida_event_changed FOR WEBHOOK_SAIDA
ACTIVE AFTER INSERT OR UPDATE POSITION 0
AS 
BEGIN 
	/* enter trigger code here */ 
	POST_EVENT "webhook_saida_changed";
END^

SET TERM ; ^ 
