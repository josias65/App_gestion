const express = require('express');
const { body, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const db = require('../database');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;

const router = express.Router();

// Configuration multer pour upload de fichiers
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads/appels-offre');
    try {
      await fs.mkdir(uploadDir, { recursive: true });
      cb(null, uploadDir);
    } catch (error) {
      cb(error);
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `appel-${req.params.id || 'new'}-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'image/jpeg',
      'image/png',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Type de fichier non autorisé'));
    }
  }
});

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

// ===== GESTION DES APPELS D'OFFRE =====

// Obtenir tous les appels d'offre avec filtres avancés
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      status = '', 
      category = '',
      search = '',
      sortBy = 'created_at',
      sortOrder = 'DESC',
      dateFrom = '',
      dateTo = '',
      budgetMin = '',
      budgetMax = ''
    } = req.query;
    
    const offset = (page - 1) * limit;
    let whereClause = '';
    let params = [];

    // Construction de la clause WHERE dynamique
    const conditions = [];
    
    if (status) {
      conditions.push('status = ?');
      params.push(status);
    }
    
    if (category) {
      conditions.push('category = ?');
      params.push(category);
    }
    
    if (search) {
      conditions.push('(title LIKE ? OR description LIKE ?)');
      params.push(`%${search}%`, `%${search}%`);
    }
    
    if (dateFrom) {
      conditions.push('deadline >= ?');
      params.push(dateFrom);
    }
    
    if (dateTo) {
      conditions.push('deadline <= ?');
      params.push(dateTo);
    }
    
    if (budgetMin) {
      conditions.push('budget >= ?');
      params.push(budgetMin);
    }
    
    if (budgetMax) {
      conditions.push('budget <= ?');
      params.push(budgetMax);
    }

    if (conditions.length > 0) {
      whereClause = 'WHERE ' + conditions.join(' AND ');
    }

    // Validation du tri
    const allowedSortFields = ['created_at', 'deadline', 'budget', 'title', 'status'];
    const validSortBy = allowedSortFields.includes(sortBy) ? sortBy : 'created_at';
    const validSortOrder = ['ASC', 'DESC'].includes(sortOrder.toUpperCase()) ? sortOrder.toUpperCase() : 'DESC';

    const appelsOffre = await db.all(
      `SELECT ao.*, 
       COUNT(s.id) as soumissions_count,
       MIN(s.amount) as min_amount,
       MAX(s.amount) as max_amount,
       AVG(s.amount) as avg_amount
       FROM appels_offre ao 
       LEFT JOIN soumissions s ON ao.id = s.appel_offre_id 
       ${whereClause} 
       GROUP BY ao.id 
       ORDER BY ${validSortBy} ${validSortOrder} 
       LIMIT ? OFFSET ?`,
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
      },
      filters: {
        status, category, search, dateFrom, dateTo, budgetMin, budgetMax
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

// Obtenir un appel d'offre par ID avec toutes ses données
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

    // Récupérer les soumissions avec détails du client
    const soumissions = await db.all(
      `SELECT s.*, c.name as customer_name, c.email as customer_email, c.phone as customer_phone
       FROM soumissions s 
       LEFT JOIN customers c ON s.customer_id = c.id 
       WHERE s.appel_offre_id = ? 
       ORDER BY s.created_at DESC`,
      [id]
    );

    // Récupérer les documents
    const documents = await db.all(
      'SELECT * FROM appel_offre_documents WHERE appel_offre_id = ? ORDER BY created_at DESC',
      [id]
    );

    // Récupérer les commentaires
    const commentaires = await db.all(
      `SELECT c.*, u.name as user_name 
       FROM appel_offre_comments c 
       LEFT JOIN users u ON c.user_id = u.id 
       WHERE c.appel_offre_id = ? 
       ORDER BY c.created_at ASC`,
      [id]
    );

    // Récupérer l'historique des modifications
    const historique = await db.all(
      `SELECT h.*, u.name as user_name 
       FROM appel_offre_history h 
       LEFT JOIN users u ON h.user_id = u.id 
       WHERE h.appel_offre_id = ? 
       ORDER BY h.created_at DESC`,
      [id]
    );

    // Récupérer les critères d'évaluation
    const criteres = await db.all(
      'SELECT * FROM appel_offre_criteria WHERE appel_offre_id = ? ORDER BY weight DESC',
      [id]
    );

    // Statistiques de soumission
    const stats = {
      totalSoumissions: soumissions.length,
      montantMinimum: soumissions.length > 0 ? Math.min(...soumissions.map(s => s.amount)) : 0,
      montantMaximum: soumissions.length > 0 ? Math.max(...soumissions.map(s => s.amount)) : 0,
      montantMoyen: soumissions.length > 0 ? soumissions.reduce((sum, s) => sum + s.amount, 0) / soumissions.length : 0
    };

    res.json({
      success: true,
      data: {
        ...appelOffre,
        soumissions,
        documents,
        commentaires,
        historique,
        criteres,
        stats
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

// Créer un nouvel appel d'offre avec critères
router.post('/', authenticateToken, [
  body('title').isLength({ min: 2 }).trim(),
  body('description').optional().trim(),
  body('deadline').optional().isISO8601(),
  body('budget').optional().isFloat({ min: 0 }),
  body('category').optional().trim(),
  body('location').optional().trim(),
  body('urgency').optional().isIn(['basse', 'normale', 'haute', 'urgente']),
  body('criteria').optional().isArray()
], handleValidationErrors, async (req, res) => {
  try {
    const { 
      title, 
      description, 
      deadline, 
      budget, 
      category,
      location,
      urgency,
      criteria = []
    } = req.body;

    // Démarrer une transaction
    const result = await db.run(
      `INSERT INTO appels_offre 
       (title, description, deadline, budget, category, location, urgency, status, created_by) 
       VALUES (?, ?, ?, ?, ?, ?, ?, 'open', ?)`,
      [title, description, deadline, budget, category, location, urgency, req.user.id]
    );

    const appelOffreId = result.id;

    // Ajouter les critères d'évaluation
    if (criteria.length > 0) {
      for (const critere of criteria) {
        await db.run(
          'INSERT INTO appel_offre_criteria (appel_offre_id, name, description, weight) VALUES (?, ?, ?, ?)',
          [appelOffreId, critere.name, critere.description, critere.weight]
        );
      }
    }

    // Enregistrer l'historique
    await db.run(
      `INSERT INTO appel_offre_history 
       (appel_offre_id, action, details, user_id) 
       VALUES (?, 'created', 'Appel d\'offre créé', ?)`,
      [appelOffreId, req.user.id]
    );

    const newAppelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ?',
      [appelOffreId]
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
  body('status').optional().isIn(['open', 'closed', 'awarded', 'cancelled']),
  body('category').optional().trim(),
  body('location').optional().trim(),
  body('urgency').optional().isIn(['basse', 'normale', 'haute', 'urgente'])
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

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

    // Préparer les champs à mettre à jour
    const updateFields = [];
    const updateValues = [];

    Object.keys(updates).forEach(key => {
      if (updates[key] !== undefined && key !== 'id') {
        updateFields.push(`${key} = ?`);
        updateValues.push(updates[key]);
      }
    });

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Aucune donnée à mettre à jour'
      });
    }

    updateFields.push('updated_at = CURRENT_TIMESTAMP');
    updateValues.push(id);

    await db.run(
      `UPDATE appels_offre SET ${updateFields.join(', ')} WHERE id = ?`,
      updateValues
    );

    // Enregistrer l'historique des modifications
    const changes = Object.keys(updates)
      .filter(key => key !== 'id' && updates[key] !== undefined)
      .map(key => `${key}: ${existingAppelOffre[key]} → ${updates[key]}`)
      .join(', ');

    await db.run(
      `INSERT INTO appel_offre_history 
       (appel_offre_id, action, details, user_id) 
       VALUES (?, 'updated', ?, ?)`,
      [id, changes, req.user.id]
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

// ===== GESTION DES DOCUMENTS =====

// Upload de documents pour un appel d'offre
router.post('/:id/documents', authenticateToken, upload.array('documents', 10), async (req, res) => {
  try {
    const { id } = req.params;
    const files = req.files;

    if (!files || files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Aucun fichier fourni'
      });
    }

    const uploadedDocs = [];
    
    for (const file of files) {
      const result = await db.run(
        `INSERT INTO appel_offre_documents 
         (appel_offre_id, filename, original_name, file_path, file_size, file_type, uploaded_by) 
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          id,
          file.filename,
          file.originalname,
          file.path,
          file.size,
          file.mimetype,
          req.user.id
        ]
      );

      uploadedDocs.push({
        id: result.id,
        filename: file.filename,
        original_name: file.originalname,
        file_size: file.size,
        file_type: file.mimetype
      });
    }

    // Enregistrer l'historique
    await db.run(
      `INSERT INTO appel_offre_history 
       (appel_offre_id, action, details, user_id) 
       VALUES (?, 'documents_uploaded', ?, ?)`,
      [id, `${files.length} document(s) téléchargé(s)`, req.user.id]
    );

    res.json({
      success: true,
      message: `${files.length} document(s) téléchargé(s) avec succès`,
      data: uploadedDocs
    });

  } catch (error) {
    console.error('Erreur lors de l\'upload des documents:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'upload des documents'
    });
  }
});

