CREATE TABLE [dbo].[tblArHistAddress] (
    [PostRun]    [dbo].[pPostRun] NOT NULL,
    [CustId]     [dbo].[pCustID]  NOT NULL,
    [Name]       VARCHAR (30)     NULL,
    [Contact]    VARCHAR (25)     NULL,
    [Attn]       VARCHAR (30)     NULL,
    [Address1]   VARCHAR (30)     NULL,
    [Address2]   VARCHAR (60)     NULL,
    [City]       VARCHAR (30)     NULL,
    [Region]     VARCHAR (10)     NULL,
    [Country]    [dbo].[pCountry] NULL,
    [PostalCode] VARCHAR (10)     NULL,
    [Phone]      VARCHAR (15)     NULL,
    [Fax]        VARCHAR (15)     NULL,
    [Email]      [dbo].[pEmail]   NULL,
    [Internet]   [dbo].[pWeb]     NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK_tblArHistAddress] PRIMARY KEY CLUSTERED ([PostRun] ASC, [CustId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistAddress';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistAddress';

