CREATE TABLE [dbo].[tblCmContactMethod] (
    [ID]            BIGINT          NOT NULL,
    [ContactID]     BIGINT          NOT NULL,
    [TypeID]        BIGINT          NOT NULL,
    [Value]         NVARCHAR (MAX)  NULL,
    [Status]        TINYINT         CONSTRAINT [DF_tblCmContactMethod_Status] DEFAULT ((0)) NOT NULL,
    [LastUpdated]   DATETIME        NOT NULL,
    [LastUpdatedBy] [dbo].[pUserID] NOT NULL,
    [CF]            XML             NULL,
    [ts]            ROWVERSION      NULL,
    CONSTRAINT [PK_tblCmContactMethod] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCmContactMethod_ContactIDLastUpdated]
    ON [dbo].[tblCmContactMethod]([ContactID] ASC, [LastUpdated] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactMethod';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactMethod';