// Télécharger un document
router.get('/:id/documents/:docId/download', authenticateToken, async (req, res) => {
  try {
    const { id, docId } = req.params;

    const document = await db.get(
      'SELECT * FROM appel_offre_documents WHERE id = ? AND appel_offre_id = ?',
      [docId, id]
    );

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document non trouvé'
      });
    }

    res.download(document.file_path, document.original_name);

  } catch (error) {
    console.error('Erreur lors du téléchargement:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du téléchargement'
    });
  }
});

// Supprimer un document
router.delete('/:id/documents/:docId', authenticateToken, async (req, res) => {
  try {
    const { id, docId } = req.params;

    const document = await db.get(
      'SELECT * FROM appel_offre_documents WHERE id = ? AND appel_offre_id = ?',
      [docId, id]
    );

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document non trouvé'
      });
    }

    // Supprimer le fichier physique
    try {
      await fs.unlink(document.file_path);
    } catch (error) {
      console.warn('Impossible de supprimer le fichier physique:', error);
    }

    // Supprimer de la base de données
    await db.run(
      'DELETE FROM appel_offre_documents WHERE id = ?',
      [docId]
    );

    // Enregistrer l'historique
    await db.run(
      `INSERT INTO appel_offre_history 
       (appel_offre_id, action, details, user_id) 
       VALUES (?, 'document_deleted', ?, ?)`,
      [id, `Document supprimé: ${document.original_name}`, req.user.id]
    );

    res.json({
      success: true,
      message: 'Document supprimé avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression du document:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression'
    });
  }
});

