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

router.get('/', authenticateToken, async (req, res) => {
  try {
    const rows = await db.all(
      `SELECT d.*, c.name as customer_name 
       FROM devis d 
       LEFT JOIN customers c ON d.customer_id = c.id 
       ORDER BY d.created_at DESC`
    );
    res.json({ success: true, data: rows });
  } catch (e) {
    console.error('Devis list error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const row = await db.get(
      `SELECT d.*, c.name as customer_name 
       FROM devis d 
       LEFT JOIN customers c ON d.customer_id = c.id 
       WHERE d.id = ?`,
      [req.params.id]
    );
    if (!row) return res.status(404).json({ success: false, message: 'Devis non trouvé' });
    res.json({ success: true, data: row });
  } catch (e) {
    console.error('Devis show error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

router.post('/', authenticateToken, [
  body('customer_id').isInt({ min: 1 }),
  body('total').isFloat({ min: 0 }),
  body('valid_until').optional().isISO8601(),
], handleValidationErrors, async (req, res) => {
  try {
    const { customer_id, total, valid_until } = req.body;
    const customer = await db.get('SELECT * FROM customers WHERE id = ?', [customer_id]);
    if (!customer) return res.status(404).json({ success: false, message: 'Client non trouvé' });
    const result = await db.run(
      'INSERT INTO devis (customer_id, total, valid_until) VALUES (?, ?, ?)',
      [customer_id, total, valid_until]
    );
    const created = await db.get('SELECT * FROM devis WHERE id = ?', [result.id]);
    res.status(201).json({ success: true, message: 'Devis créé avec succès', data: created });
  } catch (e) {
    console.error('Devis create error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

router.put('/:id', authenticateToken, [
  body('total').optional().isFloat({ min: 0 }),
  body('status').optional().isIn(['draft', 'sent', 'accepted', 'rejected']),
  body('valid_until').optional().isISO8601(),
], handleValidationErrors, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM devis WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Devis non trouvé' });
    const { total, status, valid_until } = req.body;
    await db.run(
      'UPDATE devis SET total = ?, status = ?, valid_until = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [
        total !== undefined ? total : existing.total,
        status !== undefined ? status : existing.status,
        valid_until !== undefined ? valid_until : existing.valid_until,
        req.params.id
      ]
    );
    const updated = await db.get('SELECT * FROM devis WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Devis mis à jour', data: updated });
  } catch (e) {
    console.error('Devis update error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM devis WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Devis non trouvé' });
    await db.run('DELETE FROM devis WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Devis supprimé avec succès' });
  } catch (e) {
    console.error('Devis delete error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

module.exports = router;


