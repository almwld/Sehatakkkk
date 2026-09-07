FROM node:18-alpine

WORKDIR /app

# Railway deploys from the repository root. The actual token service lives
# under livekit-token-server/, so build that service explicitly instead of
# letting Nixpacks guess a root index.js entrypoint.
COPY livekit-token-server/package*.json ./
RUN npm install --omit=dev
COPY livekit-token-server/server.js ./server.js

ENV NODE_ENV=production
EXPOSE 8080

CMD ["node", "server.js"]
