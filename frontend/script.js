document.addEventListener('DOMContentLoaded', () => {
    fetchProducts();
});

// Функция для получения товаров с бэкенда
async function fetchProducts() {
    try {
        // Пытаемся получить данные с сервера
        const response = await fetch('http://localhost:3000/api/products');
        
        if (!response.ok) {
            throw new Error('Ошибка сети');
        }

        const products = await response.json();
        renderProducts(products);
    } catch (error) {
        console.warn('Бэкенд не запущен или ошибка. Используем тестовые данные.', error);
        renderProducts(getMockProducts());
    }
}
// Функция для отображения товаров на странице
function renderProducts(products) {
    const container = document.getElementById('products-container');
    container.innerHTML = ''; 

    products.forEach(product => {
        const card = document.createElement('div');
        card.className = 'product-card';

        // Если картинки нет в бд
        const imageUrl = product.ImageUrl && product.ImageUrl.trim() !== '' 
            ? product.ImageUrl 
            : 'https://placehold.co/300x300/f8c8dc/2c2c2c?text=Loveli';

        card.innerHTML = `
            <img src="${imageUrl}" alt="${product.Name}" class="product-image" onerror="this.src='https://placehold.co/300x300/f8c8dc/2c2c2c?text=Loveli'">
            <div>
                <h3 class="product-title">${product.Name}</h3>
                <p class="product-brand">${product.Brand || 'Бренд'}</p>
                <p class="product-price">${product.Price} ₽</p>
            </div>
            <button class="add-to-cart-btn" onclick="addToCart(${product.ProductId})">Добавить в корзину</button>
        `;

        container.appendChild(card);
    });
}
// Тестовые данные (если бэкенд выключен)
function getMockProducts() {
    return [
        { ProductId: 1, Name: 'Тушь для ресниц', Brand: 'Lamel', Price: 799, ImageUrl: '' },
        { ProductId: 2, Name: 'Увлажняющий крем', Brand: 'CeraVe', Price: 1299, ImageUrl: '' },
        { ProductId: 3, Name: 'Шампунь для волос', Brand: "L'Oreal", Price: 999, ImageUrl: '' },
        { ProductId: 4, Name: 'Парфюмерная вода', Brand: 'Versace', Price: 5499, ImageUrl: '' }
    ];
}

function addToCart(productId) {
    alert(`Товар с ID ${productId} добавлен в корзину!`);
}

