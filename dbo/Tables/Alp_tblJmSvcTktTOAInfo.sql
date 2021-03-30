CREATE TABLE [dbo].[Alp_tblJmSvcTktTOAInfo] (
    [TicketId] INT  NOT NULL,
    [Email]    TEXT NULL,
    CONSTRAINT [PK_Alp_tblJmSvcTktTOAInfo] PRIMARY KEY CLUSTERED ([TicketId] ASC) WITH (FILLFACTOR = 80)
);

