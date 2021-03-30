CREATE PROCEDURE dbo.ALP_rptCSBSComparisonByErrorCategory_sp    
 (    
 @ErrorCategory varchar(1) = ''    
 )    
AS    
--Set nocount on    
--Use temp table for selected errors    
--Delete prior contents    
DELETE FROM ALP_tmpCSBSComparisonResultsErrors    
DELETE FROM ALP_tmpCSBSComparisonResults    
    
--Insert values for selected category    
INSERT INTO ALP_tmpCSBSComparisonResultsErrors    
 (Transmitter,    
 ErrorCode,    
 BSCustId,    
 BSSiteID,    
 CSCustId,    
 CSSiteId,    
 BSMonStartDate,    
 CSHasSignalsYn)    
 (    
 SELECT E.Transmitter,    
   E.ErrorCode,    
  E.BSCustId,    
  E.BSSiteID,    
  E.CSCustId,    
  E.CSSiteId,    
  E.BSMonStartDate,    
  E.CSHasSignalsYn    
 FROM ALP_tblCSBSComparisonResultsErrors E    
  INNER JOIN ALP_tblCSErrorCodes EC    
  ON E.ErrorCode = EC.ErrorCode    
 WHERE (EC.ErrorCategory = @ErrorCategory)    
 )    
INSERT INTO ALP_tmpCSBSComparisonResults    
 (Transmitter)    
 (    
 SELECT DISTINCT Transmitter    
 FROM ALP_tmpCSBSComparisonResultsErrors    
 )    
    
--Use the above temp tables in following sproc, to produce recordset for report    
EXECUTE dbo.ALP_qryCSBSComparisonByErrorCategory_sp