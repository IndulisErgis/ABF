CREATE TABLE [dbo].[tblArHistDeposit] (
    [Counter]                        INT                  IDENTITY (1, 1) NOT NULL,
    [PostRun]                        [dbo].[pPostRun]     NOT NULL,
    [TransId]                        [dbo].[pTransID]     NOT NULL,
    [CustId]                         [dbo].[pCustID]      NOT NULL,
    [InvcNum]                        [dbo].[pInvoiceNum]  NOT NULL,
    [CredMemNum]                     [dbo].[pInvoiceNum]  NULL,
    [Amount]                         [dbo].[pDec]         NOT NULL,
    [TermsCode]                      [dbo].[pTermsCode]   NULL,
    [DistCode]                       [dbo].[pDistCode]    NOT NULL,
    [FiscalPeriod]                   SMALLINT             NOT NULL,
    [FiscalYear]                     SMALLINT             NOT NULL,
    [CurrencyId]                     [dbo].[pCurrency]    NOT NULL,
    [Description]                    [dbo].[pDescription] NOT NULL,
    [ExchRate]                       [dbo].[pDec]         NOT NULL,
    [RecType]                        TINYINT              NOT NULL,
    [Note]                           NVARCHAR (MAX)       NULL,
    [GLAcctReceivablesDeposit]       [dbo].[pGlAcct]      NOT NULL,
    [GLAcctReceivablesDepositContra] [dbo].[pGlAcct]      NOT NULL,
    [PostDate]                       DATETIME             NOT NULL,
    [TransDate]                      DATETIME             NOT NULL,
    [Source]                         TINYINT              NOT NULL,
    [SourceId]                       NVARCHAR (255)       NULL,
    [ProjectName]                    NVARCHAR (10)        NULL,
    [ProjectDescription]             NVARCHAR (30)        NULL,
    [PhaseId]                        NVARCHAR (10)        NULL,
    [PhaseDescription]               NVARCHAR (30)        NULL,
    [TaskId]                         NVARCHAR (10)        NULL,
    [TaskDescription]                NVARCHAR (30)        NULL,
    [PrintOption]                    NVARCHAR (255)       NULL,
    [CF]                             XML                  NULL,
    [Rep1Id]                         [dbo].[pSalesRep]    NULL,
    [Rep1Pct]                        [dbo].[pDec]         NULL,
    [Rep1CommRate]                   [dbo].[pDec]         NULL,
    [Rep2Id]                         [dbo].[pSalesRep]    NULL,
    [Rep2Pct]                        [dbo].[pDec]         NULL,
    [Rep2CommRate]                   [dbo].[pDec]         NULL,
    CONSTRAINT [PK_tblArHistDeposit] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistDeposit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistDeposit';

