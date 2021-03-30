CREATE PROCEDURE [dbo].[ALP_qrySISiteSysItem_GetBySiteId]
(
	@SiteId INT
)
AS
BEGIN
	SELECT
		[s].[SysItemId],
		[s].[SysId], 
		[s].[ItemId], 
		[s].[Desc], 
		[s].[LocId], 
		[s].[PanelYN], 
		[s].[SerNum], 
		[s].[EquipLoc], 
		[s].[Qty], 
		[s].[UnitCost], 
		[s].[WarrPlanId], 
		[s].[WarrTerm], 
		[s].[WarrStarts], 
		[s].[WarrExpires], 
		[s].[Comments], 
		[s].[RemoveYN], 
		[s].[Zone], 
		[s].[TicketId], 
		[s].[WorkOrderId], 
		[s].[RepPlanId], 
		[s].[LeaseYN], 
		[s].[ts], 
		[s].[ModifiedBy], 
		[s].[ModifiedDate],
		[s].[SysDesc],
		[s].[SysType],
		[s].[SiteId],
		[s].[sysTypeId]
	FROM [dbo].[ALP_tblArAlpSiteSysItem_view] [s]
	WHERE [s].[SiteId] = @SiteId
END