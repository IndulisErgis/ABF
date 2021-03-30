CREATE TABLE [dbo].[tblPaEarnCode] (
    [Id]               [dbo].[pCode]   NOT NULL,
    [Description]      NVARCHAR (40)   NULL,
    [IncludeInNet]     BIT             CONSTRAINT [DF_tblPaEarnCode_IncludeInNet] DEFAULT ((1)) NOT NULL,
    [FixedWithholding] BIT             CONSTRAINT [DF_tblPaEarnCode_FixedWithholding] DEFAULT ((0)) NOT NULL,
    [EarningTypeId]    NCHAR (1)       NULL,
    [GLHoldingAccount] [dbo].[pGlAcct] NULL,
    [Multiplier]       [dbo].[pDec]    CONSTRAINT [DF_tblPaEarnCode_Multiplier] DEFAULT ((0)) NOT NULL,
    [AddToBase]        [dbo].[pDec]    CONSTRAINT [DF_tblPaEarnCode_AddToBase] DEFAULT ((0)) NOT NULL,
    [W2Box]            NVARCHAR (3)    NULL,
    [W2Code]           NVARCHAR (8)    NULL,
    [CF]               XML             NULL,
    [ts]               ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaEarnCode] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEarnCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEarnCode';

