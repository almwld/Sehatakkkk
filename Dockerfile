FROM node:20-alpine

WORKDIR /app

# The repository is a Flutter monorepo. Railway must run only the isolated
# LiveKit token service instead of trying to start a root index.js.
COPY livekit-token-server/package*.json ./
RUN npm install --omit=dev --no-audit --no-fund
COPY livekit-token-server/server.js ./server.js

ENV NODE_ENV=production
EXPOSE 8080

CMD ["node", "server.js"]
