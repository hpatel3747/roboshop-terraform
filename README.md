# roboshop-terraform

## Deploy Hashicorp vault

### download repo
```text
curl -L -o /etc/yum.repos.d/vault.repo /https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
```
### search repo downloaded
```text
dnf list | grep vault
```
### install vault
```text
dnf install vault -y
```
