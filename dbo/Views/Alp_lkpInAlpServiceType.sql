CREATE VIEW [dbo].[Alp_lkpInAlpServiceType]
AS
SELECT     ServiceTypeId, [Service Type], CASE WHEN RecurringSvc = 1 THEN 'Recur Svc' ELSE 'Other' END AS Recur
FROM         dbo.Alp_tblArAlpServiceType