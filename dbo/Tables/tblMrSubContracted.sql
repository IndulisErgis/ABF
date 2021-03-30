CREATE TABLE [dbo].[tblMrSubContracted] (
    [OperationId]     VARCHAR (10)         NOT NULL,
    [VendorId]        [dbo].[pVendorID]    NOT NULL,
    [Description]     [dbo].[pDescription] NULL,
    [UnitCost]        [dbo].[pDec]         CONSTRAINT [DF__tblMrSubC__UnitC__18859991] DEFAULT (0) NOT NULL,
    [LeadTime]        INT                  CONSTRAINT [DF__tblMrSubC__LeadT__1979BDCA] DEFAULT (0) NOT NULL,
    [MinQty]          INT                  CONSTRAINT [DF__tblMrSubC__MinQt__1A6DE203] DEFAULT (0) NOT NULL,
    [Notes]           TEXT                 NULL,
    [SubConUserDef01] VARCHAR (50)         NULL,
    [MGID]            VARCHAR (10)         NULL,
    [DfltVendorId]    BIT                  CONSTRAINT [DF__tblMrSubC__DfltV__1B62063C] DEFAULT (1) NOT NULL,
    [GLAcct1]         [dbo].[pGlAcct]      NULL,
    [CostGroupID]     VARCHAR (10)         NULL,
    [ts]              ROWVERSION           NULL,
    [CF]              XML                  NULL,
    CONSTRAINT [PK__tblMrSubContract__6FE114AC] PRIMARY KEY CLUSTERED ([OperationId] ASC, [VendorId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqltblMrSubContractedOperationId]
    ON [dbo].[tblMrSubContracted]([OperationId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlMGID]
    ON [dbo].[tblMrSubContracted]([MGID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrSubContracted] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrSubContracted] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrSubContracted] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrSubContracted] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrSubContracted';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrSubContracted';

