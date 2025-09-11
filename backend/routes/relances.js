const express = require('express');
const { body, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const db = require('../database');

const router = express.Router();

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: "Token d'accès requis" });
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ success: false, message: 'Token invalide' });
    req.user = user; next();
  });
};

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, message: 'Données invalides', errors: errors.array() });
  next();
};

// Liste
router.get('/', authenticateToken, async (req, res) => {
  try {
    const rows = await db.all(
      `SELECT r.*, f.total as facture_total, f.status as facture_status 
       FROM relances r 
       LEFT JOIN factures f ON r.facture_id = f.id 
       ORDER BY r.created_at DESC`
    );
    res.json({ success: true, data: rows });
  } catch (e) {
    console.error('Relances list error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Détail
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const row = await db.get('SELECT * FROM relances WHERE id = ?', [req.params.id]);
    if (!row) return res.status(404).json({ success: false, message: 'Relance non trouvée' });
    res.json({ success: true, data: row });
  } catch (e) {
    console.error('Relance show error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Création
router.post('/', authenticateToken, [
  body('facture_id').isInt({ min: 1 }),
  body('type').isString().isLength({ min: 2 }),
  body('message').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { facture_id, type, message } = req.body;
    const facture = await db.get('SELECT * FROM factures WHERE id = ?', [facture_id]);
    if (!facture) return res.status(404).json({ success: false, message: 'Facture non trouvée' });

    const result = await db.run(
      'INSERT INTO relances (facture_id, type, message) VALUES (?, ?, ?)',
      [facture_id, type, message]
    );
    const created = await db.get('SELECT * FROM relances WHERE id = ?', [result.id]);
    res.status(201).json({ success: true, message: 'Relance créée avec succès', data: created });
  } catch (e) {
    console.error('Relance create error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Mise à jour
router.put('/:id', authenticateToken, [
  body('type').optional().isLength({ min: 2 }),
  body('message').optional().trim(),
  body('status').optional().isIn(['sent', 'processed'])
], handleValidationErrors, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM relances WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Relance non trouvée' });
    const { type, message, status } = req.body;
    await db.run(
      'UPDATE relances SET type = ?, message = ?, status = ?, created_at = created_at WHERE id = ?',
      [
        type !== undefined ? type : existing.type,
        message !== undefined ? message : existing.message,
        status !== undefined ? status : existing.status,
        req.params.id
      ]
    );
    const updated = await db.get('SELECT * FROM relances WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Relance mise à jour', data: updated });
  } catch (e) {
    console.error('Relance update error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Supprimer
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM relances WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Relance non trouvée' });
    await db.run('DELETE FROM relances WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Relance supprimée avec succès' });
  } catch (e) {
    console.error('Relance delete error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Marquer comme traitée (alias /traitee et /traiter)
const traiterHandler = async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM relances WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Relance non trouvée' });
    const note = req.body?.note || req.body?.commentaire || null;
    await db.run("UPDATE relances SET status = 'processed' WHERE id = ?", [req.params.id]);
    const updated = await db.get('SELECT * FROM relances WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Relance marquée comme traitée', data: { ...updated, note } });
  } catch (e) {
    console.error('Relance traiter error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
};

router.patch('/:id/traiter', authenticateToken, traiterHandler);
router.patch('/:id/traitee', authenticateToken, traiterHandler);

// Stats (alias)
const statsHandler = async (req, res) => {
  try {
    const total = await db.get('SELECT COUNT(*) as count FROM relances');
    const processed = await db.get("SELECT COUNT(*) as count FROM relances WHERE status = 'processed'");
    const sent = await db.get("SELECT COUNT(*) as count FROM relances WHERE status = 'sent'");
    res.json({ success: true, data: { total: total.count, processed: processed.count, sent: sent.count } });
  } catch (e) {
    console.error('Relances stats error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
};

router.get('/stats', authenticateToken, statsHandler);
router.get('/statistiques', authenticateToken, statsHandler);

module.exports = router;


