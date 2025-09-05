const express = require('express');
const { body, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const db = require('../database');

const router = express.Router();

// Middleware d'authentification
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token d\'accès requis'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Token invalide'
      });
    }
    req.user = user;
    next();
  });
};

// Middleware pour valider les erreurs
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Données invalides',
      errors: errors.array()
    });
  }
  next();
};

// Obtenir tous les articles
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 10, search = '' } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = '';
    let params = [];

    if (search) {
      whereClause = 'WHERE name LIKE ? OR description LIKE ?';
      params = [`%${search}%`, `%${search}%`];
    }

    const articles = await db.all(
      `SELECT * FROM articles ${whereClause} ORDER BY created_at DESC LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const totalCount = await db.get(
      `SELECT COUNT(*) as count FROM articles ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: articles,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalCount.count,
        pages: Math.ceil(totalCount.count / limit)
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des articles:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir un article par ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const article = await db.get(
      'SELECT * FROM articles WHERE id = ?',
      [id]
    );

    if (!article) {
      return res.status(404).json({
        success: false,
        message: 'Article non trouvé'
      });
    }

    res.json({
      success: true,
      data: article
    });

  } catch (error) {
    console.error('Erreur lors de la récupération de l\'article:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Créer un nouvel article
router.post('/', authenticateToken, [
  body('name').isLength({ min: 2 }).trim(),
  body('price').isFloat({ min: 0 }),
  body('unit').optional().trim(),
  body('stock').optional().isInt({ min: 0 })
], handleValidationErrors, async (req, res) => {
  try {
    const { name, description, price, unit, stock } = req.body;

    const result = await db.run(
      'INSERT INTO articles (name, description, price, unit, stock) VALUES (?, ?, ?, ?, ?)',
      [name, description, price, unit || 'unité', stock || 0]
    );

    const newArticle = await db.get(
      'SELECT * FROM articles WHERE id = ?',
      [result.id]
    );

    res.status(201).json({
      success: true,
      message: 'Article créé avec succès',
      data: newArticle
    });

  } catch (error) {
    console.error('Erreur lors de la création de l\'article:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Mettre à jour un article
router.put('/:id', authenticateToken, [
  body('name').optional().isLength({ min: 2 }).trim(),
  body('price').optional().isFloat({ min: 0 }),
  body('unit').optional().trim(),
  body('stock').optional().isInt({ min: 0 })
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, unit, stock } = req.body;

    // Vérifier si l'article existe
    const existingArticle = await db.get(
      'SELECT * FROM articles WHERE id = ?',
      [id]
    );

    if (!existingArticle) {
      return res.status(404).json({
        success: false,
        message: 'Article non trouvé'
      });
    }

    await db.run(
      'UPDATE articles SET name = ?, description = ?, price = ?, unit = ?, stock = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [
        name || existingArticle.name,
        description !== undefined ? description : existingArticle.description,
        price !== undefined ? price : existingArticle.price,
        unit || existingArticle.unit,
        stock !== undefined ? stock : existingArticle.stock,
        id
      ]
    );

    const updatedArticle = await db.get(
      'SELECT * FROM articles WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Article mis à jour avec succès',
      data: updatedArticle
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'article:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Supprimer un article
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier si l'article existe
    const article = await db.get(
      'SELECT * FROM articles WHERE id = ?',
      [id]
    );

    if (!article) {
      return res.status(404).json({
        success: false,
        message: 'Article non trouvé'
      });
    }

    // Vérifier s'il y a des commandes associées
    const ordersCount = await db.get(
      'SELECT COUNT(*) as count FROM commande_items WHERE article_id = ?',
      [id]
    );

    if (ordersCount.count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Impossible de supprimer cet article car il est utilisé dans des commandes'
      });
    }

    await db.run('DELETE FROM articles WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Article supprimé avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression de l\'article:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Mettre à jour le stock d'un article
router.patch('/:id/stock', authenticateToken, [
  body('stock').isInt({ min: 0 })
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { stock } = req.body;

    // Vérifier si l'article existe
    const article = await db.get(
      'SELECT * FROM articles WHERE id = ?',
      [id]
    );

    if (!article) {
      return res.status(404).json({
        success: false,
        message: 'Article non trouvé'
      });
    }

    await db.run(
      'UPDATE articles SET stock = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [stock, id]
    );

    const updatedArticle = await db.get(
      'SELECT * FROM articles WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Stock mis à jour avec succès',
      data: updatedArticle
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour du stock:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir les articles avec stock faible
router.get('/low-stock/items', authenticateToken, async (req, res) => {
  try {
    const { threshold = 10 } = req.query;

    const lowStockItems = await db.all(
      'SELECT * FROM articles WHERE stock <= ? ORDER BY stock ASC',
      [parseInt(threshold)]
    );

    res.json({
      success: true,
      data: lowStockItems
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des articles en rupture:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

module.exports = router;
