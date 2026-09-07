FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev --no-audit --no-fund
COPY server.js ./server.js
COPY index.js ./index.js
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "index.js"]
