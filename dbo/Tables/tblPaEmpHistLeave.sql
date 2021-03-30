CREATE TABLE [dbo].[tblPaEmpHistLeave] (
    [Id]               INT                  IDENTITY (1, 1) NOT NULL,
    [EntryDate]        DATETIME             NOT NULL,
    [PaYear]           SMALLINT             NOT NULL,
    [PaMonth]          TINYINT              NOT NULL,
    [EmployeeId]       [dbo].[pEmpID]       NULL,
    [LeaveCodeId]      [dbo].[pCode]        NULL,
    [PrintedFlag]      BIT                  NOT NULL,
    [From]             NVARCHAR (2)         NULL,
    [EarningCode]      [dbo].[pCode]        NULL,
    [Description]      [dbo].[pDescription] NULL,
    [CheckNumber]      [dbo].[pCheckNum]    NULL,
    [AdjustmentDate]   DATETIME             NULL,
    [AdjustmentAmount] [dbo].[pDec]         NOT NULL,
    [CF]               XML                  NULL,
    [ts]               ROWVERSION           NULL,
    CONSTRAINT [PK_tblPaEmpHistLeave] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmpHistLeave_PaYearPaMonthEmployeeId]
    ON [dbo].[tblPaEmpHistLeave]([PaYear] ASC, [PaMonth] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistLeave';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistLeave';

