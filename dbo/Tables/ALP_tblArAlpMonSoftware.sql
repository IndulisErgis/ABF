CREATE TABLE [dbo].[ALP_tblArAlpMonSoftware] (
    [MonSoftwareId]        INT           IDENTITY (1, 1) NOT NULL,
    [Name]                 VARCHAR (50)  NULL,
    [ConnectMethod]        VARCHAR (50)  CONSTRAINT [DF_tblArAlpMonSoftware_ConnectMethod] DEFAULT (0) NULL,
    [Path]                 VARCHAR (255) NULL,
    [RequestTimeTolerance] INT           CONSTRAINT [DF_tblArAlpMonSoftware_RequestTimeTolerance] DEFAULT (10) NOT NULL,
    [ts]                   ROWVERSION    NULL,
    [EncryptYN]            BIT           NULL,
    CONSTRAINT [PK_tblArAlpMonSoftware] PRIMARY KEY CLUSTERED ([MonSoftwareId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpMonSoftware] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpMonSoftware] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpMonSoftware] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpMonSoftware] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Data access method: 0 = none; 1 = Linked Server; 2 = SQLServer direct; 3 = Access ( Jet ); 4 = CSCollect, IP:PORT ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALP_tblArAlpMonSoftware', @level2type = N'COLUMN', @level2name = N'ConnectMethod';

