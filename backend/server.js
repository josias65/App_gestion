const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const customerRoutes = require('./routes/customers');
const orderRoutes = require('./routes/orders');
const invoiceRoutes = require('./routes/invoices');
const productRoutes = require('./routes/products');
const appelsOffreRoutes = require('./routes/appels-offre');
const marcheRoutes = require('./routes/marches');
const recouvrementsRoutes = require('./routes/recouvrements');
const relancesRoutes = require('./routes/relances');
const devisRoutes = require('./routes/devis');
const proformaRoutes = require('./routes/proforma');
const livraisonsRoutes = require('./routes/livraisons');
const dashboardRoutes = require('./routes/dashboard');
const settingsRoutes = require('./routes/settings');
const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware de sécurité
app.use(helmet());

// Configuration CORS pour Flutter
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://10.0.2.2:8000', // Émulateur Android
    'http://localhost:8000', // Simulateur iOS
    'http://127.0.0.1:8000'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limite de 100 requêtes par IP par fenêtre
  message: {
    error: 'Trop de requêtes depuis cette IP, veuillez réessayer plus tard.'
  }
});
app.use(limiter);

// Middleware pour parser le JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Middleware de logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes de l'API
app.use('/api/auth', authRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/invoices', invoiceRoutes);
app.use('/api/products', productRoutes);
app.use('/api/appels-offre', appelsOffreRoutes);
app.use('/api/marches', marcheRoutes);
app.use('/api/recouvrements', recouvrementsRoutes);
app.use('/api/relances', relancesRoutes);
app.use('/api/devis', devisRoutes);
app.use('/api/proforma', proformaRoutes);
app.use('/api/livraison', livraisonsRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/v1', apiRoutes); // Nouvelles routes API

// Route de santé
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Route racine
app.get('/', (req, res) => {
  res.json({
    message: 'API AppGestion Backend',
    version: '1.0.0',
    endpoints: {
      auth: '/auth',
      customers: '/customers',
      orders: '/commande',
      invoices: '/facture',
      products: '/article',
      appelsOffre: '/appels-offre',
      marches: '/marches'
    }
  });
});

// Middleware de gestion d'erreurs
app.use((err, req, res, next) => {
  console.error('Erreur:', err.stack);
  res.status(500).json({
    success: false,
    message: 'Erreur interne du serveur',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Middleware pour les routes non trouvées
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée'
  });
});

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`📱 Accessible depuis Flutter sur: http://10.0.2.2:${PORT}`);
  console.log(`🌐 Accessible localement sur: http://localhost:${PORT}`);
});

module.exports = app;
