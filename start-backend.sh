#!/bin/bash

echo "🚀 Démarrage du backend AppGestion..."
echo

# Vérifier si Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé. Veuillez installer Node.js depuis https://nodejs.org/"
    exit 1
fi

# Aller dans le dossier backend
cd backend

# Vérifier si les dépendances sont installées
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de l'installation des dépendances"
        exit 1
    fi
fi

# Initialiser la base de données si elle n'existe pas
if [ ! -f "database.sqlite" ]; then
    echo "🗄️ Initialisation de la base de données..."
    npm run init-db
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de l'initialisation de la base de données"
        exit 1
    fi
fi

# Démarrer le serveur
echo "🌐 Démarrage du serveur..."
echo "📱 Accessible depuis Flutter sur: http://10.0.2.2:8000"
echo "🌐 Accessible localement sur: http://localhost:8000"
echo
echo "👤 Utilisateurs par défaut:"
echo "   - Admin: admin@neo.com / admin123"
echo "   - Test: test@example.com / password123"
echo
echo "Appuyez sur Ctrl+C pour arrêter le serveur"
echo

npm start
