CREATE TABLE [dbo].[tblArSalesRepSec] (
    [ID]            BIGINT            NOT NULL,
    [SalesRepID]    [dbo].[pSalesRep] NOT NULL,
    [SecSalesRepID] [dbo].[pSalesRep] NOT NULL,
    [Notes]         NVARCHAR (MAX)    NULL,
    [CF]            XML               NULL,
    [ts]            ROWVERSION        NULL,
    CONSTRAINT [PK_tblArSalesRepSec] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesRepSec';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesRepSec';

