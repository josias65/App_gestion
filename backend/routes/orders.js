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

// Obtenir toutes les commandes
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 10, status = '', customer_id = '' } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = '';
    let params = [];

    const conditions = [];
    if (status) {
      conditions.push('c.status = ?');
      params.push(status);
    }
    if (customer_id) {
      conditions.push('c.customer_id = ?');
      params.push(customer_id);
    }

    if (conditions.length > 0) {
      whereClause = 'WHERE ' + conditions.join(' AND ');
    }

    const commandes = await db.all(
      `SELECT c.*, cu.name as customer_name, cu.email as customer_email 
       FROM commandes c 
       LEFT JOIN customers cu ON c.customer_id = cu.id 
       ${whereClause} 
       ORDER BY c.created_at DESC 
       LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const totalCount = await db.get(
      `SELECT COUNT(*) as count FROM commandes c ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: commandes,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalCount.count,
        pages: Math.ceil(totalCount.count / limit)
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des commandes:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir une commande par ID avec ses articles
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const commande = await db.get(
      `SELECT c.*, cu.name as customer_name, cu.email as customer_email, cu.phone as customer_phone, cu.address as customer_address
       FROM commandes c 
       LEFT JOIN customers cu ON c.customer_id = cu.id 
       WHERE c.id = ?`,
      [id]
    );

    if (!commande) {
      return res.status(404).json({
        success: false,
        message: 'Commande non trouvée'
      });
    }

    // Récupérer les articles de la commande
    const items = await db.all(
      `SELECT ci.*, a.name as article_name, a.description as article_description
       FROM commande_items ci 
       LEFT JOIN articles a ON ci.article_id = a.id 
       WHERE ci.commande_id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...commande,
        items
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération de la commande:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Créer une nouvelle commande
router.post('/', authenticateToken, [
  body('customer_id').isInt({ min: 1 }),
  body('items').isArray({ min: 1 }),
  body('items.*.article_id').isInt({ min: 1 }),
  body('items.*.quantity').isInt({ min: 1 }),
  body('items.*.price').isFloat({ min: 0 })
], handleValidationErrors, async (req, res) => {
  try {
    const { customer_id, items, notes } = req.body;

    // Vérifier si le client existe
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

    // Calculer le total
    const total = items.reduce((sum, item) => sum + (item.quantity * item.price), 0);

    // Créer la commande
    const commandeResult = await db.run(
      'INSERT INTO commandes (customer_id, total, notes) VALUES (?, ?, ?)',
      [customer_id, total, notes]
    );

    const commandeId = commandeResult.id;

    // Ajouter les articles à la commande
    for (const item of items) {
      await db.run(
        'INSERT INTO commande_items (commande_id, article_id, quantity, price) VALUES (?, ?, ?, ?)',
        [commandeId, item.article_id, item.quantity, item.price]
      );
    }

    // Récupérer la commande complète
    const newCommande = await db.get(
      `SELECT c.*, cu.name as customer_name, cu.email as customer_email
       FROM commandes c 
       LEFT JOIN customers cu ON c.customer_id = cu.id 
       WHERE c.id = ?`,
      [commandeId]
    );

    const commandeItems = await db.all(
      `SELECT ci.*, a.name as article_name, a.description as article_description
       FROM commande_items ci 
       LEFT JOIN articles a ON ci.article_id = a.id 
       WHERE ci.commande_id = ?`,
      [commandeId]
    );

    res.status(201).json({
      success: true,
      message: 'Commande créée avec succès',
      data: {
        ...newCommande,
        items: commandeItems
      }
    });

  } catch (error) {
    console.error('Erreur lors de la création de la commande:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Mettre à jour une commande
router.put('/:id', authenticateToken, [
  body('status').optional().isIn(['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled']),
  body('notes').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    // Vérifier si la commande existe
    const commande = await db.get(
      'SELECT * FROM commandes WHERE id = ?',
      [id]
    );

    if (!commande) {
      return res.status(404).json({
        success: false,
        message: 'Commande non trouvée'
      });
    }

    // Mettre à jour la commande
    await db.run(
      'UPDATE commandes SET status = ?, notes = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [status || commande.status, notes || commande.notes, id]
    );

    const updatedCommande = await db.get(
      `SELECT c.*, cu.name as customer_name, cu.email as customer_email
       FROM commandes c 
       LEFT JOIN customers cu ON c.customer_id = cu.id 
       WHERE c.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Commande mise à jour avec succès',
      data: updatedCommande
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour de la commande:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Supprimer une commande
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier si la commande existe
    const commande = await db.get(
      'SELECT * FROM commandes WHERE id = ?',
      [id]
    );

    if (!commande) {
      return res.status(404).json({
        success: false,
        message: 'Commande non trouvée'
      });
    }

    // Supprimer les articles de la commande
    await db.run('DELETE FROM commande_items WHERE commande_id = ?', [id]);

    // Supprimer la commande
    await db.run('DELETE FROM commandes WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Commande supprimée avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression de la commande:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir les statistiques des commandes
router.get('/stats/overview', authenticateToken, async (req, res) => {
  try {
    const totalCommandes = await db.get('SELECT COUNT(*) as count FROM commandes');
    const commandesThisMonth = await db.get(
      'SELECT COUNT(*) as count FROM commandes WHERE created_at >= date("now", "start of month")'
    );
    const totalRevenue = await db.get('SELECT SUM(total) as total FROM commandes WHERE status != "cancelled"');
    const revenueThisMonth = await db.get(
      'SELECT SUM(total) as total FROM commandes WHERE created_at >= date("now", "start of month") AND status != "cancelled"'
    );

    // Statistiques par statut
    const statusStats = await db.all(
      'SELECT status, COUNT(*) as count FROM commandes GROUP BY status'
    );

    res.json({
      success: true,
      data: {
        total: totalCommandes.count,
        thisMonth: commandesThisMonth.count,
        totalRevenue: totalRevenue.total || 0,
        revenueThisMonth: revenueThisMonth.total || 0,
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
