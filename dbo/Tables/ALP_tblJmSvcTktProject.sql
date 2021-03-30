CREATE TABLE [dbo].[ALP_tblJmSvcTktProject] (
    [SvcTktProjectId]      INT          IDENTITY (1, 1) NOT NULL,
    [ProjectId]            VARCHAR (10) NULL,
    [SiteId]               INT          NULL,
    [Desc]                 VARCHAR (50) NULL,
    [PromoId]              INT          NULL,
    [LeadSourceId]         INT          NULL,
    [ReferBy]              VARCHAR (50) NULL,
    [FudgeFactor]          [dbo].[pDec] NULL,
    [AdjPoints]            FLOAT (53)   NULL,
    [AdjComments]          TEXT         NULL,
    [EstMatCost]           FLOAT (53)   NULL,
    [EstLabCost]           FLOAT (53)   NULL,
    [EstLabHrs]            SMALLINT     NULL,
    [NewWorkYn]            BIT          CONSTRAINT [DF_tblJmSvcTktProject_NewWorkYn] DEFAULT (0) NULL,
    [MarketCodeId]         INT          NULL,
    [FudgeFactorHrs]       [dbo].[pDec] CONSTRAINT [DF_tblJmSvcTktProject_FudgeFactorHrs] DEFAULT (0) NULL,
    [AdjHrs]               [dbo].[pDec] CONSTRAINT [DF_tblJmSvcTktProject_AdjHrs] DEFAULT (0) NULL,
    [InitialOrderDate]     DATETIME     NULL,
    [Contact]              VARCHAR (25) NULL,
    [ContactPhone]         VARCHAR (15) NULL,
    [BranchID]             INT          NULL,
    [CustPoNum]            VARCHAR (25) NULL,
    [ts]                   ROWVERSION   NULL,
    [LeadSalesRepID]       VARCHAR (3)  NULL,
    [BillingNotes]         NTEXT        NULL,
    [ProjectNotes]         NTEXT        NULL,
    [HoldProjInvCommitted] BIT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblJmSvcTktProject] PRIMARY KEY CLUSTERED ([SvcTktProjectId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [IX_tblJmSvcTktProject] UNIQUE NONCLUSTERED ([ProjectId] ASC) WITH (FILLFACTOR = 80)
);


GO

CREATE TRIGGER [dbo].[trgJmSvcTktProjectD] ON [dbo].[ALP_tblJmSvcTktProject] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.ProjectId = ALP_tblJmSvcTkt.ProjectId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.ProjectId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmSvcTktProjectD', @FldVal, 'ALP_tblJmSvcTkt.ProjectId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktProject] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktProject] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktProject] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktProject] TO PUBLIC
    AS [dbo];

