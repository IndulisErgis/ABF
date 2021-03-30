CREATE TABLE [dbo].[tblHrIndLicense] (
    [ID]                BIGINT         NOT NULL,
    [IndId]             [dbo].[pEmpID] NOT NULL,
    [LicenseTypeCodeID] BIGINT         NOT NULL,
    [LicenseNo]         NVARCHAR (50)  NULL,
    [LicenseExpDate]    DATETIME       NULL,
    [LicenseComment]    NVARCHAR (MAX) NULL,
    [LicenseState]      NVARCHAR (2)   NULL,
    [CF]                XML            NULL,
    [ts]                ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndLicense] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndLicense_IndId]
    ON [dbo].[tblHrIndLicense]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndLicense';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndLicense';

