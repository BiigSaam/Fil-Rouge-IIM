# 🚀 Guide de déploiement Serverless

## Architecture
```
Frontend React (S3) ←→ API Gateway ←→ Lambda ←→ DynamoDB
```

## Prérequis
- AWS CLI configuré
- Terraform installé
- Node.js installé (pour le frontend)

## Étapes de déploiement

### 1. Déployer l'infrastructure AWS (tout-en-un)
```bash
cd infra
terraform init
terraform plan
terraform apply
```

⚡ **Terraform gère maintenant automatiquement :**
- ✅ Création du package Lambda (plus de script build.sh !)
- ✅ Déploiement de la fonction
- ✅ Configuration de l'API Gateway
- ✅ Création des ressources S3 et DynamoDB

### 2. Récupérer les URLs de déploiement
Après le déploiement, Terraform affichera :
```
api_gateway_url = "https://YOUR_API_ID.execute-api.eu-west-1.amazonaws.com/prod"
s3_website_url = "http://YOUR_BUCKET.s3-website-eu-west-1.amazonaws.com"
```

### 3. Configurer le frontend
1. Créer un fichier `.env` dans `/frontend` :
```bash
REACT_APP_API_URL=https://YOUR_API_ID.execute-api.eu-west-1.amazonaws.com/prod
```

2. Ou modifier directement dans `App.tsx` :
```typescript
const API_BASE_URL = 'https://YOUR_ACTUAL_API_ID.execute-api.eu-west-1.amazonaws.com/prod';
```

### 4. Construire et déployer le frontend
```bash
cd frontend
npm run build

# Upload vers S3
aws s3 sync dist/ s3://YOUR_BUCKET_NAME --delete
```

### 5. Tester l'application
1. Ouvrir l'URL S3 dans le navigateur
2. Tester l'ajout/suppression de tâches

## Structure finale du projet
```
Fil-Rouge-IIM/
├── frontend/          # React app (déployé sur S3)
├── infra/            # Terraform (gère tout)
│   ├── main.tf       # Infrastructure complète
│   ├── lambda_function.js  # Code Lambda intégré
│   └── variables.tf  # Variables
├── backend/          # ❌ Express (non utilisé)
└── docker-compose.yml # ❌ Docker (non utilisé en prod)
```

## Avantages de cette nouvelle architecture
- 🎯 **Simplicité** : Un seul `terraform apply` déploie tout
- 💰 **Coût réduit** : Pay-per-use, pas de serveurs 24/7
- 🔧 **Maintenance minimale** : Serverless
- 📈 **Scalabilité automatique**
- 🛡️ **Sécurité AWS intégrée**

## Ce qui a été supprimé
- ❌ **Dossier `/lambda`** : Code intégré dans Terraform
- ❌ **Script `build.sh`** : Terraform gère le packaging
- ❌ **Dependencies externes** : Utilise les modules built-in (aws-sdk, crypto)
- ❌ **Backend Express** : Remplacé par Lambda
- ❌ **Docker en production** : Plus nécessaire

## Développement local
Pour tester en local, vous pouvez toujours utiliser :
```bash
docker-compose up frontend
# Le frontend pointera vers l'API Gateway en prod
```

## Notes importantes
- Le code Lambda est maintenant dans `/infra/lambda_function.js`
- DynamoDB est activé par défaut
- Plus besoin de gérer les dépendances npm pour Lambda
- L'UUID est généré avec `crypto.randomUUID()` (built-in) 