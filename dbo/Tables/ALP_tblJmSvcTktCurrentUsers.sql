CREATE TABLE [dbo].[ALP_tblJmSvcTktCurrentUsers] (
    [TicketId]       INT          NOT NULL,
    [UserId]         VARCHAR (50) NOT NULL,
    [TicketOpenTime] DATETIME     NOT NULL,
    CONSTRAINT [PK_ALP_tblJmSvcTktCurrentUsers] PRIMARY KEY CLUSTERED ([TicketId] ASC)
);

