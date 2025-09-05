const db = require('./database');

async function initDatabase() {
  try {
    console.log('🚀 Initialisation de la base de données...');
    
    await db.init();
    
    console.log('✅ Base de données initialisée avec succès !');
    console.log('');
    console.log('📋 Utilisateurs créés par défaut :');
    console.log('   - Admin: admin@neo.com / admin123');
    console.log('   - Test: test@example.com / password123');
    console.log('');
    console.log('🌐 Vous pouvez maintenant démarrer le serveur avec :');
    console.log('   npm start');
    console.log('   ou');
    console.log('   npm run dev (pour le développement)');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors de l\'initialisation de la base de données:', error);
    process.exit(1);
  }
}

initDatabase();
