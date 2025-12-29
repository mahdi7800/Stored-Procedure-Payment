USE Northwind
GO 

/* 
   Stored Procedure برای پخش کردن مبلغ پرداختی مشتری
   روی سفارش‌های تسویه‌نشده به ترتیب OrderID
*/

CREATE OR ALTER PROC usp_CutomerPayment @CustomerID nchar(5) , @Amount money , @PaymentDate datetime , @Resualt nvarchar(200) OUTPUT 
AS
BEGIN 
SET NOCOUNT ON;
SET XACT_ABORT ON;
  BEGIN TRY 
    BEGIN TRAN 
          DECLARE Ords CURSOR 
 FOR SELECT O.OrderID , CONVERT(money , SUM(OD.Quantity * OD.UnitPrice * (1 - OD.Discount )) ) AS OrderPrice , O.PaidAmount
     FROM Orders AS O INNER JOIN Customers AS C ON O.CustomerID = C.CustomerID
                      INNER JOIN [Order Details] AS OD ON OD.OrderID = O.OrderID
     WHERE C.CustomerID = @CustomerID
     GROUP BY O.OrderID , O.PaidAmount
     HAVING O.PaidAmount < CONVERT(money , SUM(OD.Quantity * OD.UnitPrice * (1 - OD.Discount )) )
     ORDER BY O.OrderID ASC 
     
 FOR READ ONLY

OPEN Ords

DECLARE @OrderID int , @OrderPrice money ,  @PaidAmount  money

DECLARE @Bestankari money  /* بستانکاری فعلی مشتری */ 
        SELECT @Bestankari = Bestankari FROM Customers WHERE CustomerID = @CustomerID

DECLARE @TotalAamount money    /* مجموع مبلغ قابل مصرف (پرداخت جدید + بستانکاری قبلی) */
        SET @TotalAamount = @Amount + @Bestankari
DECLARE @Mandeh money   /* مانده قابل پرداخت هر سفارش */



FETCH NEXT FROM Ords INTO  @OrderID , @OrderPrice , @PaidAmount
WHILE @@FETCH_STATUS <> -1 AND @TotalAamount > 0 
 BEGIN 
      SET @Mandeh = @OrderPrice - @PaidAmount /* مانده سفارش */

      IF @Mandeh <= @TotalAamount  /* اگر کل مانده سفارش قابل پرداخت باشد */
        BEGIN 
             UPDATE Orders
               SET PaidAmount = PaidAmount + @Mandeh
               WHERE OrderID = @OrderID
            SET @TotalAamount = @TotalAamount - @Mandeh
        END
      ELSE                 /* پرداخت جزئی */
        BEGIN 
               UPDATE Orders
               SET PaidAmount = PaidAmount + @TotalAamount
               WHERE OrderID = @OrderID

            SET @TotalAamount = 0
         IF @TotalAamount = 0   /* وقتی پول تمام شد، حلقه متوقف شود */
          BREAK; 
        END 

 FETCH NEXT FROM Ords INTO  @OrderID , @OrderPrice , @PaidAmount
 END 

 IF @@FETCH_STATUS = -1 /* تعیین پیام خروجی */ 
  BEGIN 
     IF @TotalAamount > 0 
         SET @Resualt = N'همه سفارشات تسویه شدند و مشتری بستانکار گردید'
     ELSE 
         SET @Resualt = N'همه سفارشات تسویه گردید'
  END 
 ELSE 
  BEGIN
    SET  @Resualt = N'همه سفارشات تسویه نشد '
   END  


CLOSE Ords
DEALLOCATE Ords

/* 
ذخیره بستانکاری جدید مشتری
(در واقع باقیمانده پولی که بعد از تسویه سفارش‌ها مانده)
*/

UPDATE Customers
  SET BestanKari = @Bestankari
  WHERE CustomerID = @CustomerID

  /* ثبت پرداخت در جدول Payments */

INSERT INTO Payments (CustomerID  , Amount  ,PaymentDate  , Resualt)
   VALUES (@CustomerID , @Amount , @PaymentDate , @Resualt)

    COMMIT TRAN ;
  END TRY 
  BEGIN CATCH
   ROLLBACK;  
     DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
     DECLARE @ErrorSeverity int = ERROR_SEVERITY();
     DECLARE @ErrorState int  =  ERROR_STATE();
     RAISERROR (@ErrorMessage , @ErrorSeverity , @ErrorState)
  END CATCH
END
GO 


DECLARE @CustomerID nchar(5) = N'ALFKI' 
DECLARE @Amount money = 1000.00
DECLARE @PaymentDate datetime = GETDATE()
DECLARE @Resualt nvarchar(200)

