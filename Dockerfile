# Selección de imagen base
FROM debian:12

# Variables de entorno para conectar con la base de datos
ENV WORDPRESS_DB_USER wordpress
ENV WORDPRESS_DB_PASSWORD wordpress
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_DB_HOST mysql-service

# Instalación de dependencias necesarias para WordPress
RUN apt-get update && apt-get install -y \
    apache2 \
    mariadb-client \
    php \
    php-mysql \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Descargar y mover WordPress al directorio web
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz && \
    mv wordpress/* /var/www/html && \
    rm -rf wordpress wordpress.tar.gz /var/www/html/index.html

# Permisos de los archivos para que los use Apache
RUN chown -R www-data:www-data /var/www/html

# Exponer los puertos que usará el contenedor
EXPOSE 80 443

# Comando para arrancar el servidor Apache en primer plano
CMD ["apache2ctl", "-D", "FOREGROUND"]
