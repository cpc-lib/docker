#https://naiyous.com/6510.html
docker run -d \
   --net=host \
   -e TZ=Asia/Shanghai \
   -v /home/mail:/data \
   --name "mailserver" \
   -h "mail.ivera.cc" \
   -t analogic/poste.io:latest