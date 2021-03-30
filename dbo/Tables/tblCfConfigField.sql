CREATE TABLE [dbo].[tblCfConfigField] (
    [FieldId]        BIGINT           NOT NULL,
    [ConfigId]       BIGINT           NOT NULL,
    [GroupId]        BIGINT           NOT NULL,
    [FieldCode]      NVARCHAR (50)    NOT NULL,
    [Label]          NVARCHAR (75)    NOT NULL,
    [TabOrder]       INT              NOT NULL,
    [LineType]       TINYINT          CONSTRAINT [DF_tblCfConfigField_LineType] DEFAULT ((0)) NOT NULL,
    [DataType]       TINYINT          CONSTRAINT [DF_tblCfConfigField_DataType] DEFAULT ((0)) NOT NULL,
    [TextLength]     INT              NULL,
    [AllowQty]       BIT              CONSTRAINT [DF_tblCfConfigField_AllowQty] DEFAULT ((0)) NOT NULL,
    [MultipleSelect] BIT              CONSTRAINT [DF_tblCfConfigField_MultipleSelect] DEFAULT ((0)) NOT NULL,
    [LimitToList]    BIT              CONSTRAINT [DF_tblCfConfigField_LimitToList] DEFAULT ((0)) NOT NULL,
    [DisplayWhen]    NVARCHAR (200)   NULL,
    [HelpText]       NVARCHAR (200)   NULL,
    [Precision]      INT              CONSTRAINT [DF_tblCfConfigField_Precision] DEFAULT ((0)) NOT NULL,
    [NumMinValue]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigField_NumMinValue] DEFAULT ((0)) NOT NULL,
    [NumMaxValue]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigField_NumMaxValue] DEFAULT ((0)) NOT NULL,
    [NumIncrement]   [dbo].[pDecimal] NULL,
    [PrintGroup]     NVARCHAR (2)     NULL,
    [NumWarnYn]      BIT              CONSTRAINT [DF_tblCfConfigField_NumWarnYn] DEFAULT ((0)) NOT NULL,
    [DefaultValue]   NVARCHAR (50)    NULL,
    [FieldPriceYn]   BIT              CONSTRAINT [DF_tblCfConfigField_FieldPriceYn] DEFAULT ((0)) NOT NULL,
    [FieldPrice]     [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigField_FieldPrice] DEFAULT ((0)) NOT NULL,
    [PriceOption]    TINYINT          CONSTRAINT [DF_tblCfConfigField_PriceOption] DEFAULT ((0)) NOT NULL,
    [RequiredYn]     BIT              CONSTRAINT [DF_tblCfConfigField_RequiredYn] DEFAULT ((0)) NOT NULL,
    [LongDescr]      NVARCHAR (MAX)   NULL,
    [SmartIdLen]     INT              NULL,
    [SmartIdValue]   NVARCHAR (24)    NULL,
    [PictureId]      VARBINARY (MAX)  NULL,
    [CF]             XML              NULL,
    [ts]             ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfConfigField] PRIMARY KEY CLUSTERED ([FieldId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCfConfigField_ConfigIdFieldCode]
    ON [dbo].[tblCfConfigField]([ConfigId] ASC, [FieldCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigField';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigField';

