

create PROCEDURE dbo.ALP_qryJm_GetKitPtsAndHrsSM_sp
	(
	@KitRef int = 0,
	@LocId varchar(10) = '',
	@ItemId pItemId = ''  OUTPUT,
	@Points int = 0  OUTPUT,
	@Hours int = 0  OUTPUT
	)
AS
set nocount on
SELECT  @ItemId = STI.ItemId,@Hours = isnull(I.AlpDfltHours,0), 
	@Points = isnull(I.AlpDfltPts,0)
FROM    ALP_tblJmSvcTktItem STI INNER JOIN
           ALP_tblSmItem_view I ON STI.ItemId = I.ItemCode
WHERE   (STI.TicketItemId = @KitRef)