IF DB_ID(N'LoveliDB') IS NULL
BEGIN
    CREATE DATABASE LoveliDB;
END
GO

USE LoveliDB;
GO

IF OBJECT_ID(N'dbo.Reviews', N'U') IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.CartItems', N'U') IS NOT NULL DROP TABLE dbo.CartItems;
IF OBJECT_ID(N'dbo.Carts', N'U') IS NOT NULL DROP TABLE dbo.Carts;
IF OBJECT_ID(N'dbo.Favorites', N'U') IS NOT NULL DROP TABLE dbo.Favorites;
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID(N'dbo.Brands', N'U') IS NOT NULL DROP TABLE dbo.Brands;
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users
(
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL DEFAULT N'User',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Users_Role CHECK (Role IN (N'User', N'Admin'))
);
GO

CREATE TABLE dbo.Categories
(
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.Brands
(
    BrandId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.Products
(
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId INT NOT NULL,
    BrandId INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Price DECIMAL(10,2) NOT NULL,
    ImageUrl NVARCHAR(500) NULL,
    Characteristics NVARCHAR(MAX) NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),

    CONSTRAINT FK_Products_Brands
        FOREIGN KEY (BrandId) REFERENCES dbo.Brands(BrandId),

    CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    CONSTRAINT CK_Products_Stock CHECK (StockQuantity >= 0)
);
GO

CREATE TABLE dbo.Favorites
(
    FavoriteId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    ProductId INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Favorites_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),

    CONSTRAINT FK_Favorites_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),

    CONSTRAINT UQ_Favorites_User_Product UNIQUE (UserId, ProductId)
);
GO

CREATE TABLE dbo.Carts
(
    CartId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL UNIQUE,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Carts_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

CREATE TABLE dbo.CartItems
(
    CartItemId INT IDENTITY(1,1) PRIMARY KEY,
    CartId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_CartItems_Carts
        FOREIGN KEY (CartId) REFERENCES dbo.Carts(CartId),

    CONSTRAINT FK_CartItems_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),

    CONSTRAINT UQ_CartItems_Cart_Product UNIQUE (CartId, ProductId),
    CONSTRAINT CK_CartItems_Quantity CHECK (Quantity > 0)
);
GO

CREATE TABLE dbo.Orders
(
    OrderId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    DeliveryAddress NVARCHAR(500) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT N'Новый',
    TotalAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Orders_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),

    CONSTRAINT CK_Orders_Total CHECK (TotalAmount >= 0)
);
GO

CREATE TABLE dbo.OrderItems
(
    OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),

    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_Price CHECK (Price >= 0)
);
GO

CREATE TABLE dbo.Reviews
(
    ReviewId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    ProductId INT NOT NULL,
    Rating INT NOT NULL,
    Comment NVARCHAR(1000) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Reviews_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),

    CONSTRAINT FK_Reviews_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),

    CONSTRAINT UQ_Reviews_User_Product UNIQUE (UserId, ProductId),
    CONSTRAINT CK_Reviews_Rating CHECK (Rating BETWEEN 1 AND 5)
);
GO

INSERT INTO dbo.Categories (Name)
VALUES
(N'Макияж'),
(N'Уход'),
(N'Волосы'),
(N'Ароматы');
GO

INSERT INTO dbo.Brands (Name)
VALUES
(N'Lamel'),
(N'CeraVe'),
(N'L''Oreal'),
(N'Versace');
GO

INSERT INTO dbo.Products
    (CategoryId, BrandId, Name, Description, Price, ImageUrl, Characteristics, StockQuantity)
VALUES
(
    1, 1,
    N'Тушь для ресниц',
    N'Тушь для ежедневного макияжа.',
    799.00,
    N'/images/mascara.jpg',
    N'Объём; чёрный цвет',
    20
),
(
    2, 2,
    N'Увлажняющий крем',
    N'Увлажняющий крем для лица.',
    1299.00,
    N'/images/cream.jpg',
    N'Для нормальной и сухой кожи',
    15
),
(
    3, 3,
    N'Шампунь для волос',
    N'Шампунь для ежедневного ухода.',
    999.00,
    N'/images/shampoo.jpg',
    N'250 мл',
    25
),
(
    4, 4,
    N'Парфюмерная вода',
    N'Женский аромат.',
    5499.00,
    N'/images/perfume.jpg',
    N'50 мл',
    8
);
GO

SELECT * FROM dbo.Users;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Brands;
SELECT * FROM dbo.Products;
SELECT * FROM dbo.Favorites;
SELECT * FROM dbo.Carts;
SELECT * FROM dbo.CartItems;
SELECT * FROM dbo.Orders;
SELECT * FROM dbo.OrderItems;
SELECT * FROM dbo.Reviews;
GO
