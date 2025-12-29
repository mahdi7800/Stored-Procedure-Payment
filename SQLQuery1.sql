USE Northwind
GO 

ALTER TABLE Orders 
  ADD PaidAmount money NOT NULL DEFAULT(0)
GO 

ALTER TABLE Customers
  ADD Bestankari money NOT NULL DEFAULT(0)
GO 

CREATE TABLE Payments (PaymentID int IDENTITY(1,1) NOT NULL  PRIMARY Key ,
                       CustomerID nchar(5)  NOT NULL , 
                       Amount money NOT NULL ,
                       PaymentDate datetime NOT NULL ,
                       Resualt nvarchar(200) NOT NULL 
                       )
GO 



