 CREATE VIEW dbo.ALP_lkpCSErrorCodes  
AS  
SELECT     TOP 100 PERCENT ErrorCode, ErrorCategory AS Type, ErrorMessage AS Message, SvcCode AS Service  
FROM         dbo.ALP_tblCSErrorCodes  
ORDER BY ErrorCode