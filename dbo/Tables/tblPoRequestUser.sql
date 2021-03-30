CREATE TABLE [dbo].[tblPoRequestUser] (
    [ID]                 INT             IDENTITY (1, 1) NOT NULL,
    [Username]           [dbo].[pUserID] NULL,
    [TravUserId]         INT             NULL,
    [Name]               NVARCHAR (100)  NULL,
    [Password]           NVARCHAR (512)  NULL,
    [Email]              NVARCHAR (256)  NULL,
    [Role]               SMALLINT        NULL,
    [RouteId]            NVARCHAR (10)   NULL,
    [AltUserId]          INT             NULL,
    [AltStartDate]       DATETIME        NULL,
    [AltEndDate]         DATETIME        NULL,
    [RequestAdmin]       BIT             NULL,
    [ApproveAdmin]       BIT             NULL,
    [EditPendingRequest] BIT             NULL,
    [CF]                 XML             NULL,
    CONSTRAINT [PK__tblPoRequestUser] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestUser';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoRequestUser';

