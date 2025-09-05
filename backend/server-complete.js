const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const db = require('./database');

// Initialiser la base de données
async function initServer() {
  try {
    console.log('🚀 Initialisation du serveur AppGestion...');
    
    // Initialiser la base de données
    await db.init();
    
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

    // Routes
    app.use('/auth', require('./routes/auth'));
    app.use('/customers', require('./routes/customers'));
    app.use('/commande', require('./routes/orders'));
    app.use('/facture', require('./routes/invoices'));
    app.use('/article', require('./routes/products'));
    app.use('/appels-offre', require('./routes/appels-offre'));
    app.use('/marches', require('./routes/marches'));

    // Route de santé
    app.get('/health', (req, res) => {
      res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        database: 'Connected'
      });
    });

    // Route racine
    app.get('/', (req, res) => {
      res.json({
        message: 'API AppGestion Backend',
        version: '1.0.0',
        status: 'Running',
        endpoints: {
          auth: '/auth',
          customers: '/customers',
          orders: '/commande',
          invoices: '/facture',
          products: '/article',
          appelsOffre: '/appels-offre',
          marches: '/marches'
        },
        users: {
          admin: 'admin@neo.com / admin123',
          test: 'test@example.com / password123'
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
      console.log(`🔐 Utilisateurs de test:`);
      console.log(`   - Admin: admin@neo.com / admin123`);
      console.log(`   - Test: test@example.com / password123`);
      console.log(`📊 Base de données: SQLite (database.sqlite)`);
    });

  } catch (error) {
    console.error('❌ Erreur lors de l\'initialisation du serveur:', error);
    process.exit(1);
  }
}

// Démarrer le serveur
initServer();
