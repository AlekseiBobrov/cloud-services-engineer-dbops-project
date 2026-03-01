# dbops-project
Исходный репозиторий для выполнения проекта дисциплины "DBOps"

### Create `store` db

```sh
psql "host=<host> port=<port> dbname=store_default user=<user>"
store_default=# CREATE DATABASE store;
store_default=# \c store
store=# CREATE USER new_user WITH PASSWORD 'new_user_password';
store=# GRANT ALL PRIVILEGES ON DATABASE store TO new_user;
store=# GRANT USAGE ON SCHEMA public TO new_user;
store=# GRANT CREATE ON SCHEMA public TO new_user;
store=# ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO new_user;
```