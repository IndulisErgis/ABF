CREATE TABLE [dbo].[tblHrIndGenInfo] (
    [IndId]                       [dbo].[pEmpID] NOT NULL,
    [LastName]                    NVARCHAR (20)  NULL,
    [FirstName]                   NVARCHAR (15)  NULL,
    [MiddleInit]                  NVARCHAR (1)   NULL,
    [Address1]                    NVARCHAR (30)  NULL,
    [Address2]                    NVARCHAR (60)  NULL,
    [City]                        NVARCHAR (30)  NULL,
    [State]                       NVARCHAR (2)   NULL,
    [ZipCode]                     NVARCHAR (12)  NULL,
    [CountryCode]                 NVARCHAR (6)   NULL,
    [HomePhone]                   NVARCHAR (13)  NULL,
    [CellPhone]                   NVARCHAR (13)  NULL,
    [BusinessPhone]               NVARCHAR (13)  NULL,
    [BusinessExtension]           NVARCHAR (5)   NULL,
    [SSN]                         NVARCHAR (255) NULL,
    [DOB]                         DATETIME       NULL,
    [EthnicityTypeCodeID]         BIGINT         NULL,
    [GenderTypeCodeID]            BIGINT         NULL,
    [MaritalStatusTypeCodeID]     BIGINT         NULL,
    [VeteranStatusTypeCodeID]     BIGINT         NULL,
    [StartDate]                   DATETIME       NULL,
    [TerminationDate]             DATETIME       NULL,
    [Manager]                     [dbo].[pEmpID] NULL,
    [CorporateOfficer]            BIT            CONSTRAINT [DF_tblHrIndGenInfo_CorporateOfficer] DEFAULT ((0)) NOT NULL,
    [SeasonalEmployee]            BIT            CONSTRAINT [DF_tblHrIndGenInfo_SeasonalEmployee] DEFAULT ((0)) NOT NULL,
    [LaborClass]                  NVARCHAR (3)   NULL,
    [StatutoryEmployee]           BIT            CONSTRAINT [DF_tblHrIndGenInfo_StatutoryEmployee] DEFAULT ((0)) NOT NULL,
    [EmergencyContact]            NVARCHAR (20)  NULL,
    [ContactWorkPhone]            NVARCHAR (13)  NULL,
    [ContactHomePhone]            NVARCHAR (13)  NULL,
    [ContactCellPhone]            NVARCHAR (13)  NULL,
    [ContactRelation]             NVARCHAR (18)  NULL,
    [WorkEmail]                   [dbo].[pEmail] NULL,
    [HomeEmail]                   [dbo].[pEmail] NULL,
    [Internet]                    [dbo].[pWeb]   NULL,
    [CitizenshipTypeCodeID]       BIGINT         NULL,
    [WorkAuthorizationExpiration] DATETIME       NULL,
    [PayDistribution]             TINYINT        CONSTRAINT [DF_tblHrIndGenInfo_PayDistribution] DEFAULT ((0)) NOT NULL,
    [CF]                          XML            NULL,
    [ts]                          ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndGenInfo] PRIMARY KEY CLUSTERED ([IndId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndGenInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndGenInfo';

