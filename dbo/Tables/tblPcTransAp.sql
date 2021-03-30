CREATE TABLE [dbo].[tblPcTransAp] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [TransId]         INT          NOT NULL,
    [EntryNum]        INT          NOT NULL,
    [Type]            TINYINT      CONSTRAINT [DF_tblPcTransAp_Type] DEFAULT ((0)) NOT NULL,
    [ProjectDetailId] INT          NOT NULL,
    [ActivityId]      INT          NOT NULL,
    [Markup]          [dbo].[pDec] CONSTRAINT [DF_tblPcTransAp_Markup] DEFAULT ((0)) NOT NULL,
    [CF]              XML          NULL,
    [ts]              ROWVERSION   NULL,
    CONSTRAINT [PK_tblPcTransAp] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [uiPcTransAp]
    ON [dbo].[tblPcTransAp]([TransId] ASC, [EntryNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTransAp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTransAp';

