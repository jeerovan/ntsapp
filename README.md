# ntsapp

## Steps to configure

- Setup flutter
- add dependencies with `flutter pub get`
- create a file named 'config.txt' in assets folder with following contents
```
{
  "db_file":"notetoself.db",
  "backup_dir":"ntsbackup",
  "media_dir":"ntsmedia",
  "sentry_dsn":"https://<CODE>@subdomain.ingest.us.sentry.io/<CODE>"
}
```