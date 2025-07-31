# 📝 Todo List Serverless - Fil Rouge IIM

> **Architecture serverless complète** utilisant React, AWS Lambda, API Gateway, DynamoDB et Terraform

![Architecture](https://img.shields.io/badge/Architecture-Serverless-orange)
![AWS](https://img.shields.io/badge/AWS-Lambda%20%7C%20API%20Gateway%20%7C%20DynamoDB%20%7C%20S3-yellow)
![Frontend](https://img.shields.io/badge/Frontend-React%20%7C%20TypeScript%20%7C%20Vite-blue)
![IaC](https://img.shields.io/badge/IaC-Terraform-purple)

## 🎯 Description du projet

Cette application **Todo List** démontre une architecture serverless moderne et scalable. Elle permet de créer, lister et supprimer des tâches avec une persistance complète des données.

### ✨ Fonctionnalités
- ✅ **Créer** des tâches
- ✅ **Lister** toutes les tâches
- ✅ **Supprimer** des tâches
- ✅ **Interface responsive** et moderne
- ✅ **Persistance des données** en temps réel
- ✅ **CORS configuré** pour les appels cross-origin

## 🏗️ Architecture

```
👤 Utilisateur
    ↓
🌐 Frontend React (S3 + Docker)
    ↓
🚪 API Gateway (REST API)
    ↓
⚡ AWS Lambda (Node.js)
    ↓
💾 DynamoDB (NoSQL)
```

### 🧩 Composants

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| **Frontend** | React + TypeScript + Vite | Interface utilisateur |
| **API Gateway** | AWS API Gateway | Routage et gestion des requêtes |
| **Backend** | AWS Lambda (Node.js 16.x) | Logique métier serverless |
| **Base de données** | AWS DynamoDB | Stockage NoSQL scalable |
| **Infrastructure** | Terraform | Infrastructure as Code |
| **Hébergement** | AWS S3 + Docker | Déploiement statique + dev local |

## 🛠️ Technologies utilisées

### Frontend
- **React 19** - Framework JavaScript moderne
- **TypeScript** - Typage statique
- **Vite** - Build tool ultra-rapide
- **Docker** - Conteneurisation pour le développement

### Backend
- **AWS Lambda** - Compute serverless
- **Node.js 16.x** - Runtime JavaScript
- **AWS SDK** - Interaction avec les services AWS

### Infrastructure
- **Terraform** - Infrastructure as Code
- **AWS S3** - Hébergement web statique
- **AWS API Gateway** - API REST managée
- **AWS DynamoDB** - Base de données NoSQL
- **AWS IAM** - Gestion des permissions

## 📋 Prérequis

- **Node.js** 16.x ou supérieur
- **npm** ou **yarn**
- **Docker** et **Docker Compose**
- **AWS CLI** configuré avec vos credentials
- **Terraform** >= 1.0

## 🚀 Installation et déploiement

### 1. Cloner le projet
```bash
git clone https://github.com/votre-username/Fil-Rouge-IIM.git
cd Fil-Rouge-IIM
```

### 2. Déployer l'infrastructure AWS
```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 3. Récupérer l'URL de l'API
```bash
terraform output api_gateway_url
# Output: https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod
```

### 4. Configurer le frontend
```bash
cd ../frontend
echo "VITE_API_URL=https://VOTRE-API-ID.execute-api.eu-west-1.amazonaws.com/prod" > .env
```

### 5. Développement local avec Docker
```bash
# À la racine du projet
docker-compose up --build
```
🌐 Frontend accessible sur : http://localhost:5173

### 6. Déploiement en production (S3)
```bash
cd frontend
npm install
npm run build
aws s3 sync dist/ s3://VOTRE-BUCKET-NAME --delete
```

## 🌐 URLs d'accès

| Environnement | URL | Description |
|---------------|-----|-------------|
| **Développement** | http://localhost:5173 | Frontend local avec Docker |
| **Production** | http://fil-rouge-samad-bucket-v2-20250122.s3-website-eu-west-1.amazonaws.com | Site statique hébergé sur S3 |
| **API** | https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod | API REST serverless |

## 📁 Structure du projet

```
Fil-Rouge-IIM/
├── 📂 frontend/                # Application React
│   ├── 📂 src/
│   │   ├── App.tsx             # Composant principal
│   │   └── main.tsx            # Point d'entrée
│   ├── 📄 package.json         # Dépendances Node.js
│   ├── 📄 Dockerfile           # Configuration Docker
│   └── 📄 .env                 # Variables d'environnement
│
├── 📂 infra/                   # Infrastructure Terraform
│   ├── 📄 main.tf              # Configuration principale
│   ├── 📄 variables.tf         # Variables Terraform
│   ├── 📄 providers.tf         # Providers AWS
│   └── 📄 lambda_function.js   # Code de la fonction Lambda
│
├── 📄 docker-compose.yml       # Configuration Docker Compose
├── 📄 .gitignore              # Fichiers ignorés par Git
└── 📄 README.md               # Documentation (ce fichier)
```

## 🔌 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/tasks` | Récupérer toutes les tâches |
| `POST` | `/tasks` | Créer une nouvelle tâche |
| `DELETE` | `/tasks/{id}` | Supprimer une tâche par ID |
| `OPTIONS` | `/tasks` | CORS preflight |

### Exemples d'utilisation

**Créer une tâche :**
```bash
curl -X POST https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Ma nouvelle tâche"}'
```

**Lister les tâches :**
```bash
curl https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod/tasks
```

**Supprimer une tâche :**
```bash
curl -X DELETE https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod/tasks/TASK-ID
```

## 🔧 Configuration

### Variables d'environnement

**Frontend (.env) :**
```env
VITE_API_URL=https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod
```

**Terraform (variables.tf) :**
- `dynamodb_table_name` : Nom de la table DynamoDB
- `bucket_name` : Nom du bucket S3
- `lambda_function_name` : Nom de la fonction Lambda

## 📊 Monitoring et logs

### Logs Lambda
```bash
# Suivre les logs en temps réel
aws logs tail /aws/lambda/tasks-api --follow

# Voir les logs récents
aws logs tail /aws/lambda/tasks-api --since 1h
```

### Métriques CloudWatch
- Invocations Lambda
- Erreurs et timeouts
- Utilisation DynamoDB
- Requêtes API Gateway

## 🔒 Sécurité

- **IAM Roles** : Permissions minimales pour Lambda
- **CORS** : Configuration cross-origin sécurisée
- **HTTPS** : Chiffrement en transit via API Gateway
- **Encryption at rest** : DynamoDB chiffré par défaut

## 💰 Coûts AWS

Cette architecture utilise principalement des services avec **free tier** :
- **Lambda** : 1M invocations/mois gratuites
- **API Gateway** : 1M requêtes/mois gratuites
- **DynamoDB** : 25GB stockage gratuit
- **S3** : 5GB stockage gratuit

## 🤝 Contribution

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. **Commit** vos changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. **Push** vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. **Créer** une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Auteurs

- **Votre Nom** - *Développement initial* - [VotreGitHub](https://github.com/votre-username)

## 🙏 Remerciements

- **AWS** pour les services cloud
- **Terraform** pour l'Infrastructure as Code
- **React Team** pour le framework frontend
- **Vite Team** pour l'outillage de build

---

⭐ **N'hésitez pas à star le projet si il vous a été utile !**

📧 **Questions ?** Créez une issue ou contactez-nous ! 