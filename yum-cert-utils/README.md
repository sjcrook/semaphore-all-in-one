# Semaphore yum repository certificate generation
 
## Dependencies

OpenSSL

## Instructions

The batch (Windows) and bash (*nix/Mac) scripts here can be used to generate an archive file consisting of a certificate and key, into the "temp" directory of your platform. These would (respectively) be:

- C:\temp\ (Windows)
- /tmp/ (*nix/Mac)

This archive file will differ for your platform. The Windows batch script will produce a .zip, and the bash script will produce a .tar. 

The archive itself can be sent to the Semaphore CloudOps admins (Steve Rice) to register the cert in the Yum repository.

The cert and key can then be placed in your `yum/` directory, at `semaphore-yum.(cert|key)`.
