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

// Obtenir tous les marchés
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 10, status = '', customer_id = '' } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = '';
    let params = [];

    const conditions = [];
    if (status) {
      conditions.push('m.status = ?');
      params.push(status);
    }
    if (customer_id) {
      conditions.push('m.customer_id = ?');
      params.push(customer_id);
    }

    if (conditions.length > 0) {
      whereClause = 'WHERE ' + conditions.join(' AND ');
    }

    const marches = await db.all(
      `SELECT m.*, c.name as customer_name, c.email as customer_email 
       FROM marches m 
       LEFT JOIN customers c ON m.customer_id = c.id 
       ${whereClause} 
       ORDER BY m.created_at DESC 
       LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const totalCount = await db.get(
      `SELECT COUNT(*) as count FROM marches m ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: marches,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalCount.count,
        pages: Math.ceil(totalCount.count / limit)
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des marchés:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir un marché par ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const marche = await db.get(
      `SELECT m.*, c.name as customer_name, c.email as customer_email, c.phone as customer_phone, c.address as customer_address
       FROM marches m 
       LEFT JOIN customers c ON m.customer_id = c.id 
       WHERE m.id = ?`,
      [id]
    );

    if (!marche) {
      return res.status(404).json({
        success: false,
        message: 'Marché non trouvé'
      });
    }

    res.json({
      success: true,
      data: marche
    });

  } catch (error) {
    console.error('Erreur lors de la récupération du marché:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Créer un nouveau marché
router.post('/', authenticateToken, [
  body('title').isLength({ min: 2 }).trim(),
  body('description').optional().trim(),
  body('customer_id').optional().isInt({ min: 1 }),
  body('amount').optional().isFloat({ min: 0 }),
  body('start_date').optional().isISO8601(),
  body('end_date').optional().isISO8601()
], handleValidationErrors, async (req, res) => {
  try {
    const { title, description, customer_id, amount, start_date, end_date } = req.body;

    // Vérifier si le client existe (si fourni)
    if (customer_id) {
      const customer = await db.get(
        'SELECT * FROM customers WHERE id = ?',
        [customer_id]
      );

      if (!customer) {
        return res.status(404).json({
          success: false,
          message: 'Client non trouvé'
        });
      }
    }

    const result = await db.run(
      'INSERT INTO marches (title, description, customer_id, amount, start_date, end_date) VALUES (?, ?, ?, ?, ?, ?)',
      [title, description, customer_id, amount, start_date, end_date]
    );

    const newMarche = await db.get(
      `SELECT m.*, c.name as customer_name, c.email as customer_email
       FROM marches m 
       LEFT JOIN customers c ON m.customer_id = c.id 
       WHERE m.id = ?`,
      [result.id]
    );

    res.status(201).json({
      success: true,
      message: 'Marché créé avec succès',
      data: newMarche
    });

  } catch (error) {
    console.error('Erreur lors de la création du marché:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Mettre à jour un marché
router.put('/:id', authenticateToken, [
  body('title').optional().isLength({ min: 2 }).trim(),
  body('description').optional().trim(),
  body('customer_id').optional().isInt({ min: 1 }),
  body('amount').optional().isFloat({ min: 0 }),
  body('start_date').optional().isISO8601(),
  body('end_date').optional().isISO8601(),
  body('status').optional().isIn(['active', 'completed', 'cancelled', 'suspended'])
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, customer_id, amount, start_date, end_date, status } = req.body;

    // Vérifier si le marché existe
    const existingMarche = await db.get(
      'SELECT * FROM marches WHERE id = ?',
      [id]
    );

    if (!existingMarche) {
      return res.status(404).json({
        success: false,
        message: 'Marché non trouvé'
      });
    }

    // Vérifier si le client existe (si fourni)
    if (customer_id && customer_id !== existingMarche.customer_id) {
      const customer = await db.get(
        'SELECT * FROM customers WHERE id = ?',
        [customer_id]
      );

      if (!customer) {
        return res.status(404).json({
          success: false,
          message: 'Client non trouvé'
        });
      }
    }

    await db.run(
      'UPDATE marches SET title = ?, description = ?, customer_id = ?, amount = ?, start_date = ?, end_date = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [
        title || existingMarche.title,
        description !== undefined ? description : existingMarche.description,
        customer_id !== undefined ? customer_id : existingMarche.customer_id,
        amount !== undefined ? amount : existingMarche.amount,
        start_date || existingMarche.start_date,
        end_date || existingMarche.end_date,
        status || existingMarche.status,
        id
      ]
    );

    const updatedMarche = await db.get(
      `SELECT m.*, c.name as customer_name, c.email as customer_email
       FROM marches m 
       LEFT JOIN customers c ON m.customer_id = c.id 
       WHERE m.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Marché mis à jour avec succès',
      data: updatedMarche
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour du marché:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Supprimer un marché
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier si le marché existe
    const marche = await db.get(
      'SELECT * FROM marches WHERE id = ?',
      [id]
    );

    if (!marche) {
      return res.status(404).json({
        success: false,
        message: 'Marché non trouvé'
      });
    }

    await db.run('DELETE FROM marches WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Marché supprimé avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression du marché:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir les statistiques des marchés
router.get('/stats/overview', authenticateToken, async (req, res) => {
  try {
    const totalMarches = await db.get('SELECT COUNT(*) as count FROM marches');
    const activeMarches = await db.get('SELECT COUNT(*) as count FROM marches WHERE status = "active"');
    const completedMarches = await db.get('SELECT COUNT(*) as count FROM marches WHERE status = "completed"');
    const totalValue = await db.get('SELECT SUM(amount) as total FROM marches WHERE amount IS NOT NULL');
    const activeValue = await db.get('SELECT SUM(amount) as total FROM marches WHERE status = "active" AND amount IS NOT NULL');

    // Statistiques par statut
    const statusStats = await db.all(
      'SELECT status, COUNT(*) as count, SUM(amount) as total FROM marches GROUP BY status'
    );

    res.json({
      success: true,
      data: {
        total: totalMarches.count,
        active: activeMarches.count,
        completed: completedMarches.count,
        totalValue: totalValue.total || 0,
        activeValue: activeValue.total || 0,
        statusBreakdown: statusStats
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

module.exports = router;
