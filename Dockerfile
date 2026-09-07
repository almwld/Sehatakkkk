FROM node:20-alpine

WORKDIR /app

COPY livekit-token-server/package*.json ./
RUN npm install --omit=dev --no-audit --no-fund

COPY livekit-token-server/server.js ./server.js
COPY livekit-token-server/index.js ./index.js

ENV NODE_ENV=production
EXPOSE 8080

CMD ["node", "index.js"]
