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

// Obtenir toutes les factures
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 10, status = '', customer_id = '' } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = '';
    let params = [];

    const conditions = [];
    if (status) {
      conditions.push('f.status = ?');
      params.push(status);
    }
    if (customer_id) {
      conditions.push('f.customer_id = ?');
      params.push(customer_id);
    }

    if (conditions.length > 0) {
      whereClause = 'WHERE ' + conditions.join(' AND ');
    }

    const factures = await db.all(
      `SELECT f.*, c.name as customer_name, c.email as customer_email 
       FROM factures f 
       LEFT JOIN customers c ON f.customer_id = c.id 
       ${whereClause} 
       ORDER BY f.created_at DESC 
       LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const totalCount = await db.get(
      `SELECT COUNT(*) as count FROM factures f ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: factures,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalCount.count,
        pages: Math.ceil(totalCount.count / limit)
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des factures:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir une facture par ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const facture = await db.get(
      `SELECT f.*, c.name as customer_name, c.email as customer_email, c.phone as customer_phone, c.address as customer_address
       FROM factures f 
       LEFT JOIN customers c ON f.customer_id = c.id 
       WHERE f.id = ?`,
      [id]
    );

    if (!facture) {
      return res.status(404).json({
        success: false,
        message: 'Facture non trouvée'
      });
    }

    res.json({
      success: true,
      data: facture
    });

  } catch (error) {
    console.error('Erreur lors de la récupération de la facture:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Créer une nouvelle facture
router.post('/', authenticateToken, [
  body('customer_id').isInt({ min: 1 }),
  body('total').isFloat({ min: 0 }),
  body('due_date').optional().isISO8601()
], handleValidationErrors, async (req, res) => {
  try {
    const { customer_id, commande_id, total, due_date } = req.body;

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

    // Vérifier si la commande existe (si fournie)
    if (commande_id) {
      const commande = await db.get(
        'SELECT * FROM commandes WHERE id = ?',
        [commande_id]
      );

      if (!commande) {
        return res.status(404).json({
          success: false,
          message: 'Commande non trouvée'
        });
      }
    }

    const result = await db.run(
      'INSERT INTO factures (customer_id, commande_id, total, due_date) VALUES (?, ?, ?, ?)',
      [customer_id, commande_id, total, due_date]
    );

    const newFacture = await db.get(
      `SELECT f.*, c.name as customer_name, c.email as customer_email
       FROM factures f 
       LEFT JOIN customers c ON f.customer_id = c.id 
       WHERE f.id = ?`,
      [result.id]
    );

    res.status(201).json({
      success: true,
      message: 'Facture créée avec succès',
      data: newFacture
    });

  } catch (error) {
    console.error('Erreur lors de la création de la facture:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Mettre à jour une facture
router.put('/:id', authenticateToken, [
  body('status').optional().isIn(['pending', 'paid', 'overdue', 'cancelled']),
  body('due_date').optional().isISO8601(),
  body('paid_date').optional().isISO8601()
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, due_date, paid_date } = req.body;

    // Vérifier si la facture existe
    const facture = await db.get(
      'SELECT * FROM factures WHERE id = ?',
      [id]
    );

    if (!facture) {
      return res.status(404).json({
        success: false,
        message: 'Facture non trouvée'
      });
    }

    await db.run(
      'UPDATE factures SET status = ?, due_date = ?, paid_date = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [
        status || facture.status,
        due_date || facture.due_date,
        paid_date || facture.paid_date,
        id
      ]
    );

    const updatedFacture = await db.get(
      `SELECT f.*, c.name as customer_name, c.email as customer_email
       FROM factures f 
       LEFT JOIN customers c ON f.customer_id = c.id 
       WHERE f.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Facture mise à jour avec succès',
      data: updatedFacture
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour de la facture:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Supprimer une facture
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier si la facture existe
    const facture = await db.get(
      'SELECT * FROM factures WHERE id = ?',
      [id]
    );

    if (!facture) {
      return res.status(404).json({
        success: false,
        message: 'Facture non trouvée'
      });
    }

    // Vérifier s'il y a des recouvrements associés
    const recouvrementsCount = await db.get(
      'SELECT COUNT(*) as count FROM recouvrements WHERE facture_id = ?',
      [id]
    );

    if (recouvrementsCount.count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Impossible de supprimer cette facture car elle a des recouvrements associés'
      });
    }

    await db.run('DELETE FROM factures WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Facture supprimée avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression de la facture:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Marquer une facture comme payée
router.patch('/:id/pay', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const facture = await db.get(
      'SELECT * FROM factures WHERE id = ?',
      [id]
    );

    if (!facture) {
      return res.status(404).json({
        success: false,
        message: 'Facture non trouvée'
      });
    }

    await db.run(
      'UPDATE factures SET status = "paid", paid_date = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [id]
    );

    const updatedFacture = await db.get(
      `SELECT f.*, c.name as customer_name, c.email as customer_email
       FROM factures f 
       LEFT JOIN customers c ON f.customer_id = c.id 
       WHERE f.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Facture marquée comme payée',
      data: updatedFacture
    });

  } catch (error) {
    console.error('Erreur lors du paiement de la facture:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir les statistiques des factures
router.get('/stats/overview', authenticateToken, async (req, res) => {
  try {
    const totalFactures = await db.get('SELECT COUNT(*) as count FROM factures');
    const facturesThisMonth = await db.get(
      'SELECT COUNT(*) as count FROM factures WHERE created_at >= date("now", "start of month")'
    );
    const totalRevenue = await db.get('SELECT SUM(total) as total FROM factures WHERE status = "paid"');
    const pendingAmount = await db.get('SELECT SUM(total) as total FROM factures WHERE status = "pending"');
    const overdueAmount = await db.get('SELECT SUM(total) as total FROM factures WHERE status = "overdue"');

    // Statistiques par statut
    const statusStats = await db.all(
      'SELECT status, COUNT(*) as count, SUM(total) as total FROM factures GROUP BY status'
    );

    res.json({
      success: true,
      data: {
        total: totalFactures.count,
        thisMonth: facturesThisMonth.count,
        totalRevenue: totalRevenue.total || 0,
        pendingAmount: pendingAmount.total || 0,
        overdueAmount: overdueAmount.total || 0,
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
