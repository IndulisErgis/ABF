CREATE TABLE [dbo].[tblMpSubContractSum] (
    [OrderNo]         [dbo].[pTransID]     NULL,
    [ReleaseNo]       VARCHAR (3)          NULL,
    [ReqID]           VARCHAR (4)          NULL,
    [TransId]         INT                  NOT NULL,
    [Description]     [dbo].[pDescription] NULL,
    [LeadTime]        INT                  DEFAULT ((0)) NOT NULL,
    [RequiredDate]    DATETIME             NULL,
    [OperationID]     VARCHAR (10)         NULL,
    [EstQtyRequired]  [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [EstPerPieceCost] [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [CostGroupID]     VARCHAR (6)          NULL,
    [DefaultVendorID] [dbo].[pVendorID]    NULL,
    [Status]          TINYINT              DEFAULT ((0)) NOT NULL,
    [Notes]           TEXT                 NULL,
    [ts]              ROWVERSION           NULL,
    [LinkSeqNum]      INT                  NULL,
    [CF]              XML                  NULL,
    CONSTRAINT [PK_tblMpSubContractSum] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpSubContractSum';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpSubContractSum';

