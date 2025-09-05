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

// Obtenir tous les clients
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 10, search = '' } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = '';
    let params = [];

    if (search) {
      whereClause = 'WHERE name LIKE ? OR email LIKE ? OR company LIKE ?';
      params = [`%${search}%`, `%${search}%`, `%${search}%`];
    }

    const clients = await db.all(
      `SELECT * FROM customers ${whereClause} ORDER BY created_at DESC LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const totalCount = await db.get(
      `SELECT COUNT(*) as count FROM customers ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: clients,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalCount.count,
        pages: Math.ceil(totalCount.count / limit)
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des clients:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir un client par ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const client = await db.get(
      'SELECT * FROM customers WHERE id = ?',
      [id]
    );

    if (!client) {
      return res.status(404).json({
        success: false,
        message: 'Client non trouvé'
      });
    }

    res.json({
      success: true,
      data: client
    });

  } catch (error) {
    console.error('Erreur lors de la récupération du client:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Créer un nouveau client
router.post('/', authenticateToken, [
  body('name').isLength({ min: 2 }).trim(),
  body('email').optional().isEmail().normalizeEmail(),
  body('phone').optional().isLength({ min: 8 }),
  body('company').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { name, email, phone, address, company } = req.body;

    // Vérifier si un client avec cet email existe déjà
    if (email) {
      const existingClient = await db.get(
        'SELECT id FROM customers WHERE email = ?',
        [email]
      );

      if (existingClient) {
        return res.status(400).json({
          success: false,
          message: 'Un client avec cet email existe déjà'
        });
      }
    }

    const result = await db.run(
      'INSERT INTO customers (name, email, phone, address, company) VALUES (?, ?, ?, ?, ?)',
      [name, email, phone, address, company]
    );

    const newClient = await db.get(
      'SELECT * FROM customers WHERE id = ?',
      [result.id]
    );

    res.status(201).json({
      success: true,
      message: 'Client créé avec succès',
      data: newClient
    });

  } catch (error) {
    console.error('Erreur lors de la création du client:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Mettre à jour un client
router.put('/:id', authenticateToken, [
  body('name').optional().isLength({ min: 2 }).trim(),
  body('email').optional().isEmail().normalizeEmail(),
  body('phone').optional().isLength({ min: 8 }),
  body('company').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, phone, address, company } = req.body;

    // Vérifier si le client existe
    const existingClient = await db.get(
      'SELECT * FROM customers WHERE id = ?',
      [id]
    );

    if (!existingClient) {
      return res.status(404).json({
        success: false,
        message: 'Client non trouvé'
      });
    }

    // Vérifier si l'email est déjà utilisé par un autre client
    if (email && email !== existingClient.email) {
      const emailExists = await db.get(
        'SELECT id FROM customers WHERE email = ? AND id != ?',
        [email, id]
      );

      if (emailExists) {
        return res.status(400).json({
          success: false,
          message: 'Un client avec cet email existe déjà'
        });
      }
    }

    await db.run(
      'UPDATE customers SET name = ?, email = ?, phone = ?, address = ?, company = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [name || existingClient.name, email || existingClient.email, phone || existingClient.phone, address || existingClient.address, company || existingClient.company, id]
    );

    const updatedClient = await db.get(
      'SELECT * FROM customers WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Client mis à jour avec succès',
      data: updatedClient
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour du client:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Supprimer un client
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier si le client existe
    const client = await db.get(
      'SELECT * FROM customers WHERE id = ?',
      [id]
    );

    if (!client) {
      return res.status(404).json({
        success: false,
        message: 'Client non trouvé'
      });
    }

    // Vérifier s'il y a des commandes associées
    const ordersCount = await db.get(
      'SELECT COUNT(*) as count FROM commandes WHERE customer_id = ?',
      [id]
    );

    if (ordersCount.count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Impossible de supprimer ce client car il a des commandes associées'
      });
    }

    await db.run('DELETE FROM customers WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Client supprimé avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression du client:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir les statistiques des clients
router.get('/stats/overview', authenticateToken, async (req, res) => {
  try {
    const totalClients = await db.get('SELECT COUNT(*) as count FROM customers');
    const clientsThisMonth = await db.get(
      'SELECT COUNT(*) as count FROM customers WHERE created_at >= date("now", "start of month")'
    );
    const clientsLastMonth = await db.get(
      'SELECT COUNT(*) as count FROM customers WHERE created_at >= date("now", "-1 month", "start of month") AND created_at < date("now", "start of month")'
    );

    res.json({
      success: true,
      data: {
        total: totalClients.count,
        thisMonth: clientsThisMonth.count,
        lastMonth: clientsLastMonth.count,
        growth: clientsLastMonth.count > 0 
          ? ((clientsThisMonth.count - clientsLastMonth.count) / clientsLastMonth.count * 100).toFixed(1)
          : 0
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
