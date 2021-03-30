﻿CREATE TABLE [dbo].[tblPoRequestRouteUser] (
    [SeqNum]  INT           IDENTITY (1, 1) NOT NULL,
    [RouteId] NVARCHAR (10) NULL,
    [UserId]  INT           NULL,
    [CF]      XML           NULL,
    CONSTRAINT [PK__tblPoRequestRouteUser] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestRouteUser';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestRouteUser';

