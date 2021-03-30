 
CREATE VIEW [dbo].[ALP_lkpJmTimeCode]
AS
SELECT     TOP 100 PERCENT TimeCodeID, TimeCode, [Desc], TimeType, InactiveYN,
CASE WHEN TimeType = 0 THEN 'Job'
	ELSE 'Other' 
END AS Type 
FROM         dbo.ALP_tblJmTimeCode
WHERE     (InactiveYN = 0)
ORDER BY TimeCode