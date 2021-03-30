CREATE TABLE [dbo].[tblSmPeriodConversionDetail] (
    [ID]       INT          IDENTITY (1, 1) NOT NULL,
    [HeaderID] INT          NOT NULL,
    [AppID]    NVARCHAR (2) NOT NULL,
    [ts]       ROWVERSION   NULL,
    CONSTRAINT [PK_tblSmPeriodConversionDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmPeriodConversionDetail]
    ON [dbo].[tblSmPeriodConversionDetail]([HeaderID] ASC, [AppID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmPeriodConversionDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmPeriodConversionDetail';

