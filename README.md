# postgres

## Directory structure

```
├── .github/
│   └── workflows/
│       ├── postgres.yml
│       └── cleanup.yml
├── postgres/
│   ├── pgrx
│   │   └── Dockerfile
│   ├── extensions/
│   │   ├── pg_jsonschema/
│   │   │   └── Dockerfile
│   │   ├── pg_session_jwt/
│   │   │   └── Dockerfile
│   │   └── wrappers/
│   │       └── Dockerfile
│   └── Dockerfile
└── docker-bake.hcl
```