CREATE TABLE [dbo].[tblCmContactAddress] (
    [ID]            BIGINT               NOT NULL,
    [ContactID]     BIGINT               NOT NULL,
    [Descr]         [dbo].[pDescription] NULL,
    [Sequence]      SMALLINT             CONSTRAINT [DF_tblCmContactAddress_Sequence] DEFAULT ((0)) NOT NULL,
    [Addr1]         NVARCHAR (30)        NULL,
    [Addr2]         NVARCHAR (60)        NULL,
    [City]          NVARCHAR (30)        NULL,
    [Region]        NVARCHAR (10)        NULL,
    [Country]       [dbo].[pCountry]     NULL,
    [PostalCode]    NVARCHAR (10)        NULL,
    [Notes]         NVARCHAR (MAX)       NULL,
    [Status]        TINYINT              CONSTRAINT [DF_tblCmContactAddress_Status] DEFAULT ((0)) NOT NULL,
    [LastUpdated]   DATETIME             NOT NULL,
    [LastUpdatedBy] [dbo].[pUserID]      NOT NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL,
    CONSTRAINT [PK_tblCmContactAddress] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCmContactAddress_ContactIDSequence]
    ON [dbo].[tblCmContactAddress]([ContactID] ASC, [Sequence] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactAddress';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactAddress';

