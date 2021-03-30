Create View [dbo].[ALP_lkpArAlpCycle_ActiveOnly] as
SELECT     TOP 100 PERCENT CycleId, Cycle, [Desc], InactiveYN
FROM         dbo.ALP_tblArAlpCycle
WHERE     (InactiveYN = 0)
ORDER BY Cycle