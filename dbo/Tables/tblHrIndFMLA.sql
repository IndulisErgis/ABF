CREATE TABLE [dbo].[tblHrIndFMLA] (
    [ID]                       BIGINT           NOT NULL,
    [IndId]                    [dbo].[pEmpID]   NOT NULL,
    [NotifyDate]               DATETIME         NOT NULL,
    [ERResponseDate]           DATETIME         NULL,
    [DesigNoticeDate]          DATETIME         NULL,
    [LeaveBegDate]             DATETIME         NULL,
    [ExpReturnDate]            DATETIME         NULL,
    [LeaveReasonTypeCodeID]    BIGINT           NULL,
    [LeaveTypeCodeID]          BIGINT           NULL,
    [LocationTypeCodeID]       BIGINT           NULL,
    [MedCertDueDate]           DATETIME         NULL,
    [MedCertRecDate]           DATETIME         NULL,
    [MedReCertDate]            DATETIME         NULL,
    [ExpDate]                  DATETIME         NULL,
    [Intermittent]             BIT              CONSTRAINT [DF_tblHrIndFMLA_Intermittent] DEFAULT ((0)) NOT NULL,
    [MedCertReq]               BIT              CONSTRAINT [DF_tblHrIndFMLA_MedCertReq] DEFAULT ((0)) NOT NULL,
    [WorkRelated]              BIT              CONSTRAINT [DF_tblHrIndFMLA_WorkRelated] DEFAULT ((0)) NOT NULL,
    [FMLAStatusTypeCodeID]     BIGINT           NULL,
    [DeliveryMethodTypeCodeID] BIGINT           NULL,
    [DeliveryCmnt]             NVARCHAR (50)    NULL,
    [FMLANote]                 NVARCHAR (MAX)   NULL,
    [FMLAHrsPerWeek]           [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndFMLA_FMLAHrsPerWeek] DEFAULT ((0)) NOT NULL,
    [CF]                       XML              NULL,
    [ts]                       ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndFMLA] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndFMLA_IndId]
    ON [dbo].[tblHrIndFMLA]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndFMLA';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndFMLA';

