# docker nginx vhost 0.1.0
![image](https://github.com/Seull1/docker-nginx-vhost/assets/148920003/209113be-0395-413e-b2de-07c3b7f8977c)

# Start!  (로드 밸런싱 수동과정)
### step 1
```
$ docker rm * rmi

$ sudo docker images
REPOSITORY      TAG       IMAGE ID       CREATED        SIZE
$ sudo docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                   NAMES
```

### step 2
```
$ sudo docker run -itd -p 9000:80 --name main nginx:latest
9a66469ad98acb5de9606acd8afd9f48779a56e7115217dab9a6681cd80bc272
$ sudo docker run -itd -p 9001:80 --name server-1 nginx
031d93f390507ca865e89e81bf6c0a6bcab103e3d19fbfcf1eb1dfdd32d62832
$ sudo docker run -itd -p 9002:80 --name server-2 nginx
de471c8020a7ac716d6c436b361864d59ee63bc24f004e0fc1ed76bd9c8d696c

$ sudo docker images
REPOSITORY      TAG       IMAGE ID       CREATED        SIZE
nginx           latest    247f7abff9f7   3 months ago   187MB

$  sudo docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED              STATUS              PORTS                                   NAMES
de471c8020a7   nginx            "/docker-entrypoint.…"   31 seconds ago       Up 29 seconds       0.0.0.0:9002->80/tcp, :::9002->80/tcp   server-2
031d93f39050   nginx            "/docker-entrypoint.…"   37 seconds ago       Up 36 seconds       0.0.0.0:9001->80/tcp, :::9001->80/tcp   server-1
9a66469ad98a   nginx:latest     "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:9000->80/tcp, :::9000->80/tcp   main


$ cat main/config/default.conf
upstream server {
        server server-1:80;
        server server-2:80;
}
server {
   listen 80;

   location /
   {
        proxy_pass http://server;
   }
}

$  tree
.
├── README.md
├── main
│   └── config
│       └── default.conf
├── server-1
└── server-2
```

### step 3
```
$ sudo docker cp server-1/index.html server-1:/usr/share/nginx/html
Successfully copied 2.05kB to server-1:/usr/share/nginx/html

$ sudo docker cp server-2/index.html server-2:/usr/share/nginx/html
Successfully copied 2.05kB to server-2:/usr/share/nginx/html

$ sudo docker cp default.conf main:/etc/nginx/conf.d
Successfully copied 2.05kB to main:/etc/nginx/conf.d

$ sudo docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                   NAMES
de471c8020a7   nginx            "/docker-entrypoint.…"   23 minutes ago   Up 23 minutes   0.0.0.0:9002->80/tcp, :::9002->80/tcp   server-2
031d93f39050   nginx            "/docker-entrypoint.…"   23 minutes ago   Up 23 minutes   0.0.0.0:9001->80/tcp, :::9001->80/tcp   server-1
이때 main은 host not found in upstream 에러때문에 나오지 않아야한다
main 은 추후 네트워킹 설정후 나온다
```
### step 4
```
$ sudo docker network ls

$ sudo docker network create aaa
3d8f9812defe0076ce62cc29b3e872d84d39a345a253268f8b5d210ed82ffe66

$ sudo docker network inspect aaa
[
    {
        "Name": "aaa",
        "Id": "3d8f9812defe0076ce62cc29b3e872d84d39a345a253268f8b5d210ed82ffe66",
        "Created": "2024-02-14T16:39:17.215767119+09:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
현재 네트워킹하지않아서 Containers 가 비어있슴

$ sudo docker network connect aaa server-1
$ sudo docker network connect aaa server-2
$ sudo docker network connect aaa main

$ sudo docker inspect aaa
[
    {
        "Name": "aaa",
        "Id": "3d8f9812defe0076ce62cc29b3e872d84d39a345a253268f8b5d210ed82ffe66",
        "Created": "2024-02-14T16:39:17.215767119+09:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "031d93f390507ca865e89e81bf6c0a6bcab103e3d19fbfcf1eb1dfdd32d62832": {
                "Name": "server-1",
                "EndpointID": "f44ca5ba220720255db70b8f61ed7e0ed97a33e20114284e13f89a646552907c",
                "MacAddress": "02:42:ac:14:00:02",
                "IPv4Address": "172.20.0.2/16",
                "IPv6Address": ""
            },
            "9a66469ad98acb5de9606acd8afd9f48779a56e7115217dab9a6681cd80bc272": {
                "Name": "main",
                "EndpointID": "e13daf46a9cb02b94d213aec812c430e5f3fc61b39f10a9f796ff93f9bc774cc",
                "MacAddress": "02:42:ac:14:00:04",
                "IPv4Address": "172.20.0.4/16",
                "IPv6Address": ""
            },
            "de471c8020a7ac716d6c436b361864d59ee63bc24f004e0fc1ed76bd9c8d696c": {
                "Name": "server-2",
                "EndpointID": "3bbd917b29e070b2cf592bf2ccd147f563a445aaf5bda9edf1aad0343e1f5cd4",
                "MacAddress": "02:42:ac:14:00:03",
                "IPv4Address": "172.20.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]

```

### step 5
```
$ sudo docker exec -it main bash
들어간후
telnet 172.20.0.4 80

```
![image](https://github.com/Seull1/docker-nginx-vhost/assets/148920003/2748a6bb-848c-4b3c-be61-608c01bc4b3b)

## main 접속시 nginx 만 뜬다면 서버 리스타트를 해야한다


 # 결과 확인
 
![image](https://github.com/Seull1/docker-nginx-vhost/assets/148920003/f941da90-d7ad-4c2d-9884-547f17103ff1)

새로고침시
![image](https://github.com/Seull1/docker-nginx-vhost/assets/148920003/5e6f6f5f-8a77-4e7e-9b4d-cd7221324eb4)

## nginx-routing
- [ ] 

### Thanks
![LGTM](https://i.lgtm.fun/1cvq.gif)
