CREATE TABLE [dbo].[tblPaCheckLeave] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [CheckId]      INT           NOT NULL,
    [LeaveCodeId]  [dbo].[pCode] NULL,
    [HoursAccrued] [dbo].[pDec]  CONSTRAINT [DF_tblPaCheckLeave_HoursAccrued] DEFAULT ((0)) NOT NULL,
    [CF]           XML           NULL,
    [ts]           ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaCheckLeave] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckLeave_CheckId]
    ON [dbo].[tblPaCheckLeave]([CheckId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckLeave';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckLeave';

