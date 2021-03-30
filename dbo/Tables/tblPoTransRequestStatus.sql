CREATE TABLE [dbo].[tblPoTransRequestStatus] (
    [TransId]      NVARCHAR (8)  NOT NULL,
    [RouteId]      NVARCHAR (10) NULL,
    [BudgetPeriod] SMALLINT      NULL,
    [BudgetYear]   SMALLINT      NULL,
    [Comments]     TEXT          NULL,
    [Level]        INT           NULL,
    [NotifyUser]   INT           NULL,
    [NotifyDate]   DATETIME      NULL,
    [CF]           XML           NULL,
    CONSTRAINT [PK__tblPoTransRequestStatus] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequestStatus';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequestStatus';

