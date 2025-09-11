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

// Transformer la table key/value en objet Settings
async function loadSettingsObject() {
  const rows = await db.all('SELECT key, value FROM settings');
  const map = Object.fromEntries(rows.map(r => [r.key, r.value]));
  return {
    isDarkTheme: map.isDarkTheme === 'true',
    notificationsEnabled: map.notificationsEnabled !== 'false',
    currency: map.currency || 'EUR',
    language: map.language || 'Français',
    autoLock: map.autoLock !== 'false',
  };
}

// GET /api/settings
router.get('/', authenticateToken, async (req, res) => {
  try {
    const settings = await loadSettingsObject();
    res.json({ success: true, data: settings });
  } catch (e) {
    console.error('Settings get error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

// PUT /api/settings
router.put('/', authenticateToken, async (req, res) => {
  try {
    const payload = req.body || {};
    const entries = Object.entries(payload);
    for (const [key, val] of entries) {
      await db.run(
        `INSERT INTO settings(key, value, updated_at) VALUES(?, ?, CURRENT_TIMESTAMP)
         ON CONFLICT(key) DO UPDATE SET value=excluded.value, updated_at=CURRENT_TIMESTAMP`,
        [key, String(val)]
      );
    }
    const settings = await loadSettingsObject();
    res.json({ success: true, message: 'Paramètres mis à jour', data: settings });
  } catch (e) {
    console.error('Settings put error:', e);
    res.status(500).json({ success: false, message: 'Erreur interne du serveur' });
  }
});

module.exports = router;



