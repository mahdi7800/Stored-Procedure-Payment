📌 Overview

usp_CutomerPayment is a SQL Server stored procedure designed to process customer payments in a transactional and reliable way.
It records a payment for a specific customer and returns an execution result message using an OUTPUT parameter.

This procedure is suitable for financial workflows where data consistency, error handling, and clear execution feedback are critical.

⚙️ Parameters
Name	Type	Direction	Description
@CustomerID	nchar(5)	INPUT	Unique identifier of the customer
@Amount	money	INPUT	Payment amount
@PaymentDate	datetime	INPUT	Date of payment
@Resualt	nvarchar(200)	OUTPUT	Result message of the operation
🔄 Procedure Behavior

Validates the customer existence

Inserts a payment record into the Payments table

Executes inside a controlled transaction

Uses safe execution patterns (SET NOCOUNT ON, SET XACT_ABORT ON)

Returns a descriptive result message through the OUTPUT parameter

🧪 Usage Example
DECLARE @Result nvarchar(200);

EXEC usp_CutomerPayment
     @CustomerID  = N'ALFKI',
     @Amount      = 1000.00,
     @PaymentDate = GETDATE(),
     @Resualt     = @Result OUTPUT;

SELECT @Result AS PaymentResult;

📤 Output

The procedure does not return result sets

Execution feedback is provided via the @Resualt OUTPUT parameter

Example outputs:

Payment successfully recorded

Customer not found

Payment processing failed

🛡️ Notes

Designed for backend and application-level integration

OUTPUT parameter should not be pre-filled

Best used within service or repository layers

Business logic is isolated from presentation logic


Microsoft SQL Server 2016 or later

Existing Customers and Payments tables

Proper foreign key relationship between tables
