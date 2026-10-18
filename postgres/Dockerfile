# Postgres with the per-service databases and users. The init script is baked in
# rather than bind-mounted, so the stack runs from any folder whatever Docker's
# file-sharing settings are.
FROM postgres:16-alpine
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql
