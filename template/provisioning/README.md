# semaphore-provisioning

Real, per-deployment Semaphore license/certs/RPMs/credentials — never committed
(see `/semaphore-provisioning/*` in the repo root `.gitignore`). Fed into the
Docker build as a named context (`semaphore_provisioning`), configured in
`docker-compose.yml`'s `semaphore.build.additional_contexts` and consumed via
`COPY --from=semaphore_provisioning ...` in
`vendor/semaphore-all-in-one/docker/Dockerfile`.

Populate this directory with:

```
semaphore-provisioning/
├── licence/
│   └── semaphore_licence.txt # note the British English spelling
├── Semaphore_RPMs/
│   └── *.rpm                 # only needed when RPM_SOURCE=LOCAL
├── docker/
│   └── Studio/
│       └── studio-authentication.properties # working example provided; edit if desired
└── yum/                      # see vendor/semaphore-all-in-one/yum-cert-utils/README.md for cert creation instructions
    ├── semaphore-yum.cert    # only needed when RPM_SOURCE is unset/private-repo
    ├── semaphore-yum.key
    └── Semaphore.repo         # working example provided; edit if your repo URLs differ
```

Only `licence/semaphore_licence.txt`, `Semaphore_RPMs/*.rpm`, `semaphore-yum.cert`,
and `semaphore-yum.key` need to be supplied — `studio-authentication.properties`
and `Semaphore.repo` contain no secrets (the admin password is a placeholder
token substituted from `.env` at container startup) and are copied in as working
examples.

These paths are exactly the ones the Dockerfile's `COPY --from=semaphore_provisioning`
instructions reference — don't rename them.
