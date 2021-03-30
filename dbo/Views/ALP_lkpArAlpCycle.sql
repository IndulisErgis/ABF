CREATE VIEW dbo.ALP_lkpArAlpCycle  
AS  
SELECT     TOP 100 PERCENT CycleId, Cycle, [Desc], Units  
FROM         dbo.ALP_tblArAlpCycle  
ORDER BY Cycle