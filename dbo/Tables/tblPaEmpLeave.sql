CREATE TABLE [dbo].[tblPaEmpLeave] (
    [EmployeeId]  [dbo].[pEmpID] NOT NULL,
    [LeaveCodeId] [dbo].[pCode]  NOT NULL,
    [CF]          XML            NULL,
    [ts]          ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpLeave] PRIMARY KEY CLUSTERED ([EmployeeId] ASC, [LeaveCodeId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpLeave';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpLeave';

