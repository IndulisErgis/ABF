

CREATE function [dbo].[ALP_ufxJmComm_UnpaidCommProjects]()
Returns table
AS
Return
(
	SELECT distinct top 100 percent
	ST.ProjectID
	FROM   dbo.ALP_tblJmSvcTkt ST
	WHERE (ST.Status <> 'canceled' 
		AND ST.Status <> 'cancelled' 
		AND ST.CommAmt <> 0 AND ST.CommPaidDate is null)
	ORDER BY ST.ProjectID
	
)
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_ufxJmComm_UnpaidCommProjects] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_ufxJmComm_UnpaidCommProjects] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_ufxJmComm_UnpaidCommProjects] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_ufxJmComm_UnpaidCommProjects] TO [JMCommissions]
    AS [dbo];

