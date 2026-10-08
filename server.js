require('dotenv').config();

const express = require('express');
const cors = require('cors');
const sql = require('mssql');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const dbConfig = {
    user: process.env.DB_USER || 'sa',
    password: process.env.DB_PASSWORD || 'ТвойПарольОтБазы',
    server: process.env.DB_SERVER || 'localhost',
    database: process.env.DB_DATABASE || 'LoveliDB',
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

let pool;

async function connectDatabase() {
    pool = await sql.connect(dbConfig);
    console.log('База данных Loveli подключена');
}
 app.get("/", (req, res) => { 
    res.json({
        message: "Backend Loveli работает",
        status: "OK"
   });
 });
const path = require("path");

app.use(express.static(path.join(__dirname, "frontend")));

app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname, "frontend", "index.html"));
});

app.get('/api/products', async (req, res) => {
    try {
        const result = await pool.request().query(`
            SELECT
                p.ID_Product,
                p.Name,
                p.Description,
                p.Price,
                p.ImageUrl,
                p.Characteristics,
                p.StockQuantity,
                c.Name AS Category,
                b.Name AS Brand
            FROM Products p
            INNER JOIN Categories c ON p.ID_Category = c.ID_Category
            INNER JOIN Brands b ON p.ID_Brand = b.ID_Brand
            ORDER BY p.ID_Product
        `);

        res.json(result.recordset);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Не удалось получить товары' });
    }
});
        
app.get('/api/categories', async (req, res) => {
    try {
        const result = await pool.request().query(`
            SELECT ID_Category, Name
            FROM Categories
            ORDER BY Name
        `);

        res.json(result.recordset);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Не удалось получить категории' });
    }
});

app.get('/api/brands', async (req, res) => {
    try {
        const result = await pool.request().query(`
            SELECT ID_Brand, Name
            FROM Brands
            ORDER BY Name
        `);

        res.json(result.recordset);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Не удалось получить бренды' });
    }
});
connectDatabase()
    .then(() => {
        app.listen(PORT, () => {
            console.log(`Loveli backend запущен: http://localhost:${PORT}`);
        });
    })
    .catch((error) => {
        console.error('Ошибка подключения к БД:', error);
        process.exit(1);
    });