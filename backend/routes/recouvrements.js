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
    return res.status(401).json({ success: false, message: "Token d'accès requis" });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Token invalide' });
    }
    req.user = user;
    next();
  });
};

// Validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, message: 'Données invalides', errors: errors.array() });
  }
  next();
};

// Liste
router.get('/', authenticateToken, async (req, res) => {
  try {
    const recs = await db.all(
      `SELECT r.*, f.total as facture_total, f.status as facture_status 
       FROM recouvrements r 
       LEFT JOIN factures f ON r.facture_id = f.id 
       ORDER BY r.created_at DESC`
    );
    res.json({ success: true, data: recs });
  } catch (error) {
    console.error('Erreur recouvrements list:', error);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Détail
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const rec = await db.get(
      `SELECT r.*, f.total as facture_total, f.status as facture_status 
       FROM recouvrements r 
       LEFT JOIN factures f ON r.facture_id = f.id 
       WHERE r.id = ?`,
      [req.params.id]
    );
    if (!rec) return res.status(404).json({ success: false, message: 'Recouvrement non trouvé' });
    res.json({ success: true, data: rec });
  } catch (error) {
    console.error('Erreur recouvrement show:', error);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Création
router.post('/', authenticateToken, [
  body('facture_id').isInt({ min: 1 }),
  body('amount').isFloat({ min: 0 }),
  body('method').optional().trim(),
  body('notes').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { facture_id, amount, method, notes } = req.body;

    const facture = await db.get('SELECT * FROM factures WHERE id = ?', [facture_id]);
    if (!facture) return res.status(404).json({ success: false, message: 'Facture non trouvée' });

    const result = await db.run(
      'INSERT INTO recouvrements (facture_id, amount, method, notes) VALUES (?, ?, ?, ?)',
      [facture_id, amount, method, notes]
    );

    const created = await db.get('SELECT * FROM recouvrements WHERE id = ?', [result.id]);
    res.status(201).json({ success: true, message: 'Recouvrement créé avec succès', data: created });
  } catch (error) {
    console.error('Erreur recouvrement create:', error);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Mise à jour
router.put('/:id', authenticateToken, [
  body('amount').optional().isFloat({ min: 0 }),
  body('method').optional().trim(),
  body('status').optional().isIn(['pending', 'paid', 'cancelled']),
  body('notes').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM recouvrements WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Recouvrement non trouvé' });

    const { amount, method, status, notes } = req.body;
    await db.run(
      'UPDATE recouvrements SET amount = ?, method = ?, status = ?, notes = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [
        amount !== undefined ? amount : existing.amount,
        method !== undefined ? method : existing.method,
        status !== undefined ? status : existing.status,
        notes !== undefined ? notes : existing.notes,
        req.params.id
      ]
    );

    const updated = await db.get('SELECT * FROM recouvrements WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Recouvrement mis à jour', data: updated });
  } catch (error) {
    console.error('Erreur recouvrement update:', error);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Suppression
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM recouvrements WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Recouvrement non trouvé' });
    await db.run('DELETE FROM recouvrements WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Recouvrement supprimé avec succès' });
  } catch (error) {
    console.error('Erreur recouvrement delete:', error);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Statistiques (deux alias)
const statsHandler = async (req, res) => {
  try {
    const totalCount = await db.get('SELECT COUNT(*) as count FROM recouvrements');
    const totalAmount = await db.get('SELECT SUM(amount) as total FROM recouvrements');
    const paidAmount = await db.get("SELECT SUM(amount) as total FROM recouvrements WHERE status = 'paid'");
    const pendingAmount = await db.get("SELECT SUM(amount) as total FROM recouvrements WHERE status = 'pending'");

    res.json({
      success: true,
      data: {
        total: totalCount.count,
        totalAmount: totalAmount.total || 0,
        paidAmount: paidAmount.total || 0,
        pendingAmount: pendingAmount.total || 0
      }
    });
  } catch (error) {
    console.error('Erreur recouvrements stats:', error);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
};

router.get('/stats', authenticateToken, statsHandler);
router.get('/statistiques', authenticateToken, statsHandler);

module.exports = router;


