## Documentation of gcloud cli

```sh
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
```

Após instalação utilizar o comando:

```sh
$ gcloud init --no-browser --skip-diagnostics
```

Você precisará de acessar outra maquina com acesso ao browser para autenticar em máquinas que são only-console.
