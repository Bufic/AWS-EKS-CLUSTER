# (Stage 1)

# EKS Cluster Deployment Using Terraform

This project deploys an Amazon Elastic Kubernetes Service (EKS) cluster on AWS using Terraform. The configuration includes creating an EKS cluster, provisioning worker nodes, and enabling connectivity using the AWS and Kubernetes providers.

## Project Structure

```
eks-terraform/
├── main.tf # EKS module configuration
├── variables.tf # Input variables
├── outputs.tf # Output values
├── provider.tf # Provider configuration
├── terraform.tfvars # Variable values
```

## Prerequisites

Terraform: Install Terraform.

AWS CLI: Install and configure the AWS CLI with proper credentials.

kubectl: Install kubectl.

AWS Account: Ensure you have an active AWS account.

### Features

Creates an EKS cluster in the default VPC.

Provisions worker nodes using managed node groups.

Supports configuration of cluster size, instance types, and scaling.

Outputs cluster and node group details.

### Usage

### 1. Clone the Repository

```
git clone <repository-url>
cd eks-terraform
```

### 2. Initialize Terraform

```
terraform init
```

### 3. Configure Variables

```
Update terraform.tfvars with your desired values:
```

```
aws_region = "us-east-2"
cluster_name = "my-eks-cluster"
vpc_id = "vpc-xxxxxxxx"
subnet_ids = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
```

### 4. Validate Configuration

```
terraform validate
```

### 5. Plan Deployment

```
terraform plan
```

### 6. Deploy Resources

```
terraform apply
```

### 7. Update Kubeconfig

To interact with the cluster using kubectl, update your kubeconfig:

```
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
```

### 8. Verify Cluster

```
kubectl get nodes
```

### Inputs

`aws_region:` The AWS region for the EKS cluster. (Type: string, Default: us-east-2)

`cluster_name:` The name of the EKS cluster. (Type: string, Default: my-eks-cluster)

`node_instance_type:` EC2 instance type for worker nodes. (Type: string, Default: t3.medium)

`desired_capacity:` Desired number of worker nodes. (Type: number, Default: 1)

`max_capacity:` Maximum number of worker nodes. (Type: number, Default: 2)

`min_capacity:` Minimum number of worker nodes. (Type: number, Default: 1)

`vpc_id:` The ID of the default VPC. (Type: string, Default: null)

`subnet_ids:` A list of subnet IDs in the default VPC. (Type: list(string), Default: [])

### Outputs

`cluster_id:` The unique identifier for the EKS cluster.

`cluster_endpoint:` The API server endpoint for the EKS cluster.

`cluster_security_group_id:` The security group ID associated with the EKS cluster.

`node_group_role_arn:` The ARN of the IAM role for the worker nodes.

### Cleanup

To destroy all resources created by this project:

```
terraform destroy
```

### References

Terraform AWS Provider

Terraform EKS Module

Amazon EKS Documentation

# (Stage 2) Test application locally.

Got an application in a zip file. The goal is to make sure the application is running smoothly, so i have to run it on my local machine before building into a docker image.

### Step 1

1. Downloaded and unzipped the application. The extracted contents indicate that the application is a full-stack project with separate frontend and backend directories. Also stores it's data in a MYSQL database.

2. ### Install MySQL: Make sure MySQL is installed and running on your local machine.
   `sudo apt-get install mysql-server`
   Log in to MySQL:
   `mysql -u root -p`
   Create a New Database: Create the dreamvacations database.
   `CREATE DATABASE dreamvacations;`
   Create a New User: Create a new MySQL user with a password and grant privileges to the dreamvacations database

```
     CREATE USER 'dream_user'@'localhost' IDENTIFIED BY 'yourpassword';
     GRANT ALL PRIVILEGES ON dreamvacations.* TO 'dream_user'@'localhost';
     FLUSH PRIVILEGES;
```

Verify Database and User: Confirm that the user and database were created successfully.

```
SHOW DATABASES;
SHOW GRANTS FOR 'dream_user'@'localhost';
```

### Step 2: Set Up the Backend

Initialize the Backend Project: Initialize a Node.js project.

```
cd backend
npm init -y
```

Install Dependencies: Install the necessary dependencies for the backend.

```
npm install
```

