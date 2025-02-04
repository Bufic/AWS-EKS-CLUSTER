# Use the smallest Node.js image (Alpine)
FROM node:16-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application code
COPY . .

# Expose the application port
EXPOSE 3001

# Start the application
CMD ["node", "/app/server.js"]
