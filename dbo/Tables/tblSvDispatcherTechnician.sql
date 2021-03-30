CREATE TABLE [dbo].[tblSvDispatcherTechnician] (
    [ID]           BIGINT     NOT NULL,
    [EmployeeID]   BIGINT     NOT NULL,
    [TechnicianID] BIGINT     NOT NULL,
    [CF]           XML        NULL,
    [ts]           ROWVERSION NULL,
    CONSTRAINT [PK_tblSvDispatcherTechnician] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSvDispatcherTechnician_EmployeeID_TechnicianID]
    ON [dbo].[tblSvDispatcherTechnician]([EmployeeID] ASC, [TechnicianID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvDispatcherTechnician';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvDispatcherTechnician';

