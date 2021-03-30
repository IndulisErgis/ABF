/*
	sproc sets all Sevices to the same Cycle as their Billing Group parent
*/
CREATE PROCEDURE [dbo].[ALP_ArAlpRecBill_CycleCorrection]  AS
BEGIN

Declare @ErrorCode int
Select @ErrorCode = @@Error
  
	begin transaction

	update
		srbs
	set
		srbs.ActiveCycleId = srb.BillCycleid
	from
		ALP_tblArAlpSiteRecBillServ srbs
		inner join ALP_tblArAlpSiteRecBill srb
			on srbs.RecBillId = srb.RecBillId 
	where
		srb.BillCycleid != srbs.ActiveCycleId

	Select @ErrorCode = @@Error

   If @ErrorCode = 0
      COMMIT TRANSACTION
   Else
      ROLLBACK TRANSACTION

	return @ErrorCode

END