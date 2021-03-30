CREATE TABLE [dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] (
    [SalesRep]           VARCHAR (3)   NOT NULL,
    [CommSplitPct]       FLOAT (53)    NOT NULL,
    [CommAmt]            [dbo].[pDec]  NOT NULL,
    [Comments]           TEXT          NULL,
    [ProjectId]          VARCHAR (10)  NULL,
    [TicketId]           INT           NOT NULL,
    [CustId]             VARCHAR (10)  NOT NULL,
    [SiteId]             INT           NOT NULL,
    [SiteName]           VARCHAR (112) NULL,
    [InvcNum]            VARCHAR (15)  NULL,
    [TotalCommissionAmt] [dbo].[pDec]  NULL,
    [CommPaidDate]       DATETIME      NULL,
    [Status]             VARCHAR (10)  NULL,
    [CommPayNowYn]       BIT           NOT NULL,
    [ForcePayNow]        VARCHAR (1)   NOT NULL,
    [WorkCode]           VARCHAR (10)  NULL,
    [CsFlagYn]           VARCHAR (3)   NOT NULL,
    [CsConnectYn]        VARCHAR (3)   NULL,
    [TODate]             DATETIME      NULL,
    [JobPrice]           [dbo].[pDec]  NULL,
    [InvcBilledAmt]      [dbo].[pDec]  NULL,
    [InvcDate]           DATETIME      NULL,
    [InvcBalance]        [dbo].[pDec]  NULL,
    [InvcStatus]         VARCHAR (4)   NULL,
    [RMRAdded]           [dbo].[pDec]  NULL,
    [RecurSvcPaidYn]     VARCHAR (3)   NOT NULL,
    [PayYn]              BIT           NULL,
    [CommToBePaidFlag]   VARCHAR (3)   NOT NULL
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs_ByRep] TO PUBLIC
    AS [dbo];

