
CREATE PROCEDURE [dbo].[ALP_qry_AlpGetRepairPlanMinHoursPrice_sp]
@RepairPlanID VARCHAR(10) = NULL
AS
/*
Created by JM for EFI#1894 on 07/02/2010
*/
SELECT
MinHrs, MinHrsOut, MinHrsHol,
MinAmt, MinAmtOut, MinAmtHol,
HrlyReg, HrlyOutOfReg, HrlyHol
FROM ALP_tblArAlpRepairPlan
WHERE RepPlanID = @RepairPlanID