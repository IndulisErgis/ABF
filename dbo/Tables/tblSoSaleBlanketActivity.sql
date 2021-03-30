CREATE TABLE [dbo].[tblSoSaleBlanketActivity] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [BlanketRef]    INT              NOT NULL,
    [BlanketDtlRef] INT              NULL,
    [EntryDate]     DATETIME         CONSTRAINT [DF_tblSoSaleBlanketActivity_EntryDate] DEFAULT (getdate()) NOT NULL,
    [TransDate]     DATETIME         CONSTRAINT [DF_tblSoSaleBlanketActivity_TransDate] DEFAULT (getdate()) NOT NULL,
    [PostRun]       [dbo].[pPostRun] NULL,
    [TransId]       [dbo].[pTransID] NOT NULL,
    [TransType]     SMALLINT         NOT NULL,
    [RecType]       SMALLINT         NOT NULL,
    [Qty]           [dbo].[pDec]     CONSTRAINT [DF_tblSoSaleBlanketActivity_Qty] DEFAULT ((0)) NOT NULL,
    [PriceExt]      [dbo].[pDec]     CONSTRAINT [DF_tblSoSaleBlanketActivity_PriceExt] DEFAULT ((0)) NOT NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblSoSaleBlanketActivity] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSoSaleBlanketActivity_BlanketDtlRef]
    ON [dbo].[tblSoSaleBlanketActivity]([BlanketDtlRef] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblSoSaleBlanketActivity_BlanketRef]
    ON [dbo].[tblSoSaleBlanketActivity]([BlanketRef] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanketActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanketActivity';

