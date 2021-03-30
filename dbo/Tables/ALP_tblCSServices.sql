CREATE TABLE [dbo].[ALP_tblCSServices] (
    [CSSvcID]   INT           NOT NULL,
    [CentralID] INT           NULL,
    [SvcCode]   NVARCHAR (15) NULL,
    [Descr]     NVARCHAR (75) NULL,
    [Verify]    VARCHAR (2)   NULL,
    [ActiveYn]  BIT           NULL,
    [ts]        ROWVERSION    NULL,
    CONSTRAINT [PK_tblCSServices] PRIMARY KEY NONCLUSTERED ([CSSvcID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [IX_tblCSServices] UNIQUE CLUSTERED ([SvcCode] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSServices] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSServices] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSServices] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSServices] TO PUBLIC
    AS [dbo];

