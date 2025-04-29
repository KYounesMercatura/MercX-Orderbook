import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath, URL } from 'url';
import environment from 'vite-plugin-environment';
import { defineConfig } from 'vite';

// 🧠 Load canister IDs (for backend calls)
let canisterIds = {};
try {
  canisterIds = JSON.parse(fs.readFileSync('../.dfx/local/canister_ids.json'));
} catch (e) {
  console.warn('⚠️ Cannot read canister_ids.json. Did you run dfx deploy?');
}

// Pick correct backend ID
const backendCanisterId = canisterIds.backend?.local ?? "";

export default defineConfig({
  base: './',
  plugins: [
    environment('all', { prefix: 'CANISTER_' }),
    environment('all', { prefix: 'DFX_' })
  ],
  envDir: '../',
  define: {
    'import.meta.env.VITE_CANISTER_ID_backend': JSON.stringify(backendCanisterId),
    'process.env': process.env
  },
  resolve: {
    alias: [
      {
        find: 'declarations',
        replacement: fileURLToPath(new URL('../src/declarations', import.meta.url))
      }
    ]
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:4943',
        changeOrigin: true
      }
    },
    host: '127.0.0.1'
  },
  build: {
    rollupOptions: {
      input: {
        main: fileURLToPath(new URL('./index.html', import.meta.url))
        // Add more HTML pages here if needed later
      }
    }
  }
});
