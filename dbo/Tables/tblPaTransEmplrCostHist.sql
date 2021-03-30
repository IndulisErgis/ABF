CREATE TABLE [dbo].[tblPaTransEmplrCostHist] (
    [PostRun]      [dbo].[pPostRun]  NOT NULL,
    [TransID]      INT               NULL,
    [EmployeeId]   [dbo].[pEmpID]    NULL,
    [DeductCode]   VARCHAR (3)       NULL,
    [DepartmentId] VARCHAR (10)      NULL,
    [LaborClass]   VARCHAR (3)       NULL,
    [Hours]        [dbo].[pDec]      NOT NULL,
    [Amount]       [dbo].[pDec]      NOT NULL,
    [TransDate]    DATETIME          NULL,
    [SeqNo]        VARCHAR (3)       NULL,
    [Note]         VARCHAR (255)     NULL,
    [CheckNumber]  [dbo].[pCheckNum] NULL,
    [CheckSeqNo]   INT               NULL,
    [Voided]       BIT               NOT NULL,
    [PaMonth]      TINYINT           NOT NULL,
    [ts]           ROWVERSION        NULL,
    [CF]           XML               NULL,
    [Id]           INT               NOT NULL,
    [PaYear]       SMALLINT          NOT NULL,
    [CheckId]      INT               NULL,
    CONSTRAINT [PK_tblPaTransEmplrCostHist] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransEmplrCostHist_CheckId]
    ON [dbo].[tblPaTransEmplrCostHist]([CheckId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransEmplrCostHist_PaYearPaMonthEmployeeId]
    ON [dbo].[tblPaTransEmplrCostHist]([PaYear] ASC, [PaMonth] ASC, [EmployeeId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlCheckSeqNo]
    ON [dbo].[tblPaTransEmplrCostHist]([CheckSeqNo] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaTransEmplrCostHist] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaTransEmplrCostHist] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaTransEmplrCostHist] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaTransEmplrCostHist] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEmplrCostHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEmplrCostHist';

