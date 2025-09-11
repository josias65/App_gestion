const express = require('express');
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

router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const [clients, commandes, factures, articles] = await Promise.all([
      db.get('SELECT COUNT(*) as count FROM customers'),
      db.get('SELECT COUNT(*) as count FROM commandes'),
      db.get('SELECT COUNT(*) as count FROM factures'),
      db.get('SELECT COUNT(*) as count FROM articles'),
    ]);

    const paidRevenue = await db.get('SELECT SUM(total) as total FROM factures WHERE status = "paid"');
    const pendingInvoices = await db.get('SELECT COUNT(*) as count FROM factures WHERE status = "pending"');

    res.json({
      success: true,
      data: {
        clients: clients.count,
        commandes: commandes.count,
        factures: factures.count,
        articles: articles.count,
        paidRevenue: paidRevenue.total || 0,
        pendingInvoices: pendingInvoices.count || 0,
      }
    });
  } catch (e) {
    console.error('Dashboard stats error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

module.exports = router;


