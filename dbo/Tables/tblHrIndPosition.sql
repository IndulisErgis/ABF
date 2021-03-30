CREATE TABLE [dbo].[tblHrIndPosition] (
    [ID]                     BIGINT         NOT NULL,
    [IndId]                  [dbo].[pEmpID] NOT NULL,
    [PositionID]             BIGINT         NOT NULL,
    [ChangeReasonTypeCodeID] BIGINT         NOT NULL,
    [PrimaryPosition]        BIT            CONSTRAINT [DF_tblHrIndPosition_PrimaryPosition] DEFAULT ((0)) NOT NULL,
    [StartDate]              DATETIME       NOT NULL,
    [EndDate]                DATETIME       NULL,
    [CF]                     XML            NULL,
    [ts]                     ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndPosition] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndPosition_IndId]
    ON [dbo].[tblHrIndPosition]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndPosition';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndPosition';

