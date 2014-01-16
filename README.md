### Unity WebPlayer Security SandBox server

有关unity webplayer security sandbox server 请看[Unity3d Web Player 的server端联网配置](http://www.cnblogs.com/funyuto/p/3216256.html).

有关unity webplayer security sandbox server，更详细的描述[SecuritySandbox](http://game.ceeger.com/Manual/SecuritySandbox.html)

### sandbox server 说明

在linux环境下，如果使用Linux的NetCat（NC）工具，来搭建sandbox服务器，非常的不稳定。使用scoket常常连接不上843端口。

因此我写了一个sandbox服务器,用tcp打开843端口监听,有访问时,返回一串固定文本。

### 部署和测试

* 使用`mvn package`打包TcpSandBox-0.0.1-SNASHOT.jar
* 将configure.properties,server.sh,TcpSandBox-0.0.1-SNASHOT.jar上传到游戏服务器同一文件目录下。eg:../sandBoxServer/
* 使用`server.sh start`   启动服务；
* 使用`server.sh stop`    停止服务；
* 使用`server.sh restart` 重启服务；
* 常看sandbox_server.log看服务是否正常启动；
* 使用`telnet sandBoxServerIP 843` 测试
* eg：
    
 ```     
 telnet 127.0.0.1 843

 Trying 127.0.0.1...
 Connected to 127.0.0.1.
 Escape character is '^]'.
 <?xml version="1.0"?>
 <cross-domain-policy>
 <allow-access-from domain="*" to-ports="1-65536"/>
 </cross-domain-policy>
 Connection closed by foreign host.
 ```    
 
### 常见问题

1. 执行server.sh时，找不到JDK运行环境  
你需要去server.sh 修改JDK=your javahome path

2. 执行server.sh时，没有权限   
可以尝试：
`chmod +x server.sh` 
`sudo ./server.sh`



 



 

  
