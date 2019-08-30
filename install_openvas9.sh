#Il faut mettre oui lors de la demande de mise en sock sur /var/run/redis/redis-server

# Sinon wget fonctionne avec ces lignes de conf.
# You can set the default proxies for Wget to use for http, https, and ftp.

sed -i 's|ftp_proxy=ftp://952275:olfaS4yo@fr-proxy03.knet.intra:3128|ftp_proxy=http://952275:olfaS4yo@fr-proxy03.knet.intra:3128|g' /etc/wgetrc
sed -i 's|https_proxy=https://952275:olfaS4yo@fr-proxy03.knet.intra:3128|https_proxy=http://952275:olfaS4yo@fr-proxy03.knet.intra:3128|g' /etc/wgetrc

# https://bugs.launchpad.net/~mrazavi/+archive/ubuntu/openvas/+index?field.series_filter=xenial

add-apt-repository ppa:mrazavi/openvas
# dans /etc/apt/source.list/mrazavi décommenter la ligne deb-src

apt update

#attention mettre 9 et non openvas tout court, sinon le mauvais packet sera installé
apt install -y openvas9 

# la synchronisation peut échouer due à des problèmes de proxy
# il vaut en cas d'erreur relancer plusieurs fois la synchronisation des tests de vulnérabilités
# a noter que ceci prends du temps
greenbone-nvt-sync --rsync
greenbone-nvt-sync


greenbone-scapdata-sync
greenbone-certdata-sync

#Configuration de l'interface Web
# il se met en écoute sur le port 9390 et 4000
service openvas-scanner stop
service openvas-manager stop
service openvas-gsa stop


echo "LISTEN_ADDRESS=\"0.0.0.0\"" >>  /etc/default/openvas-gsa
echo "MANAGER_ADDRESS=\"0.0.0.0\"" >>  /etc/default/openvas-gsa
echo "MANAGER_PORT_NUMBER=9390" >>  /etc/default/openvas-gsa

echo  "LISTEN_ADDRESS=\"0.0.0.0\"" >> /etc/default/openvas-manager
echo "PORT_NUMBER=9390" >> /etc/default/openvas-manager

systemctl daemon-reload

systemctl start openvas-scanner
systemctl start openvas-gsa


# ajout des users admin et omp (mdp par défaut)
openvasmd --create-user=admin --role=Admin
openvasmd --create-user=omp --role=Admin
openvasmd --user=admin --new-password=admin
openvasmd --user=omp --new-password=omp


systemctl start openvas-manager

#normalement gsad écoute sur le port 4000
netstat -antp

#gsad, openvassd et openvasmd sont lancés
ps -ef | grep openvas
ps -ef | grep gsad

#il ne reste plus qu'à faire une redirection de port des ports 9390 et 4000 sur la VM
#l'accès à la vm se fera sur l'adresse : https://localhost:4000
