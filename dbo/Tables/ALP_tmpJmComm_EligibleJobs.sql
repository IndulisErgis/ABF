CREATE TABLE [dbo].[ALP_tmpJmComm_EligibleJobs] (
    [ID]               INT          IDENTITY (1, 1) NOT NULL,
    [TicketId]         INT          NOT NULL,
    [ProjectId]        VARCHAR (10) NULL,
    [SalesRep]         VARCHAR (3)  NULL,
    [CustId]           VARCHAR (10) NOT NULL,
    [CustName]         VARCHAR (50) NULL,
    [SiteId]           INT          NOT NULL,
    [InvcNum]          VARCHAR (15) NULL,
    [CommAmt]          [dbo].[pDec] CONSTRAINT [DF_tmpJmComm_EligibleJobs_CommAmt] DEFAULT (0) NULL,
    [CommPaidDate]     DATETIME     NULL,
    [Status]           VARCHAR (10) NULL,
    [CommPayNowYn]     BIT          CONSTRAINT [DF_tmpJmComm_EligibleJobs_CommPayNowYn] DEFAULT (0) NOT NULL,
    [InvcStatus]       VARCHAR (4)  NULL,
    [WorkCodeID]       INT          NULL,
    [WorkCode]         VARCHAR (20) NULL,
    [CsConnectYn]      VARCHAR (3)  CONSTRAINT [DF_tmpJmComm_EligibleJobs_CsConnectYn] DEFAULT ('') NULL,
    [TODate]           DATETIME     NULL,
    [JobCompltDate]    DATETIME     NULL,
    [JobPrice]         [dbo].[pDec] CONSTRAINT [DF_tmpJmComm_EligibleJobs_JobPrice] DEFAULT (0) NULL,
    [ProjectTotPrice]  [dbo].[pDec] CONSTRAINT [DF_tmpJmComm_EligibleJobs_ProjectTotPrice] DEFAULT (0) NULL,
    [ProjectTotBilled] [dbo].[pDec] CONSTRAINT [DF_tmpJmComm_EligibleJobs_ProjectTotBilled] DEFAULT (0) NULL,
    [InvcBilledAmt]    [dbo].[pDec] CONSTRAINT [DF_tmpJmComm_EligibleJobs_InvcBilledAmt] DEFAULT (0) NULL,
    [InvcDate]         DATETIME     NULL,
    [InvcPaidDate]     DATETIME     NULL,
    [InvcBalance]      [dbo].[pDec] CONSTRAINT [DF_tmpJmComm_EligibleJobs_InvcBalance] DEFAULT (0) NULL,
    [RecurSvcPaidYn]   VARCHAR (3)  CONSTRAINT [DF_tmpJmComm_EligibleJobs_InvcIncludeRecurAmtYn] DEFAULT ('') NULL,
    [RMRAdded]         [dbo].[pDec] CONSTRAINT [DF_tmpJmComm_EligibleJobs_RMRAdded] DEFAULT (0) NULL,
    [CommToBePaidFlag] BIT          CONSTRAINT [DF_tmpJmComm_EligibleJobs_CommToBePaidFlag] DEFAULT (0) NULL,
    [PayrollDate]      DATETIME     NULL,
    [JobCreateDate]    DATETIME     NULL,
    [ts]               ROWVERSION   NULL,
    CONSTRAINT [PK_tmpJmComm_EligibleJobs] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tmpJmComm_EligibleJobs_ProjectID]
    ON [dbo].[ALP_tmpJmComm_EligibleJobs]([ProjectId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_tmpJmComm_EligibleJobs_TicketID]
    ON [dbo].[ALP_tmpJmComm_EligibleJobs]([TicketId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_EligibleJobs] TO PUBLIC
    AS [dbo];

