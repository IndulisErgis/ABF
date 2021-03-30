CREATE TABLE [dbo].[tblCfConfigFieldAction] (
    [ActionId]      BIGINT           NOT NULL,
    [FieldId]       BIGINT           NOT NULL,
    [SeqNum]        INT              NOT NULL,
    [ActionEvent]   TINYINT          CONSTRAINT [DF_tblCfConfigFieldAction_ActionEvent] DEFAULT ((0)) NOT NULL,
    [FieldValue]    NVARCHAR (50)    NULL,
    [ActionType]    TINYINT          CONSTRAINT [DF_tblCfConfigFieldAction_ActionType] DEFAULT ((0)) NOT NULL,
    [Action]        NVARCHAR (50)    NULL,
    [MessageText]   NVARCHAR (200)   NULL,
    [VariableId]    BIGINT           NULL,
    [VariableSetTo] NVARCHAR (200)   NULL,
    [FreightCharge] [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldAction_FreightCharge] DEFAULT ((0)) NOT NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfConfigFieldAction] PRIMARY KEY CLUSTERED ([ActionId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCfConfigFieldAction_FieldIdSeqNum]
    ON [dbo].[tblCfConfigFieldAction]([FieldId] ASC, [SeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldAction';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldAction';

