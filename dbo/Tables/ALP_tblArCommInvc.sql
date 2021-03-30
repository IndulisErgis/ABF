CREATE TABLE [dbo].[ALP_tblArCommInvc] (
    [AlpCounter]     INT              NOT NULL,
    [AlpCommTYpe]    TINYINT          NULL,
    [AlpAmtPossible] DECIMAL (20, 10) NULL,
    [Alpts]          ROWVERSION       NULL,
    CONSTRAINT [PK_ALP_tblArCommInvc] PRIMARY KEY CLUSTERED ([AlpCounter] ASC)
);

