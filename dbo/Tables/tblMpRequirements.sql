CREATE TABLE [dbo].[tblMpRequirements] (
    [TransId]           INT                  IDENTITY (1, 1) NOT NULL,
    [ReleaseId]         INT                  NOT NULL,
    [ReqId]             INT                  NOT NULL,
    [ParentId]          INT                  NULL,
    [IndLevel]          INT                  NOT NULL,
    [Step]              INT                  NULL,
    [Description]       [dbo].[pDescription] NULL,
    [Type]              TINYINT              CONSTRAINT [DF_tblMpRequirements_Type] DEFAULT ((0)) NOT NULL,
    [BLT]               INT                  CONSTRAINT [DF_tblMpRequirements_BLT] DEFAULT ((0)) NOT NULL,
    [QTY]               [dbo].[pDec]         CONSTRAINT [DF_tblMpRequirements_QTY] DEFAULT ((1)) NOT NULL,
    [ReqSeq]            INT                  CONSTRAINT [DF_tblMpRequirements_ReqSeq] DEFAULT ((0)) NOT NULL,
    [CF]                XML                  NULL,
    [ts]                ROWVERSION           NULL,
    [OrderNo]           VARCHAR (10)         NULL,
    [ReleaseNo]         INT                  NULL,
    [_ParentId]         INT                  NULL,
    [EstProcessTime]    BIGINT               CONSTRAINT [DF_tblMpRequirements_EstProcessTime] DEFAULT ((0)) NOT NULL,
    [EstStartDate]      DATETIME             NULL,
    [EstCompletionDate] DATETIME             NULL,
    CONSTRAINT [PK_tblMpRequirements] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMpRequirements_ParentId]
    ON [dbo].[tblMpRequirements]([ParentId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblMpRequirements_ReleaseIdReqId]
    ON [dbo].[tblMpRequirements]([ReleaseId] ASC, [ReqId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpRequirements';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpRequirements';

