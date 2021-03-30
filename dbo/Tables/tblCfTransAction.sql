CREATE TABLE [dbo].[tblCfTransAction] (
    [DetailId]      BIGINT           NOT NULL,
    [TransActionId] BIGINT           NOT NULL,
    [ActionId]      BIGINT           NOT NULL,
    [FieldId]       BIGINT           NOT NULL,
    [ValueId]       BIGINT           NULL,
    [SeqNum]        INT              NOT NULL,
    [ActionEvent]   TINYINT          CONSTRAINT [DF_tblCfTransAction_ActionEvent] DEFAULT ((0)) NOT NULL,
    [FieldValue]    NVARCHAR (50)    NULL,
    [ActionType]    TINYINT          CONSTRAINT [DF_tblCfTransAction_ActionType] DEFAULT ((0)) NOT NULL,
    [Action]        NVARCHAR (50)    NULL,
    [MessageText]   NVARCHAR (200)   NULL,
    [VariableId]    BIGINT           NULL,
    [VariableSetTo] NVARCHAR (200)   NULL,
    [FreightCharge] [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransAction_FreightCharge] DEFAULT ((0)) NOT NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfTransAction] PRIMARY KEY CLUSTERED ([TransActionId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransAction';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransAction';

