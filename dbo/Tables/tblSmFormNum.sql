CREATE TABLE [dbo].[tblSmFormNum] (
    [FormId]   VARCHAR (15)      NOT NULL,
    [NextNum]  INT               CONSTRAINT [DF__tblSmForm__NextN__4C5A4352] DEFAULT (0) NOT NULL,
    [LockBy]   [dbo].[pUserID]   NULL,
    [WrkStnID] [dbo].[pWrkStnID] NULL,
    [LockDate] DATETIME          CONSTRAINT [DF__tblSmForm__LockD__4D4E678B] DEFAULT (getdate()) NULL,
    [ts]       ROWVERSION        NULL,
    CONSTRAINT [PK__tblSmFormNum__4B661F19] PRIMARY KEY CLUSTERED ([FormId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSmFormNum] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSmFormNum] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSmFormNum] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSmFormNum] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmFormNum';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmFormNum';

