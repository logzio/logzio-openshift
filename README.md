# logzio-openshift
Deploy this integration to ship logs from your OpenShift cluster to Logz.io.

## Prerequisites:
1. Working Openshift cluster.
2. [Openshift CLI (oc)](https://docs.openshift.com/container-platform/4.8/cli_reference/openshift_cli/getting-started-cli.html) installed on your machine.

### 1. Create monitoring namespace

```shell
oc create namespace monitoring
```

### 2. Store your Logz.io credentials

```shell
oc create secret generic logzio-logs-secret \
  --from-literal=logzio-log-shipping-token='<<LOG-SHIPPING-TOKEN>>' \
  --from-literal=logzio-log-listener='https://<<LISTENER-HOST>>:8071' \
  -n monitoring
```

### 3. Deploy the resources
You can either deploy the default resources, or to customize it.
The default daemonset sends only container logs, and ignores all containers with "openshift" namespace.
To change that behaviour you can download the resources file, edit and deploy it.

#### Option 1: deploy default resources:
This option will only send container logs that are not under a namespace that contains the phrase "openshift".
To deploy the resources, use the following commands:
```shell
oc create -f https://raw.githubusercontent.com/logzio/logzio-openshift/main/resources.yaml \
&& oc adm policy add-scc-to-user privileged -z fluentd \
&& oc delete pod -l k8s-app=fluentd-logzio
```

#### Option 2: deploy customized resources:
If you wish to make advanced changes in your Fluentd configuration, you can download and edit the  [resources yaml file](https://raw.githubusercontent.com/logzio/logzio-openshift/main/resources.yaml).
In the file, go to the Daemonset section, and edit the environment variables.

**Environment variables**
The following environment variables can be edited directly from the DaemonSet without editing the Configmap.

| Parameter | Description |
|---|---|
| output_include_time | **Default**: `true` <br>  To append a timestamp to your logs when they're processed, `true`. Otherwise, `false`. |
| LOGZIO_BUFFER_TYPE | **Default**: `file` <br>  Specifies which plugin to use as the backend. |
| LOGZIO_BUFFER_PATH | **Default**: `/var/log/Fluentd-buffers/stackdriver.buffer` <br>  Path of the buffer. |
| LOGZIO_OVERFLOW_ACTION | **Default**: `block` <br>  Controls the behavior when the queue becomes full. |
| LOGZIO_CHUNK_LIMIT_SIZE | **Default**: `2M` <br>  Maximum size of a chunk allowed |
| LOGZIO_QUEUE_LIMIT_LENGTH | **Default**: `6` <br>  Maximum length of the output queue. |
| LOGZIO_FLUSH_INTERVAL | **Default**: `5s` <br>  Interval, in seconds, to wait before invoking the next buffer flush. |
| LOGZIO_RETRY_MAX_INTERVAL | **Default**: `30s` <br>  Maximum interval, in seconds, to wait between retries. |
| LOGZIO_FLUSH_THREAD_COUNT | **Default**: `2` <br>  Number of threads to flush the buffer. |
| LOGZIO_LOG_LEVEL | **Default**: `info` <br> The log level for this container. |
| INCLUDE_NAMESPACE | **Default**: `""`(All namespaces) <br> Use if you wish to send logs from specific k8s namespaces, space delimited. Should be in the following format: <br> `kubernetes.var.log.containers.**_<<NAMESPACE-TO-INCLUDE>>_** kubernetes.var.log.containers.**_<<ANOTHER-NAMESPACE>>_**`. |

If you wish to make any further changes in Fluentd's configuration, go to the ConfigMap section of the file and make the changes that you need.
After applying the changes, use the following commands to deploy your customized resources:

```shell
oc create -f /path/to/your/resources.yaml \
&& oc adm policy add-scc-to-user privileged -z fluentd \
&& oc delete pod -l k8s-app=fluentd-logzio
```

### 4.  Check Logz.io for your logs

Give your logs some time to get from your system to ours,
and then open [Kibana](https://app.logz.io/#/dashboard/kibana).

If you still don't see your logs,
see [log shipping troubleshooting](https://docs.logz.io/user-guide/log-shipping/log-shipping-troubleshooting.html).

### Changelog:
- 0.1.0: Update fluet base image to `fluent/fluentd-kubernetes-daemonset:v1.18-debian-logzio-amd64-1`
- 0.0.1: Initial release.