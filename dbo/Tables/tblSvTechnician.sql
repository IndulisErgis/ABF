CREATE TABLE [dbo].[tblSvTechnician] (
    [TechID]      [dbo].[pEmpID]       NOT NULL,
    [ScheduleID]  NVARCHAR (10)        NULL,
    [LocID]       [dbo].[pLocID]       NULL,
    [CrewYN]      BIT                  DEFAULT ((0)) NOT NULL,
    [Description] [dbo].[pDescription] NULL,
    [CF]          XML                  NULL,
    [ts]          ROWVERSION           NULL,
    [ID]          BIGINT               NOT NULL,
    [Password]    NVARCHAR (MAX)       NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSvTechnician_ID]
    ON [dbo].[tblSvTechnician]([ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnician';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnician';

