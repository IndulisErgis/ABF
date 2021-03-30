CREATE TABLE [dbo].[tblPaCheckInfo] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [PaYear]        SMALLINT        NOT NULL,
    [GlPeriod]      SMALLINT        NOT NULL,
    [GlYear]        SMALLINT        NOT NULL,
    [PeriodEndDate] DATETIME        NULL,
    [DateOnCheck]   DATETIME        NULL,
    [PrintedYn]     BIT             CONSTRAINT [DF_tblPaCheckInfo_PrintedYn] DEFAULT ((0)) NOT NULL,
    [BankId]        [dbo].[pBankID] NULL,
    [CF]            XML             NULL,
    [ts]            ROWVERSION      NULL,
    [ExtendedInfo]  XML             NULL,
    CONSTRAINT [PK_tblPaCheckInfo] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckInfo';

