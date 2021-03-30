
CREATE VIEW dbo.ALP_lkpServiceResolutionId AS
SELECT [ALP_tblJmResolution].[ResolutionId], [ALP_tblJmResolution].[ResolutionCode], 
[ALP_tblJmResolution].[Desc], [ALP_tblJmResolution].[Action], [ALP_tblJmResolution].[PointFactor], 
[ALP_tblJmResolution].[InactiveYN] FROM ALP_tblJmResolution 
WHERE ((([ALP_tblJmResolution].[Action])='Service') And 
(([ALP_tblJmResolution].[InactiveYN])=0))