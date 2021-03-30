CREATE TABLE [dbo].[tblCfConfigHeader] (
    [ConfigId]           BIGINT               NOT NULL,
    [ConfigDesc]         NVARCHAR (50)        NOT NULL,
    [ConfigType]         TINYINT              CONSTRAINT [DF_tblCfConfigHeader_ConfigType] DEFAULT ((0)) NOT NULL,
    [ConfigCategory]     NVARCHAR (10)        NULL,
    [BaseItemId]         [dbo].[pItemID]      NULL,
    [CustId]             [dbo].[pCustID]      NULL,
    [ActiveFrom]         DATETIME             NULL,
    [ActiveThru]         DATETIME             NULL,
    [ConfigItemDescType] INT                  CONSTRAINT [DF_tblCfConfigHeader_ConfigItemDescType] DEFAULT ((0)) NOT NULL,
    [ConfigItemDesc]     [dbo].[pDescription] NULL,
    [PartNumberType]     TINYINT              CONSTRAINT [DF_tblCfConfigHeader_PartNumberType] DEFAULT ((0)) NOT NULL,
    [CustomOutput]       NVARCHAR (255)       NULL,
    [PriceOption]        TINYINT              CONSTRAINT [DF_tblCfConfigHeader_PriceOption] DEFAULT ((0)) NOT NULL,
    [ConfigPriceFrom]    TINYINT              CONSTRAINT [DF_tblCfConfigHeader_ConfigPriceFrom] DEFAULT ((0)) NOT NULL,
    [DefaultPrice]       [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigHeader_DefaultPrice] DEFAULT ((0)) NOT NULL,
    [PictureId]          NVARCHAR (50)        NULL,
    [ApproveYN]          BIT                  CONSTRAINT [DF_tblCfConfigHeader_ApproveYN] DEFAULT ((0)) NOT NULL,
    [LastValidate]       DATETIME             NULL,
    [ValidateOK]         BIT                  CONSTRAINT [DF_tblCfConfigHeader_ValidateOK] DEFAULT ((0)) NOT NULL,
    [CF]                 XML                  NULL,
    [ts]                 ROWVERSION           NULL,
    [AllowConstraint]    BIT                  CONSTRAINT [DF_tblCfConfigHeader_AllowConstraint] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblCfConfigHeader] PRIMARY KEY CLUSTERED ([ConfigId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigHeader';

