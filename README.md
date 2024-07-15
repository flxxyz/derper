# derper

> Tailscale DERP Server

```
Usage: derper.sh --start [--verbose]
       derper.sh --stop [--verbose]
       derper.sh --self-cert-sign-request [--verbose]
```

## QuickStart

### Start DERP Server

```bash
./derper.sh --start --verbose
```

### Stop DERP Server

```bash
./derper.sh --stop --verbose
```

### Self-signed certificate

```bash
./derper.sh --self-cert-sign-request --verbose
```

## Environment

| Name               | Default Value           | Required | Remark                             |
| :----------------- | :---------------------- | :------: | :--------------------------------- |
| CONFIG_FILE        | /opt/derper/env         |    NO    | Absolute path to the `env` file    |
| VERBOSE            | 0                       |    NO    | Output stdout and stderr to tty    |
| DERP_DIR           | /opt/derper             |    NO    | Custom derper directory            |
| DERP_HOST          |                         |   YES    | Derp server listen host            |
| DERP_PORT          | 33333                   |    NO    | Derp server listen port            |
| DERP_CONN_LIMIT    | 100                     |    NO    | Limit derp server clients          |
| DERP_VERIFY_CLENTS | 1                       |    NO    |                                    |
| DERP_CONF          | /opt/derper/derper.conf |    NO    | Derp server node info              |
| CERT_DIR           | /opt/derper/cert        |    NO    | Check form Self-signed certificate |
| LOG_DIR            | /opt/derper/logs        |    NO    | Logs store directory               |
| CERT_DAYS          | 36500                   |    NO    |                                    |
| GOPROXY            | https://goproxy.io      |    NO    | China may need it                  |

### Command parameters

| Command                  | description                       |
| :----------------------- | :-------------------------------- |
| --self-cert-sign-request | generate self-signed certificate  |
| --start                  | start derp server                 |
| --stop                   | stop derp server                  |
| --verbose                | control the foreground output log |
| --help                   | show help                         |

## Simple Derp Network

```json
{
  // ...
  "derpMap": {
    "OmitDefaultRegions": true,
    "Regions": {
      "900": {
        "RegionID": 900,
        "RegionCode": "aws-us-nc",
        "RegionName": "AWS US West (Northern California)",
        "Nodes": [
          {
            "Name": "900-01",
            "RegionID": 900,
            "HostName": "aws-us-nc-w3qw.foo.link",
            "DERPPort": 33900,
            "STUNPort": 33900,
            "InsecureForTests": false,
          },
        ],
      },
      "901": {
        "RegionID": 901,
        "RegionCode": "aws-na-ca-cgy",
        "RegionName": "AWS Canada West (Calgary)",
        "Nodes": [
          {
            "Name": "901-01",
            "RegionID": 901,
            "HostName": "aws-na-ca-cgy-xs2d.foo.link",
            "DERPPort": 33901,
            "STUNPort": 33901,
            "InsecureForTests": false,
          },
          {
            "Name": "901-02",
            "RegionID": 901,
            "HostName": "aws-na-ca-cgy-v2cp.foo.link",
            "DERPPort": 33901,
            "STUNPort": 33901,
            "InsecureForTests": false,
          },
        ],
      },
      "902": {
        "RegionID": 902,
        "RegionCode": "aws-aus-syd",
        "RegionName": "AWS Australia (Sydney)",
        "Nodes": [
          {
            "Name": "902-01",
            "RegionID": 902,
            "HostName": "aws-aus-syd-ezz5.foo.link",
            "DERPPort": 33902,
            "STUNPort": 33902,
            "InsecureForTests": false,
          },
          {
            "Name": "902-02",
            "RegionID": 902,
            "HostName": "aws-aus-syd-oyir.foo.link",
            "DERPPort": 33902,
            "STUNPort": 33902,
            "InsecureForTests": false,
          },
        ],
      },
      "903": {
        "RegionID": 903,
        "RegionCode": "az-asia-osa",
        "RegionName": "Azure Japan West (Osaka)",
        "Nodes": [
          {
            "Name": "903-01",
            "RegionID": 903,
            "HostName": "az-asia-osa-epmj.foo.link",
            "DERPPort": 33903,
            "STUNPort": 33903,
            "InsecureForTests": false,
          },
          {
            "Name": "903-02",
            "RegionID": 903,
            "HostName": "az-asia-osa-7b6y.foo.link",
            "DERPPort": 33903,
            "STUNPort": 33903,
            "InsecureForTests": false,
          },
        ],
      },
      "904": {
        "RegionID": 904,
        "RegionCode": "gcp-eur-west3",
        "RegionName": "GCP Europe West3 (Frankfurt)",
        "Nodes": [
          {
            "Name": "904-01",
            "RegionID": 904,
            "HostName": "gcp-eur-west3-ng1a.foo.link",
            "DERPPort": 33904,
            "STUNPort": 33904,
            "InsecureForTests": false,
          },
          {
            "Name": "904-02",
            "RegionID": 904,
            "HostName": "gcp-eur-west3-b-huzr.foo.link",
            "DERPPort": 33904,
            "STUNPort": 33904,
            "InsecureForTests": false,
          },
        ],
      },
      "905": {
        "RegionID": 905,
        "RegionCode": "gcp-sa-east1",
        "RegionName": "GCP South America East1 (Osascu)",
        "Nodes": [
          {
            "Name": "905-01",
            "RegionID": 905,
            "HostName": "gcp-sa-east1-pewt.foo.link",
            "DERPPort": 33905,
            "STUNPort": 33905,
            "InsecureForTests": false,
          },
        ],
      },
      "906": {
        "RegionID": 906,
        "RegionCode": "az-asia-sg",
        "RegionName": "Azure Southeast Asia (Singapore)",
        "Nodes": [
          {
            "Name": "906-01",
            "RegionID": 906,
            "HostName": "az-asia-sg-aovm.foo.link",
            "DERPPort": 33906,
            "STUNPort": 33906,
            "InsecureForTests": false,
          },
        ],
      },
    },
  },
}
```
