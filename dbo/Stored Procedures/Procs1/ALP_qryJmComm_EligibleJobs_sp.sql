
CREATE Procedure [dbo].[ALP_qryJmComm_EligibleJobs_sp]
--Determines completed jobs eligible for commission payment
As
SET NOCOUNT ON
	/*Populates a temporary table of all completed jobs eligible for commission payment.*/
	DELETE FROM ALP_tmpJmComm_EligibleJobs
	INSERT INTO ALP_tmpJmComm_EligibleJobs 
		(
		TicketId,ProjectID,SalesRep,CustID,
		SiteId,InvcNum,CommAmt,
		CommPaidDate,Status,
		CommPayNowYn,
		InvcStatus)
		--function returns all completed jobs that have been invoiced, but not
		--yet had commissions paid.
		select TicketId,ProjectID,SalesRepID,CustID,
		SiteId,InvcNum,CommAmt,
		CommPaidDate,Status,
		CommPayNowYn,
		dbo.ALP_ufxJmComm_CheckInvcStatus(InvcNum)	/* 'PAID' or 'OPEN' */
		from  dbo.ALP_ufxJmComm_JobsCompleted()
		order by projectID,TicketID

--Check Invoice status for each job.   If not yet paid, remove job / project from table
	DELETE FROM ALP_tmpJmComm_EligibleJobs
	WHERE InvcStatus = 'OPEN'

--Check Project status.  If job is within a project, and project contains other jobs that are not yet complete, remove
--	job / project from the table.  Exception:  Leave in any jobs with "CommPayNowYn"
--	turned on.
	DELETE FROM ALP_tmpJmComm_EligibleJobs  
	WHERE CommPayNowYn = 0
		AND ProjectId is not null
		AND ProjectId <> '' 
		AND dbo.ALP_ufxJmComm_CheckProjStatus(ProjectID) <> 'Paid'

select * from ALP_tmpJmComm_EligibleJobs
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_qryJmComm_EligibleJobs_sp] TO [JMCommissions]
    AS [dbo];

