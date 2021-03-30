CREATE TABLE [dbo].[tblMbMedia] (
    [MGID]  VARCHAR (10)   NOT NULL,
    [MID]   VARCHAR (10)   NOT NULL,
    [Notes] NVARCHAR (MAX) NULL,
    [Link]  NVARCHAR (MAX) NULL,
    [ts]    ROWVERSION     NULL,
    [CF]    XML            NULL,
    CONSTRAINT [PK_tblMbMedia] PRIMARY KEY NONCLUSTERED ([MGID] ASC, [MID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMbMedia] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMbMedia] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMbMedia] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMbMedia] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbMedia';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbMedia';

