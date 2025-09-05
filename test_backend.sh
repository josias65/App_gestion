#!/bin/bash

echo "🧪 Test du backend AppGestion..."

# Fonction pour tester un endpoint
test_endpoint() {
    local url=$1
    local method=${2:-GET}
    local data=${3:-}
    
    echo -n "Testing $method $url... "
    
    if [ -n "$data" ]; then
        response=$(curl -s -X "$method" -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null)
    else
        response=$(curl -s -X "$method" "$url" 2>/dev/null)
    fi
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "✅ OK"
        echo "   Response: $response"
    else
        echo "❌ ÉCHEC"
    fi
    echo ""
}

# Attendre que le serveur démarre
echo "⏳ Attente du démarrage du serveur..."
sleep 5

# Tester les endpoints
BASE_URL="http://localhost:8000"

test_endpoint "$BASE_URL/health"
test_endpoint "$BASE_URL/auth/login" "POST" '{"email":"admin@appgestion.com","password":"password"}'
test_endpoint "$BASE_URL/customers"

echo "🏁 Tests terminés!"