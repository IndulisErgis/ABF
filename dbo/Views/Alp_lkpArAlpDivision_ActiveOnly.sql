CREATE VIEW dbo.Alp_lkpArAlpDivision_ActiveOnly  
AS  
SELECT [ALP_tblArAlpDivision].[DivisionId], [ALP_tblArAlpDivision].[Division],   
    [ALP_tblArAlpDivision].[Name], [ALP_tblArAlpDivision].[InactiveYN]  
FROM ALP_tblArAlpDivision   
WHERE ((([ALP_tblArAlpDivision].[InactiveYN]) = 0))