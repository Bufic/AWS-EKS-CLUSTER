# Setup a Static Website Using Nginx

NGINX is a high-performance web server, reverse proxy, load balancer, and caching server. It is widely used in DevOps architectures.

##### Why Use NGINX?

1. #### Handles high traffic efficiently:

   NGINX handles high traffic efficiently using event-driven, asynchronous architecture, meaning it uses a single-threaded, non-blocking model where multiple connections are managed within the same process using events instead of creating new threads for each request. This reduces CPU and memory usage, making it highly scalable

2. #### Serves as a reverse proxy for backend applications:

- #### Reverse Proxy:
  NGINX acts as an intermediary between clients (users) and backend servers, forwarding client requests to the appropriate backend application.
- #### Request Handling:
  When a client requests a webpage, NGINX receives the request instead of the backend server, processes it, and forwards it to the correct backend service.
- #### Response Delivery:
  After the backend processes the request, NGINX receives the response and sends it back to the client.
- #### Load Distribution:
  If multiple backend servers exist, NGINX can distribute traffic among them, improving performance and reliability.
  Security & Optimization: NGINX can hide backend server details, cache responses, and compress content, improving security and speed.

3. #### Supports HTTPS and SSL termination:

- ##### HTTPS Support:
  NGINX enables secure communication by encrypting data between clients and servers using SSL/TLS certificates.
- ##### SSL Termination:
  NGINX decrypts HTTPS traffic before passing requests to backend servers, reducing their computational load.
- ##### Performance Boost:
  Offloading SSL decryption to NGINX frees backend servers from handling encryption, improving efficiency.
- ##### Certificate Management:
  NGINX integrates with Let's Encrypt (Certbot) and other certificate authorities to automate SSL certificate installation and renewal.

```
What is an SSL Certificate?
An SSL (Secure Sockets Layer) certificate is a digital certificate that enables encrypted communication between a web server and a client (browser). It ensures that data transferred remains private and secure.
```

### Install Nginx

```
sudo apt update
sudo apt upgrade
sudo apt install nginx
```

### NGINX Configuration File for Deploying a Static Website

To deploy a static website with NGINX, you need to configure the server block inside the NGINX configuration file. The specific file you configure depends on your Linux distribution:

Default Config File: `/etc/nginx/sites-available/default` (Ubuntu/Debian)
Global Config File: `/etc/nginx/nginx.conf `(All systems, but not recommended for site-specific configs)

#### Why Configure This File?

Defines how NGINX serves your static files (HTML, CSS, JS, images).
Specifies the root directory where your website files are located.
Allows setting up domain names, logging, and performance optimizations.

#### Example NGINX Configuration for a Static Website

Edit the configuration file:

```
   sudo nano /etc/nginx/sites-available/default
   sudo nano /etc/nginx/nginx.conf
```

Replace its content with:

```
server {
    listen 80;
    server_name example.com www.example.com;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### Explanation of the Configuration:

listen 80; → Listens on port 80 (HTTP).
server_name example.com www.example.com; → Defines the domain name.
root /var/www/html; → Specifies the folder containing your website files.
index index.html; → Sets the default file to serve.
location / { try_files $uri $uri/ =404; } → Ensures requests serve existing files or return a 404 Not Found.

##### Test Configuration for Errors:

```
sudo nginx -t
```

##### Restart NGINX to Apply Changes:

```
sudo systemctl restart nginx
```

Now, when you access http://example.com, your static website will be served by NGINX!

---

## Route53

##### What is AWS Route 53?

AWS Route 53 is a scalable and highly available Domain Name System (DNS) service provided by Amazon Web Services (AWS). It helps route end users to applications by translating human-readable domain names (e.g., example.com) into IP addresses that computers use to communicate.

##### How Does AWS Route 53 Work?

1. ###### Domain Registration (Optional)

- You can register a domain directly through Route 53 or use an external domain registrar.

2. ###### Hosted Zones & DNS Records

- A hosted zone is created to manage DNS records for your domain.
- Common DNS record types:

##### A Record:

Maps a domain to an IPv4 address.

##### CNAME Record:

Redirects one domain to another.

##### MX Record:

Defines mail servers for a domain.

##### NS Record:

Lists the authoritative name servers for the domain.

3. ###### DNS Query Resolution

- When a user enters example.com, the request is sent to Route 53.
- Route 53 looks up the DNS record and returns the correct IP address.
- The user's browser connects to that IP address to load the website.

### Why Use AWS Route 53?

- Highly Available & Scalable (Handles millions of requests).
- Tightly Integrated with AWS Services (EC2, ELB, CloudFront, etc.).
- Fast & Reliable DNS Resolution (Low latency globally).
- Advanced Traffic Control (Failover, geo-routing, load balancing).

---

## Certbot

Certbot is an open-source tool for automating the process of obtaining and renewing SSL/TLS certificates from the Let's Encrypt Certificate Authority (CA). These certificates are used to enable HTTPS on websites, which encrypts data transmitted between the server and the client's browser, enhancing security.

#### How Does Certbot Work?

1. ###### Domain Verification:

   Certbot verifies that you own the domain by placing a challenge file in your web server or using DNS validation.

2. ###### Certificate Issuance:

   If verification is successful, Let’s Encrypt issues an SSL/TLS certificate.

3. ###### Automatic Configuration:

   Certbot can configure NGINX or Apache to use the new certificate.

4. ###### Auto-Renewal:
   Certbot renews certificates automatically before expiration (every 90 days).

### Installing Certbot on Ubuntu (NGINX)

To secure your NGINX web server with SSL/TLS, you need to install Certbot and its NGINX plugin. Follow these steps for a smooth installation and setup.

🔹Step 1: Update Your Package List

```
sudo apt update
```

This command refreshes the list of available packages and their versions, ensuring you install the latest stable Certbot release.

🔹Step 2: Install Certbot & NGINX Plugin

```
sudo apt install certbot python3-certbot-nginx -y
```

##### What does this command do?

`certbot`: Installs the Certbot tool to request and manage SSL certificates.
`python3-certbot-nginx`: The plugin that enables Certbot to automatically configure SSL settings for NGINX.
`-y`: Automatically confirms the installation, so you don’t have to manually press "yes" (y).

After installation, Certbot is ready to obtain SSL certificates and configure NGINX for HTTPS.

## Obtaining and Installing an SSL Certificate

🔹 Step 1: Run Certbot with NGINX Plugin

```
sudo certbot --nginx -d example.com -d www.example.com
```

- Replace example.com with your actual domain name.
- Certbot will automatically configure NGINX to use the issued SSL certificate.

🔹 Step 2: Verify SSL Configuration

```
sudo nginx -t
```

Restart NGINX if needed:

```
sudo systemctl restart nginx

```

### Auto-Renewing SSL Certificates

Let’s Encrypt certificates expire every 90 days, but Certbot can renew them automatically.

Check if auto-renewal is enabled:

```
sudo systemctl status certbot.timer
```

### Verifying SSL is Working

Open your website in a browser with https:// or check using:

```
curl -I https://example.com
```

- Replacing "example.com" with your Domain name.

### Summary

- Certbot automates SSL certificate management.
- Let’s Encrypt provides free SSL/TLS certificates.
- NGINX Plugin helps in auto-configuring SSL settings.
- Auto-renewal ensures continuous HTTPS security.
