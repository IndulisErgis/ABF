CREATE TABLE [dbo].[ALP_tblArAlpServiceProvider] (
    [ServiceProviderID] VARCHAR (10) NOT NULL,
    [ProductName]       VARCHAR (50) NOT NULL,
    [VendorID]          VARCHAR (10) NOT NULL,
    [Contact]           VARCHAR (50) NULL,
    [Phone]             VARCHAR (15) NULL,
    [RecurringSvc]      BIT          DEFAULT ((1)) NULL,
    [Inactive]          BIT          DEFAULT ((0)) NULL,
    [ts]                ROWVERSION   NULL
);

