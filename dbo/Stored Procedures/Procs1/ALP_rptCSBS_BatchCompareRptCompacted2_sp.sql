CREATE Procedure dbo.ALP_rptCSBS_BatchCompareRptCompacted2_sp  
As  
SELECT E.Transmitter,  
 Errors = dbo.ufxCSBS_BatchErrorsForTransmitter2(E.Transmitter)   
FROM ALP_tblCSBSComparisonResults E  
ORDER BY E.Transmitter  
return