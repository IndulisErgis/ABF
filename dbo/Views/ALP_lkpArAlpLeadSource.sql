
CREATE VIEW dbo.ALP_lkpArAlpLeadSource
AS
SELECT     TOP 100 PERCENT LeadSourceId, LeadSource, [Desc], InactiveYN
FROM         dbo.ALP_tblArAlpLeadSource
WHERE     (InactiveYN = 0)
ORDER BY LeadSource