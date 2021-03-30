
CREATE VIEW dbo.Alp_lkpArAlpCancelReason  
AS  
SELECT     TOP 100 PERCENT ReasonId, Reason, [Desc], InactiveYN  
FROM         dbo.Alp_tblArAlpCancelReason  
WHERE     (InactiveYN = 0)  
ORDER BY Reason