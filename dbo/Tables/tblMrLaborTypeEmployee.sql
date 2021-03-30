CREATE TABLE [dbo].[tblMrLaborTypeEmployee] (
    [LaborTypeID] VARCHAR (10)   NOT NULL,
    [EmployeeID]  [dbo].[pEmpID] NOT NULL,
    [ts]          ROWVERSION     NULL,
    [CF]          XML            NULL,
    CONSTRAINT [PK__tblMrLaborTypeEm__5F1FD1A7] PRIMARY KEY CLUSTERED ([LaborTypeID] ASC, [EmployeeID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlLaborTypeID]
    ON [dbo].[tblMrLaborTypeEmployee]([LaborTypeID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlEmployeeID]
    ON [dbo].[tblMrLaborTypeEmployee]([EmployeeID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrLaborTypeEmployee] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrLaborTypeEmployee] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrLaborTypeEmployee] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrLaborTypeEmployee] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrLaborTypeEmployee';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrLaborTypeEmployee';

