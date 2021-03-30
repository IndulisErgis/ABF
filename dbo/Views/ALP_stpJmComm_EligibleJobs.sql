﻿


CREATE VIEW [dbo].[ALP_stpJmComm_EligibleJobs]
--Displays completed jobs eligible for commission payment
AS
SELECT  EJ.ProjectID,EJ.TicketId,
	EJ.CustID,
	CustName = (SELECT CustName FROM tblArCust WHERE tblArCust.CustID = EJ.CustID),
	EJ.SiteId,
	EJ.InvcNum,
	--EJ.CommAmt,
	--EJ.CommPayNowYn,
	ST.SalesRepID as LeadSalesRep,
	ST.CommAmt as TotalCommissionAmt,
	ST.CommPaidDate,
	CS.SalesRep,
	CS.CommAmt as SalesRepCommAmt,
	CS.JobShare,
	CS.Comments
FROM ALP_tmpJmComm_EligibleJobs EJ
INNER JOIN dbo.ALP_tblJmSvcTkt ST
ON EJ.TicketID = ST.TicketID
LEFT OUTER JOIN dbo.ALP_tblJmSvcTktCommSplit CS
	ON EJ.TicketID = CS.TicketID
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];

