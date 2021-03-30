CREATE TABLE [dbo].[tblPaTransDeductHist] (
    [PostRun]     [dbo].[pPostRun]  NOT NULL,
    [TransID]     INT               NULL,
    [EmployeeId]  [dbo].[pEmpID]    NULL,
    [DeductCode]  VARCHAR (3)       NULL,
    [LaborClass]  VARCHAR (3)       NULL,
    [Hours]       [dbo].[pDec]      NOT NULL,
    [Amount]      [dbo].[pDec]      NOT NULL,
    [TransDate]   DATETIME          NULL,
    [SeqNo]       VARCHAR (3)       NULL,
    [Note]        VARCHAR (255)     NULL,
    [CheckNumber] [dbo].[pCheckNum] NULL,
    [CheckSeqNo]  INT               NULL,
    [Voided]      BIT               NOT NULL,
    [PaMonth]     TINYINT           NOT NULL,
    [ts]          ROWVERSION        NULL,
    [CF]          XML               NULL,
    [Id]          INT               NOT NULL,
    [PaYear]      SMALLINT          NOT NULL,
    [CheckId]     INT               NULL,
    CONSTRAINT [PK_tblPaTransDeductHist] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransDeductHist_CheckId]
    ON [dbo].[tblPaTransDeductHist]([CheckId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransDeductHist_PaYearPaMonthEmployeeId]
    ON [dbo].[tblPaTransDeductHist]([PaYear] ASC, [PaMonth] ASC, [EmployeeId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlCheckSeqNo]
    ON [dbo].[tblPaTransDeductHist]([CheckSeqNo] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaTransDeductHist] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaTransDeductHist] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaTransDeductHist] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaTransDeductHist] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransDeductHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransDeductHist';

