# terraform-kubernetes-lagom
Terraform module for simplifying deployments of Lagom-based applications.

Usage of this module depends on the following:
- The Docker Image has a `JAVA_OPTS` ENV for JVM options to inject before the Production class argument
- The primary application config is `application.conf` for several defaults, regardless of environment.
- A kubernetes secret is generated for the `production.conf` and injected as a file with the various extra
configuration options desired

## What does this module do for you?

To put it simply, this module

[SystemOfADownload]:https://github.com/SpongePowered/SystemOfADownload
[sbt-native-packager]:https://sbt-native-packager.readthedocs.io/en/latest/formats/docker.html