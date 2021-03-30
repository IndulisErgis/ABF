CREATE TABLE [dbo].[ALP_tblQMU] (
    [UserName]        VARCHAR (30)   NOT NULL,
    [RoleID]          INT            NOT NULL,
    [SalesRepID]      VARCHAR (3)    NOT NULL,
    [Supervisor]      VARCHAR (30)   NULL,
    [AlpSalesRepDtls] NVARCHAR (250) NULL,
    [AlpSalesRepImg]  IMAGE          NULL,
    CONSTRAINT [PK_ALP_tblQMU] PRIMARY KEY CLUSTERED ([UserName] ASC)
);

