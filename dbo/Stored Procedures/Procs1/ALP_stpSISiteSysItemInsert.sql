
CREATE PROCEDURE [dbo].[ALP_stpSISiteSysItemInsert]
(
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@SysItemId INT OUTPUT,
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
	INSERT INTO [dbo].[ALP_tblArAlpSiteSysItem]
	(SysId, ItemId, [Desc], LocId, PanelYN, SerNum, EquipLoc, Qty, UnitCost, WarrPlanId, WarrTerm, WarrStarts, WarrExpires, Comments, RemoveYN, Zone, TicketId, WorkOrderId, RepPlanId, LeaseYN, ModifiedBy, ModifiedDate)
	VALUES
	(	@SysId,
		@ItemId,
		@Desc,
		@LocId,
		@PanelYN,
		@SerNum,
		@EquipLoc,
		@Qty,
		@UnitCost,
		@WarrPlanId,
		@WarrTerm,
		@WarrStarts,
		@WarrExpires,
		@Comments,
		@RemoveYN,
		@Zone,
		@TicketId,
		@WorkOrderId,
		@RepPlanId,
		@LeaseYN,
		@ModifiedBy,
		@ModifiedDate)
	SET @SysItemId = @@IDENTITY
END