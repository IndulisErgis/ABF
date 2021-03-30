CREATE procedure dbo.ALP_qryCSBS_Batch_StoreParameters_sp 
-- EFI# 1762 added transmitter range processed 
 ( 
 @LastCSBSRunDate datetime, 
 @LastSignalDateAllowance int, 
 @LastCancelDateAllowance int, 
 @LastStartBillingAllowance int, 
 @StartTransmitter varchar(36), 
 @EndTransmitter varchar(36) 
 ) 
AS 
SET NOCOUNT ON 
UPDATE ALP_tblCSOptions 
SET LastCSBSRunDate = @LastCSBSRunDate, 
 LastSignalDateAllowance = @LastSignalDateAllowance, 
 LastCancelDateAllowance = @LastCancelDateAllowance, 
 LastStartBillingAllowance = @LastStartBillingAllowance, 
 LastCompareStartTrans = @StartTransmitter, 
 LastCompareEndTrans = @EndTransmitter