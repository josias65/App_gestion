const db = require('../database');

// Modèle pour les articles/produits
class Article {
  static async create(article) {
    const { name, description, price, quantity, category, unit } = article;
    const sql = `
      INSERT INTO articles (name, description, price, quantity, category, unit, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))
    `;
    const params = [name, description, price, quantity, category, unit];
    return db.run(sql, params);
  }

  static async findAll() {
    return db.all('SELECT * FROM articles ORDER BY created_at DESC');
  }

  static async findById(id) {
    return db.get('SELECT * FROM articles WHERE id = ?', [id]);
  }

  static async update(id, article) {
    const { name, description, price, quantity, category, unit } = article;
    const sql = `
      UPDATE articles 
      SET name = ?, description = ?, price = ?, quantity = ?, 
          category = ?, unit = ?, updated_at = datetime('now')
      WHERE id = ?
    `;
    const params = [name, description, price, quantity, category, unit, id];
    return db.run(sql, params);
  }

  static async delete(id) {
    return db.run('DELETE FROM articles WHERE id = ?', [id]);
  }
}

// Modèle pour les commandes
class Order {
  static async create(order) {
    const { customerId, items, total, status } = order;
    const sql = `
      INSERT INTO orders (customer_id, items, total, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))
    `;
    const params = [customerId, JSON.stringify(items), total, status || 'pending'];
    return db.run(sql, params);
  }

  static async findAll() {
    const orders = await db.all(`
      SELECT o.*, c.name as customer_name 
      FROM orders o 
      LEFT JOIN customers c ON o.customer_id = c.id 
      ORDER BY o.created_at DESC
    `);
    return orders.map(order => ({
      ...order,
      items: JSON.parse(order.items)
    }));
  }

  static async findById(id) {
    const order = await db.get('SELECT * FROM orders WHERE id = ?', [id]);
    if (order) {
      order.items = JSON.parse(order.items);
    }
    return order;
  }

  static async updateStatus(id, status) {
    const sql = `
      UPDATE orders 
      SET status = ?, updated_at = datetime('now') 
      WHERE id = ?
    `;
    return db.run(sql, [status, id]);
  }
}

// Modèle pour les factures
class Invoice {
  static async create(invoice) {
    const { orderId, customerId, amount, dueDate, status } = invoice;
    const sql = `
      INSERT INTO invoices (order_id, customer_id, amount, due_date, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, datetime('now'), datetime('now'))
    `;
    const params = [orderId, customerId, amount, dueDate, status || 'unpaid'];
    return db.run(sql, params);
  }

  static async findAll() {
    return db.all(`
      SELECT i.*, c.name as customer_name 
      FROM invoices i 
      LEFT JOIN customers c ON i.customer_id = c.id 
      ORDER BY i.created_at DESC
    `);
  }

  static async findById(id) {
    return db.get('SELECT * FROM invoices WHERE id = ?', [id]);
  }

  static async updateStatus(id, status) {
    const sql = `
      UPDATE invoices 
      SET status = ?, updated_at = datetime('now') 
      WHERE id = ?
    `;
    return db.run(sql, [status, id]);
  }
}

module.exports = {
  Article,
  Order,
  Invoice
};
