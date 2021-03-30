
CREATE VIEW dbo.ALP_lkpJmSvcTktDivId AS 
SELECT TOP 100 PERCENT DivisionId, Division, Name, InactiveYN, GlSegId 
FROM dbo.ALP_tblArAlpDivision WHERE (InactiveYN = 0) ORDER BY Division