﻿CREATE TYPE [dbo].[pBankID]
    FROM VARCHAR (10) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pBankID] TO PUBLIC;

