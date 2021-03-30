CREATE TYPE [dbo].[pInvoiceNum]
    FROM VARCHAR (15) NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pInvoiceNum] TO PUBLIC;

