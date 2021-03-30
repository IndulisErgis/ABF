CREATE TABLE [dbo].[tblPoRequestRouteHeader] (
    [RouteId]       NVARCHAR (10)  NOT NULL,
    [Description]   NVARCHAR (50)  NULL,
    [ApprovalEmail] NVARCHAR (MAX) NULL,
    [NotifyVendor]  BIT            NULL,
    [Inactive]      BIT            NULL,
    [CF]            XML            NULL,
    CONSTRAINT [PK__tblPoRequestRouteHeader] PRIMARY KEY CLUSTERED ([RouteId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestRouteHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestRouteHeader';

