CREATE TABLE [dbo].[tblPaTransDeduct] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [PaYear]     SMALLINT         NOT NULL,
    [EmployeeId] [dbo].[pEmpID]   NULL,
    [DeductCode] [dbo].[pCode]    NULL,
    [LaborClass] NVARCHAR (3)     NULL,
    [Hours]      [dbo].[pDec]     CONSTRAINT [DF_tblPaTransDeduct_Hours] DEFAULT ((0)) NOT NULL,
    [Amount]     [dbo].[pDec]     CONSTRAINT [DF_tblPaTransDeduct_Amount] DEFAULT ((0)) NOT NULL,
    [TransDate]  DATETIME         NOT NULL,
    [SeqNo]      NVARCHAR (3)     NULL,
    [Note]       NVARCHAR (255)   NULL,
    [PostedYn]   BIT              CONSTRAINT [DF_tblPaTransDeduct_PostedYn] DEFAULT ((0)) NOT NULL,
    [PostRun]    [dbo].[pPostRun] NULL,
    [CF]         XML              NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblPaTransDeduct] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransDeduct_PaYearEmployeeId]
    ON [dbo].[tblPaTransDeduct]([PaYear] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransDeduct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransDeduct';

