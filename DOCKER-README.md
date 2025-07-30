# 🐳 Configuration Docker pour l'architecture Serverless

## 🔄 Architecture mise à jour

**AVANT** (Architecture monolithique) :
```
Frontend (Docker) ←→ Backend (Docker) ←→ Base de données locale
```

**APRÈS** (Architecture serverless) :
```
Frontend (Docker) ←→ API Gateway ←→ Lambda ←→ DynamoDB (AWS)
```

## 🚀 Comment utiliser Docker maintenant

### 1. Démarrer l'application
```bash
docker-compose up --build
```

### 2. Accéder à l'application
- **Frontend** : http://localhost:5173
- **API** : https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod (AWS)

## ⚙️ Configuration

### Variables d'environnement configurées :
- `REACT_APP_API_URL` : URL de l'API Gateway AWS
- `VITE_API_URL` : Variable Vite pour l'API Gateway

### Changements apportés :
1. ✅ **Backend Docker supprimé** : Remplacé par Lambda
2. ✅ **Variables d'environnement ajoutées** : Configuration API Gateway
3. ✅ **Dépendances supprimées** : Plus de depends_on backend
4. ✅ **Configuration réseau simplifiée** : Connexion directe à AWS

## 🔧 Modes de développement

### Mode 1 : Docker (Actuel)
```bash
docker-compose up --build
# Frontend : http://localhost:5173
# Backend : AWS Lambda (prod)
```

### Mode 2 : Local sans Docker
```bash
cd frontend
npm install
npm run dev
# Frontend : http://localhost:5173
# Backend : AWS Lambda (prod)
```

### Mode 3 : Production S3
```bash
cd frontend
npm run build
aws s3 sync dist/ s3://fil-rouge-samad-bucket-v2-20250122
# Frontend : http://fil-rouge-samad-bucket-v2-20250122.s3-website-eu-west-1.amazonaws.com
# Backend : AWS Lambda (prod)
```

## 🎯 Avantages de cette configuration

- ✅ **Cohérence** : Même API en dev et prod
- ✅ **Simplicité** : Plus de gestion de base de données locale
- ✅ **Réalisme** : Environnement de dev proche de la prod
- ✅ **Performance** : API optimisée AWS

## 🔗 URLs importantes

- **API Gateway** : https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod
- **Frontend local** : http://localhost:5173
- **Frontend prod S3** : http://fil-rouge-samad-bucket-v2-20250122.s3-website-eu-west-1.amazonaws.com

## 📝 Notes

- L'API AWS doit être déployée AVANT d'utiliser Docker
- Les données sont partagées entre tous les développeurs (DynamoDB commune)
- Pour des tests isolés, utilisez le mode développement local avec API mock 