CREATE TABLE [dbo].[tblEpHCEmployeeMonth] (
    [ID]       BIGINT           NOT NULL,
    [HeaderId] BIGINT           NOT NULL,
    [PaMonth]  TINYINT          NOT NULL,
    [CodeType] TINYINT          NOT NULL,
    [Code]     NVARCHAR (10)    NULL,
    [Premium]  [dbo].[pDecimal] CONSTRAINT [DF_tblEpHCEmployeeMonth_Premium] DEFAULT ((0)) NOT NULL,
    [CF]       XML              NULL,
    [ts]       ROWVERSION       NULL,
    CONSTRAINT [PK_tblEpHCEmployeeMonth] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblEpHCEmployeeMonth_HeaderIdCodeTypePaMonth]
    ON [dbo].[tblEpHCEmployeeMonth]([HeaderId] ASC, [CodeType] ASC, [PaMonth] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployeeMonth';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployeeMonth';

