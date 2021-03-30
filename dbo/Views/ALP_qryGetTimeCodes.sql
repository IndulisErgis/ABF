
CREATE VIEW dbo.ALP_qryGetTimeCodes
AS
SELECT     TOP 100 PERCENT TimeCode, TimeCodeID, [Desc], TimeType, ToggleOrder, BarColor, TextColor, InactiveYN
FROM         dbo.ALP_tblJmTimeCode
ORDER BY TimeCode