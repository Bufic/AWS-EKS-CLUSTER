# Stage 1: Build the React application
FROM node:18-alpine as build

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json into the working directory
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React app
RUN npm run build

# Stage 2: Serve the React app with NGINX
FROM nginx:stable-alpine

# Copy the built React app from the previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy the custom nginx.conf into the container
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the port on which NGINX runs
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
