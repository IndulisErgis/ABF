CREATE TABLE [dbo].[ALP_tblIMPItem] (
    [ImportItemId]            INT             IDENTITY (1, 1) NOT NULL,
    [ImportMainId]            INT             NULL,
    [QuoteItemsID]            NUMERIC (18)    NULL,
    [QuoteItemLocationID]     NUMERIC (18)    NULL,
    [ItemType]                INT             NULL,
    [Source_Id]               VARCHAR (20)    NULL,
    [ItemId]                  [dbo].[pItemID] NULL,
    [Descr]                   VARCHAR (MAX)   NULL,
    [Quantity]                [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_Qty] DEFAULT ((0)) NOT NULL,
    [Uom]                     [dbo].[pUom]    NULL,
    [UnitPrice]               [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_UnitPrice] DEFAULT ((0)) NULL,
    [KittedYN]                SMALLINT        NULL,
    [AlpDfltHoursAdjusted]    [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_AlpDfltHoursAdjusted] DEFAULT ((0)) NULL,
    [AlpDfltPointsAdjusted]   [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_AlpDfltPointsAdjusted] DEFAULT ((0)) NULL,
    [Comment]                 TEXT            NULL,
    [MFGDiscount]             [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_MFGDiscount] DEFAULT ((0)) NULL,
    [RetailYN]                BIT             NULL,
    [WireCalcLaborAdj]        [dbo].[pDec]    NULL,
    [ConvFactor]              [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_ConvFactor] DEFAULT ((0)) NULL,
    [ValidatedInvItemYn]      BIT             NULL,
    [VendorQuoteNum]          VARCHAR (50)    NULL,
    [Vendor]                  VARCHAR (50)    NULL,
    [MFG]                     VARCHAR (50)    NULL,
    [UnitCost]                [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_UnitCost] DEFAULT ((0)) NULL,
    [Location]                VARCHAR (50)    NULL,
    [Lvl]                     INT             NULL,
    [KitID]                   INT             NULL,
    [KitReference]            INT             NULL,
    [KitNestLevel]            INT             NULL,
    [KitLineNumber]           VARCHAR (50)    NULL,
    [DiscountedUnitCost]      [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_DiscountedUnitCost] DEFAULT ((0)) NULL,
    [Labor]                   [dbo].[pDec]    CONSTRAINT [DF_Alp_tblIMPItem_Labor] DEFAULT ((0)) NULL,
    [AlpVendorKitYn]          BIT             NULL,
    [AlpVendorKitComponentYn] BIT             NULL,
    [IsImported]              INT             NULL,
    [TicketId]                INT             NULL,
    [ModifiedBy]              VARCHAR (50)    NULL,
    [ModifiedDate]            DATETIME        CONSTRAINT [DF_Alp_tblIMPItem_ModifiedDate] DEFAULT (getdate()) NULL,
    [KitLocationRef]          VARCHAR (50)    NULL,
    [PartsOnlyYn]             BIT             NULL,
    [AlpPhaseCodeID]          INT             NULL,
    CONSTRAINT [PK_Alp_tblIMPINItem] PRIMARY KEY CLUSTERED ([ImportItemId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ALP_tblIMPItem_IsImported>]
    ON [dbo].[ALP_tblIMPItem]([ImportMainId] ASC)
    INCLUDE([IsImported]);

