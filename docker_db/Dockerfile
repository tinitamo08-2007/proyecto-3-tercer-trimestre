FROM mysql:8.0

# Configuración inicial de la base de datos
ENV MYSQL_DATABASE=mi_base_de_datos
ENV MYSQL_USER=usuario
ENV MYSQL_PASSWORD=contraseña_segura
ENV MYSQL_ROOT_PASSWORD=contraseña_root_segura

# Puerto que utiliza MySQL
EXPOSE 3306

# Declaración del volumen (buena práctica)
VOLUME ["/var/lib/mysql"]

# Comando de inicio
CMD ["mysqld"]
