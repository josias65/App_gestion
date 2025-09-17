const db = require('../database');

async function enhanceDatabase() {
  try {
    console.log('🚀 Amélioration de la base de données pour les appels d\'offre...');
    
    // Initialiser la base de données d'abord
    await db.init();

    // Ajouter des colonnes à la table appels_offre
    try {
      await db.run('ALTER TABLE appels_offre ADD COLUMN category TEXT');
      console.log('✅ Colonne category ajoutée');
    } catch (e) {
      console.log('ℹ️  Colonne category déjà présente');
    }

    try {
      await db.run('ALTER TABLE appels_offre ADD COLUMN location TEXT');
      console.log('✅ Colonne location ajoutée');
    } catch (e) {
      console.log('ℹ️  Colonne location déjà présente');
    }

    try {
      await db.run('ALTER TABLE appels_offre ADD COLUMN urgency TEXT DEFAULT "normale"');
      console.log('✅ Colonne urgency ajoutée');
    } catch (e) {
      console.log('ℹ️  Colonne urgency déjà présente');
    }

    try {
      await db.run('ALTER TABLE appels_offre ADD COLUMN created_by INTEGER');
      console.log('✅ Colonne created_by ajoutée');
    } catch (e) {
      console.log('ℹ️  Colonne created_by déjà présente');
    }

    try {
      await db.run('ALTER TABLE appels_offre ADD COLUMN favorite INTEGER DEFAULT 0');
      console.log('✅ Colonne favorite ajoutée');
    } catch (e) {
      console.log('ℹ️  Colonne favorite déjà présente');
    }

    // Table pour les documents des appels d'offre
    await db.run(`
      CREATE TABLE IF NOT EXISTS appel_offre_documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appel_offre_id INTEGER NOT NULL,
        filename TEXT NOT NULL,
        original_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER,
        file_type TEXT,
        uploaded_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (appel_offre_id) REFERENCES appels_offre (id),
        FOREIGN KEY (uploaded_by) REFERENCES users (id)
      )
    `);
    console.log('✅ Table appel_offre_documents créée');

    // Table pour les commentaires des appels d'offre
    await db.run(`
      CREATE TABLE IF NOT EXISTS appel_offre_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appel_offre_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (appel_offre_id) REFERENCES appels_offre (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `);
    console.log('✅ Table appel_offre_comments créée');

    // Table pour l'historique des appels d'offre
    await db.run(`
      CREATE TABLE IF NOT EXISTS appel_offre_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appel_offre_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        user_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (appel_offre_id) REFERENCES appels_offre (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `);
    console.log('✅ Table appel_offre_history créée');

    // Table pour les critères d'évaluation
    await db.run(`
      CREATE TABLE IF NOT EXISTS appel_offre_criteria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appel_offre_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        weight INTEGER DEFAULT 10,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (appel_offre_id) REFERENCES appels_offre (id)
      )
    `);
    console.log('✅ Table appel_offre_criteria créée');

    // Ajouter des colonnes à la table soumissions
    try {
      await db.run('ALTER TABLE soumissions ADD COLUMN delivery_time TEXT');
      console.log('✅ Colonne delivery_time ajoutée aux soumissions');
    } catch (e) {
      console.log('ℹ️  Colonne delivery_time déjà présente');
    }

    try {
      await db.run('ALTER TABLE soumissions ADD COLUMN warranty TEXT');
      console.log('✅ Colonne warranty ajoutée aux soumissions');
    } catch (e) {
      console.log('ℹ️  Colonne warranty déjà présente');
    }

    try {
      await db.run('ALTER TABLE soumissions ADD COLUMN total_score REAL');
      console.log('✅ Colonne total_score ajoutée aux soumissions');
    } catch (e) {
      console.log('ℹ️  Colonne total_score déjà présente');
    }

    try {
      await db.run('ALTER TABLE soumissions ADD COLUMN evaluation_comments TEXT');
      console.log('✅ Colonne evaluation_comments ajoutée aux soumissions');
    } catch (e) {
      console.log('ℹ️  Colonne evaluation_comments déjà présente');
    }

    try {
      await db.run('ALTER TABLE soumissions ADD COLUMN evaluated_by INTEGER');
      console.log('✅ Colonne evaluated_by ajoutée aux soumissions');
    } catch (e) {
      console.log('ℹ️  Colonne evaluated_by déjà présente');
    }

    try {
      await db.run('ALTER TABLE soumissions ADD COLUMN evaluated_at DATETIME');
      console.log('✅ Colonne evaluated_at ajoutée aux soumissions');
    } catch (e) {
      console.log('ℹ️  Colonne evaluated_at déjà présente');
    }

    // Table pour les scores par critère
    await db.run(`
      CREATE TABLE IF NOT EXISTS soumission_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        soumission_id INTEGER NOT NULL,
        criteria_id INTEGER NOT NULL,
        score REAL NOT NULL,
        comments TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (soumission_id) REFERENCES soumissions (id),
        FOREIGN KEY (criteria_id) REFERENCES appel_offre_criteria (id)
      )
    `);
    console.log('✅ Table soumission_scores créée');

    // Table pour les notifications
    await db.run(`
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        related_id INTEGER,
        related_type TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    `);
    console.log('✅ Table notifications créée');

    // Table pour les favoris des utilisateurs
    await db.run(`
      CREATE TABLE IF NOT EXISTS user_favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        appel_offre_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (appel_offre_id) REFERENCES appels_offre (id),
        UNIQUE(user_id, appel_offre_id)
      )
    `);
    console.log('✅ Table user_favorites créée');

    // Insérer des critères par défaut pour les appels d'offre existants
    const existingAppelsOffre = await db.all('SELECT id FROM appels_offre');
    
    for (const appel of existingAppelsOffre) {
      // Vérifier si des critères existent déjà
      const existingCriteria = await db.get(
        'SELECT COUNT(*) as count FROM appel_offre_criteria WHERE appel_offre_id = ?',
        [appel.id]
      );

      if (existingCriteria.count === 0) {
        // Ajouter des critères par défaut
        const defaultCriteria = [
          { name: 'Prix', description: 'Compétitivité du prix proposé', weight: 40 },
          { name: 'Qualité technique', description: 'Qualité et pertinence de la solution technique', weight: 30 },
          { name: 'Expérience', description: 'Expérience du soumissionnaire', weight: 20 },
          { name: 'Délai de livraison', description: 'Respect des délais proposés', weight: 10 }
        ];

        for (const critere of defaultCriteria) {
          await db.run(
            'INSERT INTO appel_offre_criteria (appel_offre_id, name, description, weight) VALUES (?, ?, ?, ?)',
            [appel.id, critere.name, critere.description, critere.weight]
          );
        }
      }
    }

    console.log('✅ Critères par défaut ajoutés aux appels d\'offre existants');

    // Créer le dossier uploads s'il n'existe pas
    const fs = require('fs');
    const path = require('path');
    const uploadDir = path.join(__dirname, '../uploads');
    
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
      fs.mkdirSync(path.join(uploadDir, 'appels-offre'), { recursive: true });
      console.log('✅ Dossier uploads créé');
    }

    console.log('🎉 Base de données améliorée avec succès !');
    console.log('');
    console.log('📋 Nouvelles fonctionnalités disponibles :');
    console.log('   ✅ Gestion des documents');
    console.log('   ✅ Système de commentaires');
    console.log('   ✅ Historique des modifications');
    console.log('   ✅ Critères d\'évaluation');
    console.log('   ✅ Notifications');
    console.log('   ✅ Favoris utilisateur');
    console.log('   ✅ Analytics avancés');
    console.log('   ✅ Export des données');

  } catch (error) {
    console.error('❌ Erreur lors de l\'amélioration de la base de données:', error);
    throw error;
  }
}

// Exécuter si appelé directement
if (require.main === module) {
  enhanceDatabase()
    .then(() => {
      console.log('✅ Amélioration terminée avec succès');
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ Erreur:', error);
      process.exit(1);
    });
}

module.exports = enhanceDatabase;
