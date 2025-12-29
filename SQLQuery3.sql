DECLARE @CustomerID nchar(5) = N'ALFKI' 
DECLARE @Amount money = 1000.00
DECLARE @Date datetime 
         SET @Date = GETDATE()
DECLARE @Resualt nvarchar(200);

EXEC usp_CutomerPayment @CustomerID = @CustomerID , @Amount = @Amount , @PaymentDate = @Date , @Resualt = @Resualt  OUTPUT 

SELECT @Resualt AS PaymentResult;
