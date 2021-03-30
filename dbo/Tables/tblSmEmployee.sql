CREATE TABLE [dbo].[tblSmEmployee] (
    [EmployeeId]       [dbo].[pEmpID]   NOT NULL,
    [LastName]         VARCHAR (20)     NULL,
    [FirstName]        VARCHAR (15)     NULL,
    [MiddleInit]       VARCHAR (1)      NULL,
    [AddressLine1]     VARCHAR (30)     NULL,
    [AddressLine2]     VARCHAR (60)     NULL,
    [ResidentCity]     VARCHAR (30)     NULL,
    [ResidentState]    VARCHAR (2)      NULL,
    [ZipCode]          VARCHAR (12)     NULL,
    [CountryCode]      [dbo].[pCountry] NULL,
    [SocialSecurityNo] NVARCHAR (255)   NULL,
    [PhoneNumber]      VARCHAR (13)     NULL,
    [WorkPhoneNo]      VARCHAR (13)     NULL,
    [WorkExtension]    VARCHAR (5)      NULL,
    [BirthDate]        DATETIME         NULL,
    [EmergrncyContact] VARCHAR (20)     NULL,
    [ContactWorkPhone] VARCHAR (13)     NULL,
    [ContactHomePhone] VARCHAR (13)     NULL,
    [ContactRelation]  VARCHAR (18)     NULL,
    [WorkEmail]        [dbo].[pEmail]   NULL,
    [HomeEmail]        [dbo].[pEmail]   NULL,
    [Internet]         [dbo].[pWeb]     NULL,
    [ts]               ROWVERSION       NULL,
    [CF]               XML              NULL,
    [Status]           TINYINT          CONSTRAINT [DF_tblSmEmployee_Status] DEFAULT ((0)) NOT NULL,
    [UID]              BIGINT           NOT NULL,
    CONSTRAINT [PK__tblSmEmployee] PRIMARY KEY CLUSTERED ([EmployeeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmEmployee_UID]
    ON [dbo].[tblSmEmployee]([UID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmEmployee_Status]
    ON [dbo].[tblSmEmployee]([Status] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmEmployee';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmEmployee';

