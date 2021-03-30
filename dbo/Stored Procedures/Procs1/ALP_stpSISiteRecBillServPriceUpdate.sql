CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillServPriceUpdate]  
(
	-- NP Added @PriceLockedYn
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@RecBillServPriceId int,  
	@RecBillServId int,  
	@StartBillDate datetime = null,  
	@EndBillDate datetime = null,  
	@Price decimal(20,10) = null,  
	@UnitCost decimal(20,10) = null,  
	@RMR decimal(20,10) = null,  
	@RMRChange decimal(20,10) = null,  
	@Reason tinyint = null,  
	@JobOrdNum varchar(12) = null,  
	@ActiveYn bit = null,  
	@PriceLockedYn bit = null,
	@ModifiedBy VARCHAR(50) = NULL,
	@ModifiedDate DATETIME = NULL
)
AS  
BEGIN
	UPDATE [dbo].[ALP_tblArAlpSiteRecBillServPrice]
	SET	[RecBillServId] = @RecBillServId,  
		[StartBillDate] = @StartBillDate,  
		[EndBillDate] = @EndBillDate,  
		[Price] = @Price,  
		[UnitCost] = @UnitCost,  
		[RMR] = @RMR,  
		[RMRChange] = @RMRChange,  
		[Reason] = @Reason,  
		[JobOrdNum] = @JobOrdNum,  
		[ActiveYn] = @ActiveYn,
		[PriceLockedYn] = @PriceLockedYn,
		[ModifiedBy] = @ModifiedBy,
		[ModifiedDate] = @ModifiedDate
	WHERE [RecBillServPriceId] = @RecBillServPriceId
END