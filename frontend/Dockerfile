FROM node:20-alpine

WORKDIR /app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier tout le code source
COPY . .

# Exposer le port 5173
EXPOSE 5173

# Variables d'environnement par défaut (peuvent être surchargées par docker-compose)
ENV REACT_APP_API_URL=https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod
ENV VITE_API_URL=https://dwg7ep529i.execute-api.eu-west-1.amazonaws.com/prod

# Commande pour démarrer le serveur de développement
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
