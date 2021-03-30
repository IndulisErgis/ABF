CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillServInsert]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@RecBillServId int output,
	@RecBillId int  = null,
	@Status  varchar(10) = null,
	@ServiceId varchar(24) = null,
	@Desc varchar(35) = null,
	@LocId varchar(10) = null,
	@ActivePrice decimal(20,10) = null,
	@ActiveCycleId int = null,
	@ActiveCost decimal(20,10) = null,
	@ActiveRMR decimal(20,10) = null,
	@AcctCode varchar(2) = null,
	@GLAcctSales varchar(40) = null,
	@GLAcctCOGS varchar(40) = null,
	@GLAcctInv varchar(40) = null,
	@DfltPrice decimal(20, 10) = null,
	@DfltCost decimal(20, 10) = null,
	@ServiceType smallint = null,
	@SysId int = null,
	@ExtRepPlanId int = null,
	@ContractId int = null,
	@InitialTerm smallint = null,
	@RenTerm smallint = null,
	@ServiceStartDate datetime = null,
	@BilledThruDate datetime = null,
	@FinalBillDate datetime = null,
	@AllowGlobalPriceChangeYn bit = null,
	@MinMths smallint = null,
	@NoChangePriorTo datetime = null,
	@AutoRenYn bit = null,
	@NotifyYn bit = null,
	@CanReasonId int = null,
	@CanComments text = null,
	@CanReportDate datetime = null,
	@CanServEndDate datetime = null,
	@CanCustId varchar(10) = null,
	@CanCustName varchar(30) = null,
	@CanSiteName varchar(80) = null,
	@CanCustFirstName varchar(30) = null,
	@CanSiteFirstName varchar(30) = null,
	@Processed bit = null,
	@ModifiedBy VARCHAR(50) = NULL,
	@ModifiedDate DATETIME = NULL
)
AS
BEGIN
	INSERT INTO ALP_tblArAlpSiteRecBillServ
		([RecBillId], [Status], [ServiceID],[Desc],[LocID],[ActivePrice],[ActiveCycleId],[ActiveCost],[ActiveRMR],[AcctCode],
		 [GLAcctSales],[GLAcctCOGS],[GLAcctInv],[DfltPrice],[DfltCost],[ServiceType],[SysId],[ExtRepPlanId],[ContractId],
		 [InitialTerm],[RenTerm],[ServiceStartDate],[BilledThruDate],[FinalBillDate],[AllowGlobalPriceChangeYN],[MinMths],
		 [NoChangePriorTo],[AutoRenYn],[NotifyYn],[CanReasonId],[CanComments],[CanReportDate],[CanServEndDate],[CanCustId],[CanCustName],
		 [CanSiteName],[CanCustFirstName],[CanSiteFirstName],[Processed], [ModifiedBy], ModifiedDate)
	VALUES (
		@RecBillId, @Status,@ServiceId,@Desc,@LocId,@ActivePrice,@ActiveCycleId,@ActiveCost,@ActiveRMR,@AcctCode,
		@GLAcctSales,@GLAcctCOGS,@GLAcctInv,@DfltPrice,@DfltCost,@ServiceType,@SysId,@ExtRepPlanId,@ContractId,
		@InitialTerm,@RenTerm,@ServiceStartDate,@BilledThruDate,@FinalBillDate,@AllowGlobalPriceChangeYn,@MinMths,@NoChangePriorTo,
		@AutoRenYn,@NotifyYn,@CanReasonId,@CanComments,@CanReportDate,@CanServEndDate,@CanCustId,@CanCustName,@CanSiteName,
		@CanCustFirstName,@CanSiteFirstName,@Processed, @ModifiedBy, @ModifiedDate)
		
	SET @RecBillServId = @@Identity
END