#### server.js: Set up the server to connect to the MySQL database

Add your MYSQL Database details to the backend .env file.
PS: Don't tamper with the DATABASE_URL, PORT and COUNTRIES_API_BASE_URL

```
DATABASE_URL=mysql://localhost:3306/dreamvacations
PORT=3001
COUNTRIES_API_BASE_URL=https://restcountries.com/v3.1

DB_HOST=localhost
DB_USER=dream_user
DB_PWD=yourpassword
DB_DATABASE=dream_vacation
DB_PORT=3306
```

Update this section of the Server.js with your MYSQL database details (Using the variables in .env).

```
// MySQL Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PWD,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
});
```

### Run the Backend: Start the backend server:

```
npm start
```

## Step 3: Set Up the Frontend

#### Navigate to frontend: Change directory to the frontend directory:

```
cd frontend
```

Install dependencies: Install Axios for making HTTP requests:

```
npm install
```

You have the `REACT_APP_API_URL=http://localhost:3001` in the frontend .env file. This is the value of the variable, which is the URL of your backend API (in this case, it's pointing to your backend server running locally on port 3001). This is how the frontend communicates with the backend.

In a production setup, this URL might be the address of your deployed backend API.

This is how it is used in the App.js of your frontend application

```
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';
```

#### Run the Frontend: Start the React frontend:

```
npm start
```

## Stage 3 (Docker)

### Build Docker Images

### Step 1.

Created a Dockerfile in the backend directory: Using a Node:18 alpine image, i created a docker file that copies the JSON packages and copies the application source code into the docker image and exposes port 3001. And the using `CMD ["node", "server.js"]` to start the backend application, as seen in the configuration below.

```
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
```

And then i updated the .env file in the backend directory with my credentials to connect to MYSQL. This is to prevent hardcoding so as to avoid exposing your credentials to access your MYSQL database.

```
DB_HOST=mysqldb
MYSQL_ROOT_PASSWORD=yourpassword
DB_USER=root
DB_PWD=yourpassword
DB_DATABASE=dream_vacation
DB_PORT=3306
```

### Step 2.

Create a Dockerfile in the frontend directory: This Dockerfile builds the React application and configures NGINX to serve the frontend and act as a reverse proxy for the backend.

```
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
```

PS: I updated the package.json and edited

```
"start": "react-scripts start",
"build": "react-scripts",

to

"start": "react-scripts start --host 0.0.0.0",
"build": "react-scripts --openssl-legacy-provider build",
```

What it Does:
`react-scripts start`: This command starts the development server for your React application. It:

Serves the React app locally.
Watches for file changes and refreshes the browser automatically (hot reloading).
Provides detailed error overlays in the browser.
--host 0.0.0.0: This flag tells the development server to listen on all network interfaces, not just localhost.

By default, react-scripts start serves the app on localhost (127.0.0.1), making it accessible only on your own machine.
With --host 0.0.0.0, the app becomes accessible to other devices on the same network by using your machine's local IP address.

`react-scripts build`: This command creates an optimized production build of your React app. It:

Minifies the JavaScript and CSS files.
Optimizes assets (e.g., images).
Generates a build folder containing all the static files (e.g., index.html, main.js) that can be deployed to a web server.
--openssl-legacy-provider: This flag forces the use of the legacy OpenSSL provider for compatibility with older environments or libraries. It is added due to compatibility issues between react-scripts and Node.js versions 17+.

### NGINX Configuration

Remember we built our frontend application and copied it into an Nginx.conf file in our Docker file.
This NGINX config (nginx.conf) serves the React app and proxies /api requests to the backend:

Using NGINX to serve your React frontend in production is essential because it:

1. Efficiently Serves Static Files: Optimized for delivering HTML, CSS, and JS files.
2. Improves Performance: Provides compression, caching, and HTTP/2 support for faster loading.
3. Handles SPA Routing: Redirects all routes to index.html for proper client-side rendering.
4. Enhances Security: Manages SSL/TLS and protects against malicious traffic.
5. Supports Scalability: Handles large traffic and integrates well in containerized environments like Docker.
6. Acts as a Reverse Proxy: Optionally forwards API requests to your backend.

It’s lightweight, fast, and designed for production, making it ideal over the React development server.

```
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    #include /etc/nginx/nginx.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;

        #health check
        location /health {
        default_type text/html;
        return 200 "<!DOCTYPE html><p>Web Tier Health Check</p>\n";
        }

        #react app and front end files
        location / {
        root    /usr/share/nginx/html;
        index index.html index.htm
        try_files $uri /index.html;
        }

        #proxy for internal lb
        location /api/{
                proxy_pass http://backend:3001/;
        }


    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}
```

#### Summary

#### Frontend App:

Static React files are served from /usr/share/nginx/html. The try_files directive ensures React handles client-side routing.

#### Health Check:

Provides a lightweight endpoint (/health) to check server status.

#### API Proxying:

Proxies requests starting with /api/ to the backend service at http://backend:3001/.

This configuration integrates your frontend and backend effectively, making the React app accessible on port 80 and routing API requests correctly.

PS: Update the .env file in the backend with `REACT_APP_API_URL=/api`.

This sets the base URL for API requests in a React application, allowing frontend requests to route to /api (e.g., proxied to a backend server).

## Step 3. Docker-Compose Configuration.

The docker-compose.yml file (created in the root directory of the application) defines services for the backend, frontend, and MySQL database:

```
version: "3.9"

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "3001:3001" # Expose backend on port 3001
    env_file:
      - ./backend/.env # Reference the backend environment variables
    command: sh -c "until nc -z -v -w30 mysql 3306; do echo 'Waiting for MySQL...'; sleep 1; done && node server.js"
    depends_on:
      - mysql
    networks:
      - dream-vacation-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile # Using the custom Dockerfile with NGINX
    env_file:
      - ./frontend/.env
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - dream-vacation-network

  mysql:
    image: mysql:5.7
    ports:
      - "3307:3306" # Expose MySQL on port 3306
    env_file:
      - ./backend/.env # Database-specific environment variables
    volumes:
      - db_data:/var/lib/mysql # Persist database data
      - ./backend/init.sql:/docker-entrypoint-initdb.d/init.sql # Mount init.sql script to initialize database
    networks:
      - dream-vacation-network

volumes:
  db_data:

networks:
  dream-vacation-network:
    driver: bridge
```

#### General Setup

#### Version:

Specifies the Docker Compose file format version (3.9 in this case).

#### Networks:

Defines a custom bridge network (dream-vacation-network) to allow services to communicate with each other.

---

#### Services

1. #### Backend
   Build:
   Builds the backend service using the Dockerfile located in the ./backend directory.

#### Ports:

Maps port `3001` on the host to port 3001 in the container.

#### Environment File:

References environment variables from `./backend/.env.`

#### Command:

Waits for the MySQL service (on port 3306) to become available using nc (Netcat) before running node server.js.

#### Depends On:

Ensures the mysql service starts before the backend.

#### Networks:

Connects to the dream-vacation-network.

---

2. #### Frontend
   Build:
   Builds the frontend service using the Dockerfile in the ./frontend directory.

#### Environment File:

References environment variables from `./frontend/.env.`

#### Ports:

Maps port `3000` on the host to port `80` in the container (frontend served by NGINX).

#### Depends On:

Ensures the backend service starts before the frontend.

#### Networks:

Connects to the dream-vacation-network.

---

3. #### MySQL
   Image:
   Uses the official `mysql:5.7` image.

#### Ports:

Maps port `3307` on the host to port `3306` in the container.

#### Environment File:

References environment variables from `./backend/.env` for MySQL configuration (e.g., root password, database name).

#### Volumes:

db_data: Persists database data in a Docker volume `(/var/lib/mysql)`.

Mounts an init.sql script to /docker-entrypoint-initdb.d/ to initialize the database during startup.

PS: I created an `init.sql` script file in the backend directory to create a dream_vacation database when the database is initializing.

```
CREATE DATABASE IF NOT EXISTS dream_vacation;
USE dream_vacation;
```

#### Networks:

Connects to the dream-vacation-network.

After these configurations, you run `docker-compose up --build` to build your images and then run your containers.

After verification that they are up and running, you can run `docker-compose down` to stop and destroy the containers.

#### Step 4. Push images to Docker hub

1. Log into your docker account via your browser (if you dont have an account, create one via Docker.com). Create a repository that will house your images.

2. Go to your terminal and also run `docker login`. It will prompt for your Username and Password. Feed it your details and you are ready to push your images to Docker hub.

On your terminal, use these commands to tag your images and then push to Docker.

The command to tag an image:

```
docker tag <source-image> <docker-hub-username>/<repository-name>:<tag>
```

example:

```
docker tag backend:latest bufic/dream-vacation-app:backend
docker tag frontend:latest bufic/dream-vacation-app:frontend
docker tag mysql:latest bufic/dream-vacation-app:mysql
```

where `backend` is my image name `bufic` is my docker username and `dream-vacation-app` is the repository i created to house my images.

The command to push an image to Docker Hub:

```
docker push <docker-hub-username>/<repository-name>:<tag>
```

Example:

```
docker push bufic/dream-vacation-app:backend
docker push bufic/dream-vacation-app:frontend
docker push bufic/dream-vacation-app:mysql
```

## Stage 3 (Deployment of Dream Vacation App to AWS EKS)

#### Prerequisites

Before starting, ensure you have the following tools installed:

1. AWS CLI

2. Kubectl

3. Terraform (for EKS cluster setup)

4. Docker

5. Kompose

6. MyCLI (Linux) or MySQL client (Windows) (for database verification)

### Step 1

I provisioned the EKS cluster using Terraform with S3 and DynamoDB for state management.

```
terraform init
terraform apply -auto-approve
```

Once the cluster was created, I updated my kubeconfig to connect to it:

```
aws eks --region us-east-2 update-kubeconfig --name fubara-eks-cluster
```

### Step 2 (Convert Docker Compose to Kubernetes Manifests)

I used Kompose to convert my docker-compose.yml file to Kubernetes manifests

```
kompose convert -f docker-compose.yml -o k8s-manifests/
```

This generated YAML files for the services, deployments for my frontend and backend application. Decided to discard the mysql and opted for an AWS RDS simply because it is easier to manage in a kubernetes cluster and most importantly, it is more suitable in a production enviroment because it is highly available because it automatically deploys in more than one availability zone.

##### Modify Kubernetes Manifests

Since I was using AWS RDS for MySQL, I modified the backend deployment to use the RDS database instead of a local MySQL container. I updated the env section in backend-deployment.yaml:

```
env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: DB_HOST
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: DB_USER
        - name: DB_PWD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_ROOT_PASSWORD # Correctly referencing the root password
        - name: DB_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: DB_DATABASE # Still referencing the database name from the secret
        - name: DB_PORT
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: DB_PORT
```

The env section is sourcing its values from a mysql-secret.yml file i created to store my RDS credentials/login detals.

```
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  DB_HOST: ZHJlYW0tdmFjYXRpb24uY3Rrd21jYXVndmNuLnVzLWVhc3QtMi5yZHMuYW1hem9uYXdzLmNvbQ== # "RDS Endpoint" encoded in base64
  DB_USER: YWRtaW4= # "admin" encoded in base64
  MYSQL_ROOT_PASSWORD: VmFjYXRpb25QYXNzd29yZDEyMw== # "VacationPassword123" encoded in base64
  DB_DATABASE: ZHJlYW0tdmFjYXRpb24= # "dream_vacation" encoded in base64
  DB_PORT: MzMwNg== # "3306" encoded in base64
```

### Step 3 (Deploy to EKS)

I applied all the manifests to the EKS cluster:

```
kubectl apply -f k8s-manifests/
```

I verified the pods and services:

```
kubectl get pods
kubectl get svc
```

### Step 4 (Verify Database Connection)

To confirm the backend could reach the RDS instance, I tested the MySQL connection manually:

```
mycli -h dream-vacation.ctkwmcaugvcn.us-east-2.rds.amazonaws.com -u admin -p 3306
```

I checked for the database:

```
SHOW DATABASES;
```

If the database did not exist, I created it:

```
CREATE DATABASE dream-vacation;
```

### Step 5

I retrieved the public URL:

```
kubectl get svc frontend-service
```

## Conclusion

At this point, my Dream Vacation App was successfully deployed to AWS EKS, using an AWS RDS MySQL database. The frontend was accessible via the LoadBalancer URL, and the backend was connected to the RDS instance.
