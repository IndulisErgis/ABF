CREATE TABLE [dbo].[tblMpVarianceCodes] (
    [VarianceCode] VARCHAR (10)         NOT NULL,
    [Descr]        [dbo].[pDescription] NULL,
    [ActiveYN]     BIT                  CONSTRAINT [DF_tblMpVarianceCodes_ActiveYN] DEFAULT (0) NOT NULL,
    [ts]           ROWVERSION           NULL,
    [CF]           XML                  NULL,
    PRIMARY KEY CLUSTERED ([VarianceCode] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMpVarianceCodes] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMpVarianceCodes] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMpVarianceCodes] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMpVarianceCodes] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpVarianceCodes';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpVarianceCodes';

