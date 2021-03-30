CREATE TABLE [dbo].[tblHrIndDependent] (
    [ID]                 BIGINT         NOT NULL,
    [IndId]              [dbo].[pEmpID] NOT NULL,
    [RelationTypeCodeID] BIGINT         NULL,
    [SSN]                NVARCHAR (255) NULL,
    [DOB]                DATETIME       NULL,
    [LastName]           NVARCHAR (20)  NULL,
    [FirstName]          NVARCHAR (15)  NULL,
    [FullTimeStudent]    BIT            CONSTRAINT [DF_tblHrIndDependent_FullTimeStudent] DEFAULT ((0)) NOT NULL,
    [GenderTypeCodeID]   BIGINT         NULL,
    [Smoker]             BIT            CONSTRAINT [DF_tblHrIndDependent_Smoker] DEFAULT ((0)) NOT NULL,
    [CF]                 XML            NULL,
    [ts]                 ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndDependent] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndDependent_IndId]
    ON [dbo].[tblHrIndDependent]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndDependent';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndDependent';

