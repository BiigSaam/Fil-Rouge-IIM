/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string
  readonly REACT_APP_API_URL: string
  // Plus de variables d'environnement si nécessaire...
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
