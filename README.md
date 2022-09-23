# Lab S4U2Self Abuse

This lab aims to provide a safe environment to test the `S4U2Self abuse` exploit

# Deploy
The project will deploy :
- 1 `DC` with a single `domain admin` `hpotter`
- 1 `MSSQL` with a weak `sa` password

The deployment is performed through `terraform` and `ansible` on `AWS` thus, both these software must be installed and you must provide your `AWS` credentials.

Then just run `terraform init && terraform apply --auto-approve`

> Don't forget to destroy the lab with `terraform destroy --auto-approve` once you've finished it !

# Spoiler
- Simple bruteforce on `MSSQL`'s `sa` account
- RCE on the server (see [here](https://otterhacker.github.io/Pentest/Services/MSSQL.html))
- S4U2Self abuse (see [here](https://otterhacker.github.io/Pentest/Services/Kerberos.html))
