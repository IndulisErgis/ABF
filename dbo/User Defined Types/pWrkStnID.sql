﻿CREATE TYPE [dbo].[pWrkStnID]
    FROM VARCHAR (20) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pWrkStnID] TO PUBLIC;
