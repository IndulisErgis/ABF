
CREATE VIEW [dbo].[ALP_lkpJmClassCode]
--EFI# 1454 MAH 08/25/04 - modified to ignore null, blank class
AS
SELECT     TOP 100 PERCENT ClassId
FROM         dbo.tblArCust
WHERE ClassId is not null and CLassID <> ''
GROUP BY ClassId
ORDER BY ClassId