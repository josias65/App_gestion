const jsonServer = require('json-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

// Configuration
const SECRET_KEY = 'votre_cle_secrete_jwt_2024';
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

app.use(express.json());
app.use(middlewares);

// Middleware pour logger les requêtes
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Route de santé
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Serveur fonctionnel',
    timestamp: new Date().toISOString()
  });
});

// Routes d'authentification
app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email et mot de passe requis',
        errors: {
          email: !email ? ['Email requis'] : [],
          password: !password ? ['Mot de passe requis'] : []
        }
      });
    }

    // Lire la base de données
    const dbPath = path.join(__dirname, 'db.json');
    const db = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
    
    // Trouver l'utilisateur
    const user = db.users.find(u => u.email === email);
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }

    // Vérifier le mot de passe (pour simplifier, on accepte aussi 'password')
    const isPasswordValid = password === 'password' || bcrypt.compareSync(password, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }

    // Générer les tokens
    const accessToken = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      SECRET_KEY,
      { expiresIn: '1h' }
    );

    const refreshToken = jwt.sign(
      { id: user.id },
      SECRET_KEY,
      { expiresIn: '7d' }
    );

    // Supprimer le mot de passe de la réponse
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      success: true,
      message: 'Connexion réussie',
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        user: userWithoutPassword
      }
    });

  } catch (error) {
    console.error('Erreur lors de la connexion:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

app.post('/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Tous les champs sont requis',
        errors: {
          name: !name ? ['Nom requis'] : [],
          email: !email ? ['Email requis'] : [],
          password: !password ? ['Mot de passe requis'] : []
        }
      });
    }

    // Lire la base de données
    const dbPath = path.join(__dirname, 'db.json');
    const db = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
    
    // Vérifier si l'email existe déjà
    const existingUser = db.users.find(u => u.email === email);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Un compte avec cet email existe déjà'
      });
    }

    // Créer le nouvel utilisateur
    const hashedPassword = bcrypt.hashSync(password, 10);
    const newUser = {
      id: db.users.length + 1,
      name,
      email,
      password: hashedPassword,
      role: 'user',
      avatar: null,
      created_at: new Date().toISOString()
    };

    db.users.push(newUser);
    
    // Sauvegarder dans le fichier
    fs.writeFileSync(dbPath, JSON.stringify(db, null, 2));

    // Générer les tokens
    const accessToken = jwt.sign(
      { id: newUser.id, email: newUser.email, role: newUser.role },
      SECRET_KEY,
      { expiresIn: '1h' }
    );

    const refreshToken = jwt.sign(
      { id: newUser.id },
      SECRET_KEY,
      { expiresIn: '7d' }
    );

    // Supprimer le mot de passe de la réponse
    const { password: _, ...userWithoutPassword } = newUser;

    res.status(201).json({
      success: true,
      message: 'Compte créé avec succès',
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        user: userWithoutPassword
      }
    });

  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

app.post('/auth/refresh', (req, res) => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      return res.status(400).json({
        success: false,
        message: 'Token de rafraîchissement requis'
      });
    }

    jwt.verify(refresh_token, SECRET_KEY, (err, decoded) => {
      if (err) {
        return res.status(401).json({
          success: false,
          message: 'Token de rafraîchissement invalide'
        });
      }

      // Générer un nouveau token d'accès
      const accessToken = jwt.sign(
        { id: decoded.id },
        SECRET_KEY,
        { expiresIn: '1h' }
      );

      const newRefreshToken = jwt.sign(
        { id: decoded.id },
        SECRET_KEY,
        { expiresIn: '7d' }
      );

      res.json({
        success: true,
        data: {
          access_token: accessToken,
          refresh_token: newRefreshToken
        }
      });
    });

  } catch (error) {
    console.error('Erreur lors du rafraîchissement:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur interne du serveur'
    });
  }
});

app.post('/auth/logout', (req, res) => {
  res.json({
    success: true,
    message: 'Déconnexion réussie'
  });
});

// Middleware d'authentification pour les routes protégées
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token d\'accès requis'
    });
  }

  jwt.verify(token, SECRET_KEY, (err, user) => {
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

// Route pour obtenir les informations de l'utilisateur connecté
app.get('/auth/me', authenticateToken, (req, res) => {
  const dbPath = path.join(__dirname, 'db.json');
  const db = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
  
  const user = db.users.find(u => u.id === req.user.id);
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'Utilisateur non trouvé'
    });
  }

  const { password, ...userWithoutPassword } = user;
  res.json({
    success: true,
    data: userWithoutPassword
  });
});

// Appliquer l'authentification aux routes CRUD
app.use('/customers*', authenticateToken);
app.use('/article*', authenticateToken);
app.use('/commande*', authenticateToken);
app.use('/devis*', authenticateToken);
app.use('/facture*', authenticateToken);
app.use('/marches*', authenticateToken);
app.use('/appels-offre*', authenticateToken);
app.use('/recouvrements*', authenticateToken);
app.use('/relances*', authenticateToken);

// Utiliser les routes par défaut de json-server
app.use(router);

// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`📖 API disponible sur: http://localhost:${PORT}`);
  console.log(`🔍 Route de santé: http://localhost:${PORT}/health`);
  console.log(`🔐 Endpoints d'authentification:`);
  console.log(`   POST http://localhost:${PORT}/auth/login`);
  console.log(`   POST http://localhost:${PORT}/auth/register`);
  console.log(`   POST http://localhost:${PORT}/auth/refresh`);
  console.log(`   POST http://localhost:${PORT}/auth/logout`);
  console.log(`\n📧 Comptes de test:`);
  console.log(`   admin@appgestion.com / password`);
  console.log(`   user@test.com / password`);
});