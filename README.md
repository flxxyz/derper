# derper

> Tailscale DERP Server

### QuickStart

```bash
# Start DERP Server
./derper.sh --host foo.link --start

# Stop DERP Server
./derper.sh --stop
```

### Derp Map

> Append to access controls

```json
{
  // ...
  "derpMap": {
    "OmitDefaultRegions": false, // 替换官方服务器需要设置为true，但可能会完全无法访问哦
    "Regions": {
      "900": {
        "RegionID": 900,
        "RegionCode": "xnet-aws-01", // 编号随意
        "RegionName": "xnet", // 名字随意
        "Nodes": [
          {
            "Name": "aws-01", // 随意
            "RegionID": 900,
            "HostName": "aws-01.foo.link", // 与DERP服务器绑定的域名
            "DERPPort": 33333, // 环境变量中配置的端口号
            "STUNPort": 33333,
            "InsecureForTests": false, // 不验证证书有效性，使用自签证书只能设置为true
          },
        ],
      },
      "901": {
        "RegionID": 901,
        "RegionCode": "xnet-aws-02",
        "RegionName": "xnet",
        "Nodes": [
          {
            "Name": "aws-02",
            "RegionID": 901,
            "HostName": "aws-02.foo.link",
            "DERPPort": 33333,
            "STUNPort": 33333,
            "InsecureForTests": true,
          },
        ],
      },
    },
  },
}
```
