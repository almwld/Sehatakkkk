FROM node:20-alpine

WORKDIR /app

# Railway entrypoint for the isolated LiveKit token service.
COPY livekit-token-server/package*.json ./
RUN npm install --omit=dev --no-audit --no-fund
COPY livekit-token-server/server.js ./server.js

ENV NODE_ENV=production
EXPOSE 8080

CMD ["node", "server.js"]
