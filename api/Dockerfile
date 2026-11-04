FROM node:22-alpine
WORKDIR /app
COPY api/package.json api/package-lock.json ./
RUN npm ci --omit=dev
COPY api/server.js ./server.js
ENV PORT=3000
EXPOSE 3000
USER node
CMD ["node", "server.js"]
