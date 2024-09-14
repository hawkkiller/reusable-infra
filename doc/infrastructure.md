# Infrastructure

Some docs about the infrastructure of the project.

## Cloudnative PG

Cloudnative pg is an operator for PostgreSQL that runs on Kubernetes.
It is a powerful tool that makes it easy to deploy production-ready clusters that
support replication, backup, and high availability.

In order to deploy a simple PostgreSQL cluster that supports backups, consider the following configuration:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster
spec:
  instances: 1
  superuserSecret:
    name: superuser-secret

  backup:
    retentionPolicy: 7d
    barmanObjectStore: &barman
      serverName: &current-cluster cluster-v1
      destinationPath: "s3://shoplist-staging-backups"
      endpointURL: "https://d2e1470eded3cd2e7a93cc3f69f34558.r2.cloudflarestorage.com"
      data:
        compression: bzip2
      wal:
        compression: bzip2
        maxParallel: 8
      s3Credentials:
        accessKeyId:
          name: &s3-secret s3-credentials
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: *s3-secret
          key: ACCESS_SECRET_KEY

  # bootstrap:
  #   initdb:
  #     database: app
  #     owner: shoplist
  #     secret:
  #       name: app-secret

  #   recovery:
  #     database: app
  #     owner: shoplist
  #     secret:
  #       name: app-secret
  #     source: &prev-cluster cluster-v1
  # externalClusters:
  #   - name: *prev-cluster
  #     barmanObjectStore:
  #       <<: *barman
  #       serverName: *prev-cluster
```

This configuration will create a PostgreSQL cluster with a single instance and a backup configuration that will store backups in an S3 bucket. The backups are managed by Barman, a tool that makes it easy to manage backups and restore them when needed.

However, this configures barman to only save WALs. It is also needed to configure the `ScheduledBackup` resource that will trigger the backup. If there is no backup, the cluster will not be able to restore itself.

If you're bootstrapping cluster the first time, you should uncomment the initdb section.
Otherwise, if you have a backup to recover from, you should uncomment the recovery section.

Each time you recover from a backup, you should bump the cluster version. For example, you had clusterv1, and you recovered from a backup, the current cluster variable should be changed to clusterv2.
This is needed to avoid conflicts with the barman object store.

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: cluster
spec:
  cron: "0 0 * * *"
  backupOwnerReference: self
  cluster:
    name: &current-cluster
```

This configuration will create a `ScheduledBackup` resource that will trigger a backup every day at midnight.