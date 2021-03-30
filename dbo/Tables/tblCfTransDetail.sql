CREATE TABLE [dbo].[tblCfTransDetail] (
    [DetailId]       BIGINT           NOT NULL,
    [GroupId]        BIGINT           NOT NULL,
    [FieldId]        BIGINT           NOT NULL,
    [FieldCode]      NVARCHAR (50)    NOT NULL,
    [Question]       NVARCHAR (75)    NULL,
    [TabOrder]       INT              NOT NULL,
    [LineType]       TINYINT          CONSTRAINT [DF_tblCfTransDetail_LineType] DEFAULT ((0)) NOT NULL,
    [DataType]       TINYINT          CONSTRAINT [DF_tblCfTransDetail_DataType] DEFAULT ((0)) NOT NULL,
    [TextLength]     INT              NULL,
    [AllowQty]       BIT              CONSTRAINT [DF_tblCfTransDetail_AllowQty] DEFAULT ((0)) NOT NULL,
    [MultipleSelect] BIT              CONSTRAINT [DF_tblCfTransDetail_MultipleSelect] DEFAULT ((0)) NOT NULL,
    [LimitToList]    BIT              CONSTRAINT [DF_tblCfTransDetail_LimitToList] DEFAULT ((0)) NOT NULL,
    [DisplayWhen]    NVARCHAR (200)   NULL,
    [HelpText]       NVARCHAR (200)   NULL,
    [Precision]      INT              CONSTRAINT [DF_tblCfTransDetail_Precision] DEFAULT ((0)) NOT NULL,
    [NumMinValue]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetail_NumMinValue] DEFAULT ((0)) NOT NULL,
    [NumMaxValue]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetail_NumMaxValue] DEFAULT ((0)) NOT NULL,
    [NumIncrement]   [dbo].[pDecimal] NULL,
    [PrintGroup]     NVARCHAR (2)     NULL,
    [NumWarnYn]      BIT              CONSTRAINT [DF_tblCfTransDetail_NumWarnYn] DEFAULT ((0)) NOT NULL,
    [DefaultValue]   NVARCHAR (50)    NULL,
    [Answer]         NVARCHAR (50)    NULL,
    [FieldPriceYn]   BIT              CONSTRAINT [DF_tblCfTransDetail_FieldPriceYn] DEFAULT ((0)) NOT NULL,
    [FieldPrice]     [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetail_FieldPrice] DEFAULT ((0)) NOT NULL,
    [PriceOption]    TINYINT          CONSTRAINT [DF_tblCfTransDetail_PriceOption] DEFAULT ((0)) NOT NULL,
    [Quantity]       [dbo].[pDecimal] NULL,
    [UnitPrice]      [dbo].[pDecimal] NULL,
    [UnitPriceFgn]   [dbo].[pDecimal] NULL,
    [ExtPrice]       [dbo].[pDecimal] NULL,
    [ExtPriceFgn]    [dbo].[pDecimal] NULL,
    [UnitCost]       [dbo].[pDecimal] NULL,
    [UnitCostFgn]    [dbo].[pDecimal] NULL,
    [AdjUnitCost]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetail_AdjUnitCost] DEFAULT ((0)) NOT NULL,
    [AdjUnitCostFgn] [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetail_AdjUnitCostFgn] DEFAULT ((0)) NOT NULL,
    [ExtCost]        [dbo].[pDecimal] NULL,
    [ExtCostFgn]     [dbo].[pDecimal] NULL,
    [RequiredYn]     BIT              CONSTRAINT [DF_tblCfTransDetail_RequiredYn] DEFAULT ((0)) NOT NULL,
    [AddlDescr]      NVARCHAR (MAX)   NULL,
    [SmartIdLen]     INT              NULL,
    [SmartIdValue]   NVARCHAR (24)    NULL,
    [SelectedYn]     BIT              CONSTRAINT [DF_tblCfTransDetail_SelectedYn] DEFAULT ((0)) NOT NULL,
    [Notes]          NVARCHAR (MAX)   NULL,
    [CF]             XML              NULL,
    [ts]             ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfTransDetail] PRIMARY KEY CLUSTERED ([DetailId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransDetail';

