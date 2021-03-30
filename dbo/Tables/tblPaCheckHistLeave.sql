CREATE TABLE [dbo].[tblPaCheckHistLeave] (
    [PostRun]      [dbo].[pPostRun] NOT NULL,
    [Id]           INT              NOT NULL,
    [CheckId]      INT              NOT NULL,
    [LeaveCodeId]  [dbo].[pCode]    NULL,
    [HoursAccrued] [dbo].[pDec]     CONSTRAINT [DF_tblPaCheckHistLeave_HoursAccrued] DEFAULT ((0)) NOT NULL,
    [ts]           ROWVERSION       NULL,
    CONSTRAINT [PK_tblPaCheckHistLeave] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckHistLeave_PostRunCheckId]
    ON [dbo].[tblPaCheckHistLeave]([PostRun] ASC, [CheckId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistLeave';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistLeave';

