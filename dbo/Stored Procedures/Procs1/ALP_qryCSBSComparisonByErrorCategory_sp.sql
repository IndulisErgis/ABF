
create PROCEDURE dbo.ALP_qryCSBSComparisonByErrorCategory_sp    
AS    
select E.Transmitter,    
 Errors = dbo.ALP_ufxCSBS_BatchErrorsForTransmitter_FromTMP(E.Transmitter)    
from ALP_tmpCSBSComparisonResults E    
ORDER BY E.Transmitter