CREATE TABLE [dbo].[tblPaEmpPict] (
    [EmployeeId] [dbo].[pEmpID] NOT NULL,
    [PictItem]   IMAGE          NULL,
    [CF]         XML            NULL,
    [ts]         ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpPict] PRIMARY KEY CLUSTERED ([EmployeeId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpPict';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpPict';

