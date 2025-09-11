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
      `SELECT l.*, c.name as customer_name 
       FROM livraisons l 
       LEFT JOIN customers c ON l.customer_id = c.id 
       ORDER BY l.created_at DESC`
    );
    res.json({ success: true, data: rows });
  } catch (e) {
    console.error('Livraisons list error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Détail
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const row = await db.get('SELECT * FROM livraisons WHERE id = ?', [req.params.id]);
    if (!row) return res.status(404).json({ success: false, message: 'Livraison non trouvée' });
    res.json({ success: true, data: row });
  } catch (e) {
    console.error('Livraison show error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Création
router.post('/', authenticateToken, [
  body('customer_id').isInt({ min: 1 }),
  body('commande_id').optional().isInt({ min: 1 }),
  body('notes').optional().trim()
], handleValidationErrors, async (req, res) => {
  try {
    const { customer_id, commande_id, notes } = req.body;
    const customer = await db.get('SELECT * FROM customers WHERE id = ?', [customer_id]);
    if (!customer) return res.status(404).json({ success: false, message: 'Client non trouvé' });
    if (commande_id) {
      const cmd = await db.get('SELECT id FROM commandes WHERE id = ?', [commande_id]);
      if (!cmd) return res.status(404).json({ success: false, message: 'Commande non trouvée' });
    }
    const result = await db.run(
      'INSERT INTO livraisons (customer_id, commande_id, notes) VALUES (?, ?, ?)',
      [customer_id, commande_id, notes]
    );
    const created = await db.get('SELECT * FROM livraisons WHERE id = ?', [result.id]);
    res.status(201).json({ success: true, message: 'Livraison créée avec succès', data: created });
  } catch (e) {
    console.error('Livraison create error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// Changer statut
router.patch('/:id', authenticateToken, [
  body('status').isIn(['pending', 'in_transit', 'delivered', 'cancelled'])
], handleValidationErrors, async (req, res) => {
  try {
    const existing = await db.get('SELECT * FROM livraisons WHERE id = ?', [req.params.id]);
    if (!existing) return res.status(404).json({ success: false, message: 'Livraison non trouvée' });
    const { status } = req.body;
    await db.run(
      'UPDATE livraisons SET status = ?, delivered_at = CASE WHEN ? = "delivered" THEN CURRENT_TIMESTAMP ELSE delivered_at END, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [status, status, req.params.id]
    );
    const updated = await db.get('SELECT * FROM livraisons WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Statut de la livraison mis à jour', data: updated });
  } catch (e) {
    console.error('Livraison status error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

module.exports = router;


