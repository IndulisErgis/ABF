
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateWorkPartsRecurJobPartsOhPct]
	@PartsOhPct numeric(20,10),
	@Ticketid int	
AS
update ALP_tbljmsvctkt set 
 PartsOhPct=@PartsOhPct	
where ticketid=@Ticketid