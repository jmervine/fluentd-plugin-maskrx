# fluentd-plugin-maskrx

A simple Fluentd filter plugin to mask string events using a regex.

### Configurations

| Block | Config  | Default | Desc |
| ----- | ------  | ------- | ---- |
| mask  | keys    | nil     | (Array)  Keys to perform mask on, if none than all keys are filtered. |
| mask  | pattern | nil     | (Regexp) REQUIRED: Ruby Regexp matching one or more strings within a record key. |
| mask  | mask    | \*\*\*\*\*\*\*\* | (String) The mask string to be used in replacing the matched strings within the record. |

#### Example configuration

```
<filter **>
  @type maskrx

  <mask>
    pattern /password=([.[^ ]]+)(?: |$)/
    mask    xxxxx
  </mask>
  <mask>
    keys token, accesskey
    pattern /^.+$/
  </mask>
</filter>
```

##### Example record
```
{
    "message":"This is a password=foobarbah",
    "password":"password=foobarbah",
    "token": "some-token"
}
```

##### Example output
```
{
    "message":"This is a password=xxxxx",
    "password":"password=foobarbah",
    "token": "some-token"
}
```
