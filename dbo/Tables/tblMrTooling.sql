CREATE TABLE [dbo].[tblMrTooling] (
    [ToolingId]       VARCHAR (10)         NOT NULL,
    [Descr]           [dbo].[pDescription] NULL,
    [Qty]             [dbo].[pDec]         CONSTRAINT [DF__tblMrToolin__Qty__1E3E72E7] DEFAULT (0) NOT NULL,
    [VendorId]        [dbo].[pVendorID]    NULL,
    [Cost]            [dbo].[pDec]         CONSTRAINT [DF__tblMrTooli__Cost__1F329720] DEFAULT (0) NOT NULL,
    [StorageLocation] VARCHAR (10)         NULL,
    [Notes]           TEXT                 NULL,
    [Consumable]      BIT                  NOT NULL,
    [MGID]            VARCHAR (10)         NULL,
    [ts]              ROWVERSION           NULL,
    [CF]              XML                  NULL,
    CONSTRAINT [PK__tblMrTooling__4EB45FB4] PRIMARY KEY CLUSTERED ([ToolingId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlMGID]
    ON [dbo].[tblMrTooling]([MGID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrTooling] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrTooling] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrTooling] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrTooling] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrTooling';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrTooling';

