# API specification

### Register a new User under `/api/users`
The endpoint accepts a JSON with the following syntax:

```json
{"username": "<your username>", "password": "<your password>"}
```

### Request a new token under `/api/token`

```
curl -u <your username>:<your password> http://url/api/token
```
### Post recource configurations under `/api/resource`
The current format for the JSON configuration is:

```json
{
    "name": "destroyer",
    "instance_type": "t2.micro",
    "associate_pub_ip": true
}
```

To post your settings use the following command:

```
curl -u <your username | token>:<your password | x> --json @yourfile.json http://url/api/resource
```