// ===== GESTION DES COMMENTAIRES =====

// Ajouter un commentaire
router.post('/:id/comments', authenticateToken, [
  body('content').isLength({ min: 1 }).trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { content } = req.body;

    const result = await db.run(
      'INSERT INTO appel_offre_comments (appel_offre_id, user_id, content) VALUES (?, ?, ?)',
      [id, req.user.id, content]
    );

    const newComment = await db.get(
      `SELECT c.*, u.name as user_name 
       FROM appel_offre_comments c 
       LEFT JOIN users u ON c.user_id = u.id 
       WHERE c.id = ?`,
      [result.id]
    );

    // Enregistrer l'historique
    await db.run(
      `INSERT INTO appel_offre_history 
       (appel_offre_id, action, details, user_id) 
       VALUES (?, 'comment_added', 'Commentaire ajouté', ?)`,
      [id, req.user.id]
    );

    res.status(201).json({
      success: true,
      message: 'Commentaire ajouté avec succès',
      data: newComment
    });

  } catch (error) {
    console.error('Erreur lors de l\'ajout du commentaire:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// ===== GESTION DES SOUMISSIONS =====

// Soumettre une offre avec documents
router.post('/:id/soumissions', authenticateToken, [
  body('customer_id').isInt({ min: 1 }),
  body('amount').isFloat({ min: 0 }),
  body('notes').optional().trim(),
  body('delivery_time').optional().trim(),
  body('warranty').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { customer_id, amount, notes, delivery_time, warranty } = req.body;

    // Vérifier si l'appel d'offre existe et est ouvert
    const appelOffre = await db.get(
      'SELECT * FROM appels_offre WHERE id = ? AND status = "open"',
      [id]
    );

    if (!appelOffre) {
      return res.status(404).json({
        success: false,
        message: 'Appel d\'offre non trouvé ou fermé'
      });
    }

    // Vérifier si ce client a déjà soumis une offre
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
      `INSERT INTO soumissions 
       (appel_offre_id, customer_id, amount, notes, delivery_time, warranty, status) 
       VALUES (?, ?, ?, ?, ?, ?, 'submitted')`,
      [id, customer_id, amount, notes, delivery_time, warranty]
    );

    const newSoumission = await db.get(
      `SELECT s.*, c.name as customer_name, c.email as customer_email
       FROM soumissions s 
       LEFT JOIN customers c ON s.customer_id = c.id 
       WHERE s.id = ?`,
      [result.id]
    );

    // Enregistrer l'historique
    await db.run(
      `INSERT INTO appel_offre_history 
       (appel_offre_id, action, details, user_id) 
       VALUES (?, 'submission_added', ?, ?)`,
      [id, `Nouvelle soumission de ${newSoumission.customer_name}`, req.user.id]
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

// Évaluer une soumission
router.post('/:id/soumissions/:soumissionId/evaluate', authenticateToken, [
  body('scores').isArray(),
  body('total_score').isFloat({ min: 0, max: 100 }),
  body('comments').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { id, soumissionId } = req.params;
    const { scores, total_score, comments } = req.body;

    // Vérifier si la soumission existe
    const soumission = await db.get(
      'SELECT * FROM soumissions WHERE id = ? AND appel_offre_id = ?',
      [soumissionId, id]
    );

    if (!soumission) {
      return res.status(404).json({
        success: false,
        message: 'Soumission non trouvée'
      });
    }

    // Mettre à jour la soumission avec l'évaluation
    await db.run(
      'UPDATE soumissions SET total_score = ?, evaluation_comments = ?, evaluated_by = ?, evaluated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [total_score, comments, req.user.id, soumissionId]
    );

    // Enregistrer les scores par critère
    for (const score of scores) {
      await db.run(
        'INSERT INTO soumission_scores (soumission_id, criteria_id, score, comments) VALUES (?, ?, ?, ?)',
        [soumissionId, score.criteria_id, score.score, score.comments]
      );
    }

    res.json({
      success: true,
      message: 'Soumission évaluée avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de l\'évaluation:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

// ===== STATISTIQUES ET RAPPORTS =====

// Statistiques détaillées
router.get('/stats/detailed', authenticateToken, async (req, res) => {
  try {
    const { dateFrom, dateTo } = req.query;

    let dateFilter = '';
    let params = [];
    
    if (dateFrom && dateTo) {
      dateFilter = 'WHERE created_at BETWEEN ? AND ?';
      params = [dateFrom, dateTo];
    }

    // Statistiques générales
    const totalAppelsOffre = await db.get(
      `SELECT COUNT(*) as count FROM appels_offre ${dateFilter}`,
      params
    );

    const statusStats = await db.all(
      `SELECT status, COUNT(*) as count FROM appels_offre ${dateFilter} GROUP BY status`,
      params
    );

    const categoryStats = await db.all(
      `SELECT category, COUNT(*) as count FROM appels_offre ${dateFilter} GROUP BY category`,
      params
    );

    // Statistiques financières
    const budgetStats = await db.get(
      `SELECT 
       SUM(budget) as total_budget,
       AVG(budget) as avg_budget,
       MIN(budget) as min_budget,
       MAX(budget) as max_budget
       FROM appels_offre ${dateFilter}`,
      params
    );

    // Statistiques des soumissions
    const soumissionStats = await db.get(
      `SELECT 
       COUNT(*) as total_soumissions,
       AVG(amount) as avg_amount,
       MIN(amount) as min_amount,
       MAX(amount) as max_amount
       FROM soumissions s 
       JOIN appels_offre ao ON s.appel_offre_id = ao.id 
       ${dateFilter.replace('created_at', 'ao.created_at')}`,
      params
    );

    // Top des clients par nombre de soumissions
    const topClients = await db.all(
      `SELECT c.name, c.email, COUNT(s.id) as soumissions_count
       FROM customers c
       JOIN soumissions s ON c.id = s.customer_id
       JOIN appels_offre ao ON s.appel_offre_id = ao.id
       ${dateFilter.replace('created_at', 'ao.created_at')}
       GROUP BY c.id, c.name, c.email
       ORDER BY soumissions_count DESC
       LIMIT 10`,
      params
    );

    res.json({
      success: true,
      data: {
        general: {
          total: totalAppelsOffre.count,
          statusBreakdown: statusStats,
          categoryBreakdown: categoryStats
        },
        financial: budgetStats,
        soumissions: soumissionStats,
        topClients
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

// Export des données
router.get('/export/:format', authenticateToken, async (req, res) => {
  try {
    const { format } = req.params;
    const { dateFrom, dateTo } = req.query;

    if (!['csv', 'excel'].includes(format)) {
      return res.status(400).json({
        success: false,
        message: 'Format non supporté'
      });
    }

    let dateFilter = '';
    let params = [];
    
    if (dateFrom && dateTo) {
      dateFilter = 'WHERE ao.created_at BETWEEN ? AND ?';
      params = [dateFrom, dateTo];
    }

    const data = await db.all(
      `SELECT 
       ao.id,
       ao.title,
       ao.description,
       ao.budget,
       ao.status,
       ao.category,
       ao.deadline,
       ao.created_at,
       COUNT(s.id) as soumissions_count,
       AVG(s.amount) as avg_submission_amount
       FROM appels_offre ao
       LEFT JOIN soumissions s ON ao.id = s.appel_offre_id
       ${dateFilter}
       GROUP BY ao.id
       ORDER BY ao.created_at DESC`,
      params
    );

    if (format === 'csv') {
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', 'attachment; filename="appels_offre.csv"');
      
      // Générer CSV
      const csvHeader = 'ID,Title,Description,Budget,Status,Category,Deadline,Created At,Submissions Count,Avg Submission Amount\n';
      const csvData = data.map(row => 
        `${row.id},"${row.title}","${row.description}",${row.budget},${row.status},${row.category},${row.deadline},${row.created_at},${row.soumissions_count},${row.avg_submission_amount}`
      ).join('\n');
      
      res.send(csvHeader + csvData);
    }

  } catch (error) {
    console.error('Erreur lors de l\'export:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'export'
    });
  }
});

module.exports = router;
