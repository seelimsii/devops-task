# Stage 1: Use a lightweight official Node.js image
FROM node:18-alpine AS base

WORKDIR /app

# --- FIX IS HERE ---
# Copy package files from the 'src' directory
COPY src/package*.json ./

# Run npm install
RUN npm install --cache .npm-cache

# --- FIX IS HERE ---
# Copy the rest of the application code from the 'src' directory
COPY src/ .

# Production stage
FROM base AS production
ENV NODE_ENV=production

# Expose the port the app runs on
EXPOSE 3000

# --- FIX IS HERE ---
# Update the command to run the app from the root of the WORKDIR
CMD ["node", "app.js"]
