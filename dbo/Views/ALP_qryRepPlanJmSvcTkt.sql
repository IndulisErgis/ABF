
CREATE VIEW [dbo].[ALP_qryRepPlanJmSvcTkt]
AS
SELECT     RepPlanId, SysId, CreateDate, TicketId
FROM         dbo.ALP_tblJmSvcTkt
WHERE     (RepPlanId IS NULL)