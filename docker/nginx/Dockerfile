FROM nginx
COPY nginx /etc/nginx
COPY letsencrypt /etc/letsencrypt
RUN apt-get update && apt-get install -yy curl
RUN mkdir -p /var/lib/jenkins_artifacts /var/www/conservify.org /var/www/fieldkit.org
