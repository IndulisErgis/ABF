CREATE TABLE [dbo].[tblPoRequestRouteDetail] (
    [RouteId]        NVARCHAR (10) NOT NULL,
    [Level]          INT           NOT NULL,
    [UserId]         INT           NULL,
    [MinAmount]      [dbo].[pDec]  NULL,
    [MaxAmount]      [dbo].[pDec]  NULL,
    [BudgetApproval] BIT           DEFAULT ((0)) NULL,
    [CF]             XML           NULL,
    CONSTRAINT [PK__tblPoRequestRouteDetail] PRIMARY KEY CLUSTERED ([RouteId] ASC, [Level] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestRouteDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestRouteDetail';

