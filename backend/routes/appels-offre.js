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

// Obtenir tous les appels d'offre
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 10, status = '' } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = '';
    let params = [];

    if (status) {
      whereClause = 'WHERE status = ?';
      params.push(status);
    }

    const appelsOffre = await db.all(
      `SELECT * FROM appels_offre ${whereClause} ORDER BY created_at DESC LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const totalCount = await db.get(
      `SELECT COUNT(*) as count FROM appels_offre ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: appelsOffre,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalCount.count,
        pages: Math.ceil(totalCount.count / limit)
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des appels d\'offre:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir un appel d'offre par ID avec ses soumissions
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const appelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ?',
      [id]
    );

    if (!appelOffre) {
      return res.status(404).json({
        success: false,
        message: 'Appel d\'offre non trouvé'
      });
    }

    // Récupérer les soumissions
    const soumissions = await db.all(
      `SELECT s.*, c.name as customer_name, c.email as customer_email
       FROM soumissions s 
       LEFT JOIN customers c ON s.customer_id = c.id 
       WHERE s.appel_offre_id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...appelOffre,
        soumissions
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération de l\'appel d\'offre:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Créer un nouvel appel d'offre
router.post('/', authenticateToken, [
  body('title').isLength({ min: 2 }).trim(),
  body('description').optional().trim(),
  body('deadline').optional().isISO8601(),
  body('budget').optional().isFloat({ min: 0 })
], handleValidationErrors, async (req, res) => {
  try {
    const { title, description, deadline, budget } = req.body;

    const result = await db.run(
      'INSERT INTO appels_offre (title, description, deadline, budget) VALUES (?, ?, ?, ?)',
      [title, description, deadline, budget]
    );

    const newAppelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ?',
      [result.id]
    );

    res.status(201).json({
      success: true,
      message: 'Appel d\'offre créé avec succès',
      data: newAppelOffre
    });

  } catch (error) {
    console.error('Erreur lors de la création de l\'appel d\'offre:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Mettre à jour un appel d'offre
router.put('/:id', authenticateToken, [
  body('title').optional().isLength({ min: 2 }).trim(),
  body('description').optional().trim(),
  body('deadline').optional().isISO8601(),
  body('budget').optional().isFloat({ min: 0 }),
  body('status').optional().isIn(['open', 'closed', 'awarded'])
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, deadline, budget, status } = req.body;

    // Vérifier si l'appel d'offre existe
    const existingAppelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ?',
      [id]
    );

    if (!existingAppelOffre) {
      return res.status(404).json({
        success: false,
        message: 'Appel d\'offre non trouvé'
      });
    }

    await db.run(
      'UPDATE appels_offre SET title = ?, description = ?, deadline = ?, budget = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [
        title || existingAppelOffre.title,
        description !== undefined ? description : existingAppelOffre.description,
        deadline || existingAppelOffre.deadline,
        budget !== undefined ? budget : existingAppelOffre.budget,
        status || existingAppelOffre.status,
        id
      ]
    );

    const updatedAppelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Appel d\'offre mis à jour avec succès',
      data: updatedAppelOffre
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'appel d\'offre:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Supprimer un appel d'offre
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier si l'appel d'offre existe
    const appelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ?',
      [id]
    );

    if (!appelOffre) {
      return res.status(404).json({
        success: false,
        message: 'Appel d\'offre non trouvé'
      });
    }

    // Supprimer les soumissions associées
    await db.run('DELETE FROM soumissions WHERE appel_offre_id = ?', [id]);

    // Supprimer l'appel d'offre
    await db.run('DELETE FROM appels_offre WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Appel d\'offre supprimé avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression de l\'appel d\'offre:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Soumettre une offre
router.post('/:id/soumissions', authenticateToken, [
  body('customer_id').isInt({ min: 1 }),
  body('amount').isFloat({ min: 0 }),
  body('notes').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { customer_id, amount, notes } = req.body;

    // Vérifier si l'appel d'offre existe
    const appelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ?',
      [id]
    );

    if (!appelOffre) {
      return res.status(404).json({
        success: false,
        message: 'Appel d\'offre non trouvé'
      });
    }

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

    // Vérifier si ce client a déjà soumis une offre pour cet appel d'offre
    const existingSoumission = await db.get(
      'SELECT id FROM soumissions WHERE appel_offre_id = ? AND customer_id = ?',
      [id, customer_id]
    );

    if (existingSoumission) {
      return res.status(400).json({
        success: false,
        message: 'Ce client a déjà soumis une offre pour cet appel d\'offre'
      });
    }

    const result = await db.run(
      'INSERT INTO soumissions (appel_offre_id, customer_id, amount, notes) VALUES (?, ?, ?, ?)',
      [id, customer_id, amount, notes]
    );

    const newSoumission = await db.get(
      `SELECT s.*, c.name as customer_name, c.email as customer_email
       FROM soumissions s 
       LEFT JOIN customers c ON s.customer_id = c.id 
       WHERE s.id = ?`,
      [result.id]
    );

    res.status(201).json({
      success: true,
      message: 'Soumission créée avec succès',
      data: newSoumission
    });

  } catch (error) {
    console.error('Erreur lors de la création de la soumission:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// Obtenir les statistiques des appels d'offre
router.get('/stats/overview', authenticateToken, async (req, res) => {
  try {
    const totalAppelsOffre = await db.get('SELECT COUNT(*) as count FROM appels_offre');
    const openAppelsOffre = await db.get('SELECT COUNT(*) as count FROM appels_offre WHERE status = "open"');
    const totalSoumissions = await db.get('SELECT COUNT(*) as count FROM soumissions');
    const avgAmount = await db.get('SELECT AVG(amount) as avg FROM soumissions');

    // Statistiques par statut
    const statusStats = await db.all(
      'SELECT status, COUNT(*) as count FROM appels_offre GROUP BY status'
    );

    res.json({
      success: true,
      data: {
        total: totalAppelsOffre.count,
        open: openAppelsOffre.count,
        totalSoumissions: totalSoumissions.count,
        avgAmount: avgAmount.avg || 0,
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
