CREATE TABLE [dbo].[tblMpHistoryOrderReleases] (
    [PostRun]           [dbo].[pPostRun] NOT NULL,
    [OrderNo]           [dbo].[pTransID] NOT NULL,
    [ReleaseNo]         INT              NOT NULL,
    [AssemblyId]        [dbo].[pItemID]  NULL,
    [RevisionNo]        VARCHAR (3)      NULL,
    [LocId]             [dbo].[pLocID]   NULL,
    [Planner]           VARCHAR (20)     NULL,
    [Routing]           TINYINT          DEFAULT ((0)) NOT NULL,
    [Status]            TINYINT          DEFAULT ((0)) NOT NULL,
    [EstStartDate]      DATETIME         NULL,
    [EstCompletionDate] DATETIME         NULL,
    [CustId]            [dbo].[pCustID]  NULL,
    [SalesOrder]        VARCHAR (8)      NULL,
    [PurchaseOrder]     VARCHAR (25)     NULL,
    [PriorityCode]      SMALLINT         DEFAULT ((0)) NULL,
    [UOM]               [dbo].[pUom]     NULL,
    [Qty]               [dbo].[pDec]     DEFAULT ((1)) NOT NULL,
    [OrderSource]       INT              NOT NULL,
    [OrderCode]         VARCHAR (10)     NULL,
    [Notes]             TEXT             NULL,
    [ts]                ROWVERSION       NULL,
    [CF]                XML              NULL,
    [ReleaseId]         INT              NOT NULL,
    [Priority]          INT              CONSTRAINT [DF_tblMpHistoryOrderReleases_Priority] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblMpHistoryOrderReleases] PRIMARY KEY CLUSTERED ([PostRun] ASC, [ReleaseId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryOrderReleases';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryOrderReleases';

