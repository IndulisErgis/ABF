CREATE TABLE [dbo].[tblMbECONum] (
    [ECONum]         [dbo].[pInvoiceNum]  NOT NULL,
    [Descr]          [dbo].[pDescription] NULL,
    [Engineer]       VARCHAR (20)         NULL,
    [AssemblyId]     [dbo].[pItemID]      NULL,
    [CurrRevisionNo] VARCHAR (3)          NULL,
    [NewRevisionNo]  VARCHAR (3)          NULL,
    [ECODate]        DATETIME             NULL,
    [EffectiveDate]  DATETIME             NULL,
    [TypeRef]        INT                  NULL,
    [StatusRef]      INT                  NULL,
    [Other]          VARCHAR (20)         NULL,
    [OtherDate]      DATETIME             NULL,
    [Notes]          TEXT                 NULL,
    [ts]             ROWVERSION           NULL,
    [CF]             XML                  NULL,
    [_ECORef]        INT                  NULL,
    [ECORef]         INT                  NOT NULL,
    CONSTRAINT [PK_tblMbECONum] PRIMARY KEY CLUSTERED ([ECORef] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlECONum]
    ON [dbo].[tblMbECONum]([ECONum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbECONum';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbECONum';

