﻿CREATE TYPE [dbo].[pCheckNum]
    FROM VARCHAR (10) NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pCheckNum] TO PUBLIC;

