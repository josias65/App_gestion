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
      `SELECT p.*, c.name as customer_name 
       FROM proformas p 
       LEFT JOIN customers c ON p.customer_id = c.id 
       ORDER BY p.created_at DESC`
    );
    res.json({ success: true, data: rows });
  } catch (e) {
    console.error('Proformas list error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const row = await db.get(
      `SELECT p.*, c.name as customer_name 
       FROM proformas p 
       LEFT JOIN customers c ON p.customer_id = c.id 
       WHERE p.id = ?`,
      [req.params.id]
    );
    if (!row) return res.status(404).json({ success: false, message: 'Proforma non trouvée' });
    res.json({ success: true, data: row });
  } catch (e) {
    console.error('Proforma show error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

router.post('/', authenticateToken, [
  body('customer_id').isInt({ min: 1 }),
  body('total').isFloat({ min: 0 })
], handleValidationErrors, async (req, res) => {
  try {
    const { customer_id, total } = req.body;
    const customer = await db.get('SELECT * FROM customers WHERE id = ?', [customer_id]);
    if (!customer) return res.status(404).json({ success: false, message: 'Client non trouvé' });
    const result = await db.run(
      'INSERT INTO proformas (customer_id, total) VALUES (?, ?)',
      [customer_id, total]
    );
    const created = await db.get('SELECT * FROM proformas WHERE id = ?', [result.id]);
    res.status(201).json({ success: true, message: 'Proforma créée avec succès', data: created });
  } catch (e) {
    console.error('Proforma create error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

router.patch('/:id', authenticateToken, [
  body('status').optional().isIn(['pending', 'sent', 'accepted', 'cancelled'])
], handleValidationErrors, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM proformas WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Proforma non trouvée' });
    const { status } = req.body;
    await db.run('UPDATE proformas SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [status || existing.status, req.params.id]);
    const updated = await db.get('SELECT * FROM proformas WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Proforma mise à jour', data: updated });
  } catch (e) {
    console.error('Proforma update error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

module.exports = router;


