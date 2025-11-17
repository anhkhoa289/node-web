# Multi-stage build for optimized Node.js image

# Stage 1: Dependencies
FROM node:18-alpine AS deps
WORKDIR /app

# Install yarn if not available (should be included in node:18-alpine)
RUN corepack enable && corepack prepare yarn@stable --activate

# Copy package files
COPY package.json yarn.lock* ./

# Install dependencies with yarn
RUN yarn install --frozen-lockfile --production

# Stage 2: Production image
FROM node:18-alpine AS runner
WORKDIR /app

# Install yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY src ./src
COPY package.json ./

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejs

# Set ownership
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["yarn", "start"]
