CREATE TABLE [dbo].[tblMpOrderReleases] (
    [OrderNo]           [dbo].[pTransID] NOT NULL,
    [ReleaseNo]         INT              NOT NULL,
    [Routing]           TINYINT          CONSTRAINT [DF__tblMpOrde__Routi__1336D48F] DEFAULT (0) NOT NULL,
    [Status]            TINYINT          CONSTRAINT [DF__tblMpOrde__Statu__142AF8C8] DEFAULT (0) NOT NULL,
    [EstStartDate]      DATETIME         NULL,
    [CustId]            [dbo].[pCustID]  NULL,
    [SalesOrder]        VARCHAR (8)      NULL,
    [PurchaseOrder]     VARCHAR (25)     NULL,
    [PriorityCode]      SMALLINT         CONSTRAINT [DF__tblMpOrde__Prior__151F1D01] DEFAULT (0) NULL,
    [UOM]               [dbo].[pUom]     NULL,
    [Qty]               [dbo].[pDec]     CONSTRAINT [DF__tblMpOrderR__Qty__1613413A] DEFAULT (1) NOT NULL,
    [OrderSource]       INT              CONSTRAINT [DF_tblMpOrderReleases_OrderSource] DEFAULT ((0)) NOT NULL,
    [OrderCode]         VARCHAR (10)     NULL,
    [Notes]             TEXT             NULL,
    [ts]                ROWVERSION       NULL,
    [EstCompletionDate] DATETIME         NULL,
    [CF]                XML              NULL,
    [Id]                INT              IDENTITY (1, 1) NOT NULL,
    [Priority]          INT              CONSTRAINT [DF_tblMpOrderReleases_Priority] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblMpOrderReleases] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblMpOrderReleases_OrderNoReleaseNo]
    ON [dbo].[tblMpOrderReleases]([OrderNo] ASC, [ReleaseNo] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMpOrderReleases] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMpOrderReleases] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMpOrderReleases] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMpOrderReleases] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpOrderReleases';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpOrderReleases';

