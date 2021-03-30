
CREATE VIEW dbo.ALP_lkpJmCauseCode AS
SELECT [ALP_tblJmCauseCode].[CauseId], [ALP_tblJmCauseCode].[CauseCode], 
[ALP_tblJmCauseCode].[Desc], [ALP_tblJmCauseCode].[InactiveYN] FROM ALP_tblJmCauseCode WHERE
 ((([ALP_tblJmCauseCode].[InactiveYN])=0))