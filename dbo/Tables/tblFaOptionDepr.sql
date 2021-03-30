CREATE TABLE [dbo].[tblFaOptionDepr] (
    [DeprType]    VARCHAR (6) NOT NULL,
    [PdInYr]      SMALLINT    CONSTRAINT [DF__tblFaOpti__PdInY__1388ACEE] DEFAULT (0) NOT NULL,
    [PdProcessed] SMALLINT    CONSTRAINT [DF__tblFaOpti__PdPro__147CD127] DEFAULT (0) NOT NULL,
    [BeginPd]     SMALLINT    CONSTRAINT [DF__tblFaOpti__Begin__1570F560] DEFAULT (0) NOT NULL,
    [EndPd]       SMALLINT    CONSTRAINT [DF__tblFaOpti__EndPd__16651999] DEFAULT (0) NOT NULL,
    [FiscalYear]  SMALLINT    CONSTRAINT [DF__tblFaOpti__Fisca__17593DD2] DEFAULT (0) NOT NULL,
    [GLPd]        SMALLINT    CONSTRAINT [DF__tblFaOptio__GLPd__184D620B] DEFAULT (0) NOT NULL,
    [Process]     TINYINT     CONSTRAINT [DF__tblFaOpti__Proce__19418644] DEFAULT (0) NOT NULL,
    [SortOrder]   SMALLINT    CONSTRAINT [DF__tblFaOpti__SortO__1A35AA7D] DEFAULT (0) NOT NULL,
    [ts]          ROWVERSION  NULL,
    [CF]          XML         NULL,
    [Type]        TINYINT     NOT NULL,
    CONSTRAINT [PK__tblFaOptionDepr__6B79F03D] PRIMARY KEY CLUSTERED ([DeprType] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblFaOptionDepr] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblFaOptionDepr] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblFaOptionDepr] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblFaOptionDepr] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaOptionDepr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaOptionDepr';

