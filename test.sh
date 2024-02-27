docker build -t s-1 -f server-1/Dockerfile /home/seull/code/docker-nginx-vhost/server-1
docker build -t s-2 -f server-2/Dockerfile /home/seull/code/docker-nginx-vhost/server-2
docker build -t lb:1 -f main/Dockerfile /home/seull/code/docker-nginx-vhost/main/
docker build -t blog -f /home/seull/code/seull.blog-copy/docker/blog-a/Dockerfile /home/seull/code/docker-nginx-vhost/blog

docker run -itd -p 9000:80 --name lb nginx:latest
docker run -itd -p 9001:80 --name server-1 s-1
docker run -itd -p 9003:80 --name server-2 s-2
docker run -itd -p 9002:80 --name blog blog

docker cp /home/seull/code/docker-nginx-vhost/main/config/default.conf lb:/etc/nginx/conf.d
sudo docker cp server-1/index.html server-1:/usr/share/nginx/html
sudo docker cp server-2/index.html server-2:/usr/share/nginx/html
sudo docker cp blog/index.html blog:/usr/share/nginx/html


docker network create bbb



docker network connect bbb server-1
docker network connect bbb server-2
docker network connect bbb blog
docker network connect bbb lb

docker stop lb
docker start lb
