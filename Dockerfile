# Build stage
FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app
COPY --from=builder /app/build ./build
COPY --from=builder /app/server.js .
COPY --from=builder /app/package*.json ./

RUN npm install --production

EXPOSE 5000

CMD ["npm", "server.js"] 