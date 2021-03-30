CREATE TABLE [dbo].[tblSmZoneGeographicLocation] (
    [ID]       BIGINT         NOT NULL,
    [ZoneID]   BIGINT         NOT NULL,
    [Location] NVARCHAR (255) NOT NULL,
    [CF]       XML            NULL,
    [ts]       ROWVERSION     NULL,
    CONSTRAINT [PK_tblSmZoneGeographicLocation] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmZoneGeographicLocation_ZoneIDLocation]
    ON [dbo].[tblSmZoneGeographicLocation]([ZoneID] ASC, [Location] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmZoneGeographicLocation';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmZoneGeographicLocation';

