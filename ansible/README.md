# S4U2Self Abuse Lab

This lab aims to provide a safe environment to exploit the `S4U2Self Abuse` vulnerability.

# Deploy
The terraform will deploy the infrastructure in `AWS`. Thus, you will have to provide your `AWS` credentials.

Then just run `terraform init && terraform apply --auto-approve`.

You will have to have `ansible` installed as the configuration is pushed through `ansible`.

# Infrastructure
- 1 `DC` with 1 domain admin called `hpotter`
- 1 `MSSQL` server with a weak `sa` password

# Exploitation
The goal is to root the `MSSQL` server.

## Spoiler
- Get `sa` access on the `MySQL` using simple bruteforce
- Get `RCE` on the server
- Exploit `S4U2Self` ([See here](https://otterhacker.github.io/Pentest/Services/Kerberos.html))

