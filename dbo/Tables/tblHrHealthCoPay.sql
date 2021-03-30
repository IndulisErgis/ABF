CREATE TABLE [dbo].[tblHrHealthCoPay] (
    [ID]          BIGINT           NOT NULL,
    [HealthInsID] BIGINT           NOT NULL,
    [Description] NVARCHAR (50)    NOT NULL,
    [Amount]      [dbo].[pDecimal] CONSTRAINT [DF_tblHrHealthCoPay_Amount] DEFAULT ((0)) NOT NULL,
    [CF]          XML              NULL,
    [ts]          ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrHealthCoPay] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrHealthCoPay_HealthInsIDDescription]
    ON [dbo].[tblHrHealthCoPay]([HealthInsID] ASC, [Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrHealthCoPay';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrHealthCoPay';

