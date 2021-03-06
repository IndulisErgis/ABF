CREATE TABLE [dbo].[tblApVendorClass] (
    [ClassID] VARCHAR (6)  NOT NULL,
    [Desc]    VARCHAR (25) NULL,
    [ts]      ROWVERSION   NULL,
    [CF]      XML          NULL,
    PRIMARY KEY CLUSTERED ([ClassID] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApVendorClass';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApVendorClass';

