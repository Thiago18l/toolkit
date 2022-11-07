# Documentação dos Scripts de Backup


No arquivo `.env` na raiz do repo inserir as variáveis de ambiente para a execução do script para backup lógico.

```sh
USERDB=
PASS=
HOSTDB=
```
**OBS:** Se o arquivo não existir, criar o `.env` na raiz do repo e alterar o path da variavel `PATH_ENV` no arquivo `backup.sh`

### **Como Executar?**

Utilizar o bash para rodar o arquivo com o seguinte comando:
```sh
$ bash ./src/backup/backup.sh
```
Ele irá ler as variaveis do arquivo `.env` e em seguida irá executar o backup.

<hr>

- `backup.sh` *Arquivo de backup do banco de dados*
- `.env` *Variáveis de ambiente referente ao acesso aos bancos*