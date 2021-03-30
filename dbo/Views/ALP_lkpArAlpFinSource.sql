CREATE VIEW dbo.ALP_lkpArAlpFinSource    
AS    
SELECT     TOP 100 PERCENT FinSourceId, FinSource, [Desc], InactiveYN    
FROM         dbo. ALP_tblArAlpFinSource    
WHERE     (InactiveYN = 0)    
ORDER BY FinSource