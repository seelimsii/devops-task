# Stage 1: Use a lightweight official Node.js image
FROM node:18-alpine AS base

WORKDIR /app

# Copy package files and install dependencies
# This leverages Docker's layer caching
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY src/ .

# Stage 2: Run tests


# Stage 3: Production build
FROM base AS production
ENV NODE_ENV=production

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application

CMD ["node", "src/app.js"]

