CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillServPriceInsert]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@RecBillServPriceId int output,
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
	@PriceLockedYn BIT = NULL,
	@ModifiedBy VARCHAR(50) = NULL,
	@ModifiedDate DATETIME = NULL
)
AS
BEGIN
	INSERT INTO [dbo].[ALP_tblArAlpSiteRecBillServPrice]
	([RecBillServId],[StartBillDate],[EndBillDate],[Price],[UnitCost],[RMR],[RMRChange],[Reason],[JobOrdNum],[ActiveYn],[PriceLockedYn], [ModifiedBy], [ModifiedDate])
	VALUES 
	(	@RecBillServId,
		@StartBillDate,
		@EndBillDate,
		@Price,
		@UnitCost,
		@RMR,
		@RMRChange,
		@Reason,
		@JobOrdNum,
		@ActiveYn,
		@PriceLockedYn,
		@ModifiedBy,
		@ModifiedDate)
	
	SET @RecBillServPriceId = @@identity
END