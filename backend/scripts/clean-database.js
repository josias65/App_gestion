const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Chemin vers la base de données
const dbPath = path.join(__dirname, '..', 'database.sqlite');

// Créer une connexion à la base de données
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Erreur lors de la connexion à la base de données:', err.message);
    process.exit(1);
  }
  console.log('✅ Connexion à la base de données établie');
});

async function cleanDatabase() {
  try {
    console.log('🧹 Nettoyage de la base de données...');

    // Supprimer toutes les données des tables principales
    const tablesToClean = [
      'appels_offre',
      'customers', 
      'orders',
      'invoices',
      'devis',
      'products',
      'stock',
      'recouvrements',
      'relances',
      'soumission_scores',
      'notifications',
      'user_favorites',
      'comments',
      'documents',
      'evaluation_criteria',
      'audit_logs'
    ];

    for (const table of tablesToClean) {
      try {
        await new Promise((resolve, reject) => {
          db.run(`DELETE FROM ${table}`, (err) => {
            if (err) {
              // Ignorer les erreurs si la table n'existe pas
              if (err.message.includes('no such table')) {
                console.log(`⚠️  Table ${table} n'existe pas encore`);
                resolve();
              } else {
                reject(err);
              }
            } else {
              console.log(`✅ Données supprimées de la table ${table}`);
              resolve();
            }
          });
        });
      } catch (error) {
        console.log(`⚠️  Erreur lors du nettoyage de ${table}:`, error.message);
      }
    }

    // Réinitialiser les compteurs auto-increment
    await new Promise((resolve, reject) => {
      db.run("DELETE FROM sqlite_sequence WHERE name IN ('appels_offre', 'customers', 'orders', 'invoices', 'devis', 'products', 'stock', 'recouvrements', 'relances')", (err) => {
        if (err) {
          reject(err);
        } else {
          console.log('✅ Compteurs auto-increment réinitialisés');
          resolve();
        }
      });
    });

    console.log('🎉 Base de données nettoyée avec succès !');
    console.log('📝 Toutes les données par défaut ont été supprimées');
    console.log('💡 Votre application est maintenant prête pour des données réelles');

  } catch (error) {
    console.error('❌ Erreur lors du nettoyage de la base de données:', error);
  } finally {
    // Fermer la connexion à la base de données
    db.close((err) => {
      if (err) {
        console.error('❌ Erreur lors de la fermeture de la base de données:', err.message);
      } else {
        console.log('✅ Connexion à la base de données fermée');
      }
    });
  }
}

// Exécuter le nettoyage
cleanDatabase();
