CREATE TABLE [dbo].[tblSvBillingType] (
    [BillingType]     NVARCHAR (10)        NOT NULL,
    [Description]     [dbo].[pDescription] NULL,
    [BillableYN]      BIT                  DEFAULT ((1)) NOT NULL,
    [CF]              XML                  NULL,
    [ts]              ROWVERSION           NULL,
    [AutoAddTravel]   BIT                  CONSTRAINT [DF_tblSvBillingType_AutoAddTravel] DEFAULT ((0)) NOT NULL,
    [TravelLaborCode] NVARCHAR (10)        NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvBillingType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvBillingType';

