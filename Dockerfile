# Use the official Nginx image as base
FROM nginx:latest

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/

# Copy the HTML file
COPY welcome.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx when the container has provisioned.
CMD ["nginx", "-g", "daemon off;"]
