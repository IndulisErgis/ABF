CREATE TABLE [dbo].[tblSvServiceContractDetail] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [ContractID]     BIGINT       NOT NULL,
    [EquipmentID]    BIGINT       NOT NULL,
    [CoverageType]   TINYINT      DEFAULT ((0)) NOT NULL,
    [ContractAmount] [dbo].[pDec] DEFAULT ((0)) NOT NULL,
    [CF]             XML          NULL,
    [ts]             ROWVERSION   NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvServiceContractDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvServiceContractDetail';

