CREATE TABLE [dbo].[tblSmExternalPaymentMethod] (
    [ID]             BIGINT          NOT NULL,
    [CustomerID]     [dbo].[pCustID] NOT NULL,
    [Status]         TINYINT         NOT NULL,
    [DefaultYn]      BIT             CONSTRAINT [DF_tblSmExternalPaymentMethod_DefaultYn] DEFAULT ((0)) NOT NULL,
    [EntryDate]      DATETIME        CONSTRAINT [DF_tblSmExternalPaymentMethod_EntryDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedDate]    DATETIME        NULL,
    [CardHolder]     NVARCHAR (30)   NOT NULL,
    [ServiceID]      INT             NOT NULL,
    [Description]    NVARCHAR (255)  NULL,
    [MaskValue]      NVARCHAR (4)    NULL,
    [ExpirationDate] NVARCHAR (6)    NOT NULL,
    [CardID]         NVARCHAR (255)  NOT NULL,
    [Response]       NVARCHAR (MAX)  NULL,
    [CF]             XML             NULL,
    [ts]             ROWVERSION      NULL,
    CONSTRAINT [PK_tblSmExternalPaymentMethod] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmExternalPaymentMethod_CustomerID]
    ON [dbo].[tblSmExternalPaymentMethod]([CustomerID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExternalPaymentMethod';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExternalPaymentMethod';

