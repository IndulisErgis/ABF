CREATE PROCEDURE [dbo].[ALP_stpSISiteSysItemUpdate]
(
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@SysItemId INT,
	@SysId INT = NULL,
	@ItemId VARCHAR(24) = NULL,
	@Desc VARCHAR(255) = NULL,
	@LocId VARCHAR(10)= NULL,
	@PanelYN BIT = NULL,
	@SerNum VARCHAR(35) = NULL,
	@EquipLoc VARCHAR(30) = NULL,
	@Qty FLOAT = NULL,
	@UnitCost NUMERIC(20,10) = NULL,
	@WarrPlanId INT = NULL,
	@WarrTerm SMALLINT = NULL,
	@WarrStarts DATETIME = NULL,
	@WarrExpires DATETIME = NULL,
	@Comments TEXT = NULL,
	@RemoveYN BIT = NULL,
	@Zone VARCHAR(5) = NULL,
	@TicketId INT = NULL,
	@WorkOrderId INT = NULL,
	@RepPlanId INT = NULL,
	@LeaseYN BIT = NULL,
	@ModifiedBy VARCHAR(50) = NULL,
	@ModifiedDate DATETIME = NULL
)
AS
BEGIN
	UPDATE [si]
	SET	SysId = @SysId,
		ItemId = @ItemId,
		[Desc] = @Desc,
		LocId = @LocId,
		PanelYN = @PanelYN,
		SerNum = @SerNum,
		EquipLoc = @EquipLoc,
		Qty = @Qty,
		UnitCost = @UnitCost,
		WarrPlanId = @WarrPlanId,
		WarrTerm = @WarrTerm,
		WarrStarts = @WarrStarts,
		WarrExpires = @WarrExpires,
		Comments = @Comments,
		RemoveYN = @RemoveYN,
		Zone = @Zone,
		TicketId = @TicketId,
		WorkOrderId = @WorkOrderId,
		RepPlanId = @RepPlanId,
		LeaseYN = @LeaseYN,
		ModifiedBy = @ModifiedBy,
		ModifiedDate = @ModifiedDate
	FROM [dbo].[ALP_tblArAlpSiteSysItem] AS [si]
	WHERE	[si].[SysItemId] = @SysItemId
END