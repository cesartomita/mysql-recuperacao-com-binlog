# Recuperação de banco de dados MySQL usando binlog

Este repositório tem como objetivo demonstrar uma **simulação de recuperação de dados** em um banco de dados **MySQL** utilizando os arquivos **binlog (binary log)**.

A simulação será feita com uso de contêineres Docker (em ambiente Windows), onde:

- O banco original estará rodando com a imagem **mysql:8.0**.
- A recuperação será feita em outro contêiner com a imagem **mysql:8.0-debian**.

## Objetivos

- Demonstrar como habilitar o binlog no MySQL.
- Simular a perda de dados ou falha no servidor.
- Restaurar o banco até um determinado ponto usando os arquivos binlog (binary log).

## Como executar a simulação

### Resumo dos scripts utilizados:
1. `docker-compose up -d`
2. `.\scripts_bash\select_tables.sh`
3. `.\scripts_bash\simulate_disaster.sh`
4. `.\scripts_bash\copy_binlogs.sh`
5.
    1. `.\scripts_bash\binlog_to_sql_datetime.sh`
    2. `.\scripts_bash\binlog_to_sql_position.sh`
6.
    1. `.\scripts_bash\restore_db.sh`
    2. `.\scripts_bash\restore_using_binlog_datetime.sh`
    3. `.\scripts_bash\restore_using_binlog_position.sh`

### 1. Subindo os contêineres

Inicie os contêineres MySQL com o Docker Compose:

`docker-compose up -d`

Isso iniciará os dois contêineres:

- **mysql_binlog_production**: Banco de dados principal com binlogs habilitados.
- **mysql_binlog_recovery**: Banco de dados para recuperação.

Verifique se os contêineres estão rodando com o comando:

`docker ps`

### Tabela de Contêineres

<table>
  <thead>
    <tr>
      <th>Contêiner</th>
      <th>Endereço</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>mysql_binlog_production</td>
      <td>localhost:5001</td>
    </tr>
    <tr>
      <td>mysql_binlog_recovery</td>
      <td>localhost:5002</td>
    </tr>
  </tbody>
</table>

Caso precisa resetar os contêineres e pastas/volumes criados, basta executar o arquivo `docker_reset.sh`.

### 2. Inserindo dados no MySQL

O banco de dados será inicializado automaticamente com os scripts SQL localizados no diretório *scripts_mysql*.

Esses scripts criam o banco de dados, tabelas e inserem dados iniciais. Pode levar alguns minutos até que todos os scripts sejam executados.

Para verificar os dados inseridos, execute:

`select_tables_production.sh`

### 3. Simular um desastre

Execute o script `simulate_disaster.sh` para simular um desastre no banco de dados de produção.

Este script realiza as seguintes ações:

- Drop na tabela *diretores*.
- Exclusão dos registros da tabela *vendedores* com id superior a 1.
- Atualização do campo nome de todos os registros na tabela *clientes*.

Essas operações simulam um cenário de falha onde dados importantes são perdidos ou alterados por acidente.

Pode executar novamente o `select_tables_production.sh` para verificar que alguns dados foram perdidos e alterados.

### 4. Copiar os arquivos binlog

Copiar os arquivos binlog do contêiner de produção para o host e, em seguida, para o contêiner de recuperação.

Execute o script:

`copy_binlogs.sh`

Este script realiza as seguintes ações:

- Copia os arquivos binlog do contêiner mysql_binlog_production para o diretório binlogs_recovery no host.
- Copia os arquivos binlog do host para o contêiner mysql_binlog_recovery.

Observação: Em um ambiente real, o número de arquivos binlog pode variar dependendo da configuração do MySQL e do volume de transações realizadas. Antes de copiar os arquivos binlog, é essencial verificar quantos arquivos existem e quais precisam ser copiados.

### 5. Restaurar o banco de dados

No contêiner de recuperação, você pode aplicar os arquivos binlog para restaurar o banco até o ponto desejado. Existem dois métodos disponíveis para realizar a recuperação:

1. Convertendo os arquivos binlog para SQL.

    Prós:

    - Você pode revisar o conteúdo SQL antes de aplicar.
    - Fácil de auditar ou ajustar comandos manualmente.
    - Pode aplicar com --verbose --force e salvar logs de erro.

    Contras:

    - O processo pode ser mais lento, principalmente para binlogs grandes.
    - Pode falhar se o script SQL contiver comandos dependentes de tabelas não existentes.

2. Restaruar diretamenteo do binlog.

    Prós:

    - Mais rápido, pois os comandos são enviados direto ao MySQL.
    - Menor uso de disco, pois não gera arquivos intermediários.

    Contras:

    - Menos controle sobre o que será aplicado.
    - Difícil auditar ou corrigir erros caso algo dê errado.
    - Se houver falha no meio do processo, pode ser difícil identificar o ponto exato.

### Scripts de restauração:

SQL - Baseado em data e hora (`binlog_to_sql_datetime.sh`)

SQL - Baseado em posição (`binlog_to_sql_position.sh`)

BINLOG - Baseado em data e hora (`restore_using_binlog_datetime.sh`)

BINLOG - Baseado em posição (`restore_using_binlog_position.sh`)

Baseado em data e hora: Este método permite restaurar o banco até um momento específico no tempo.
Útil para cenários onde você sabe exatamente quando ocorreu a falha ou alteração indesejada.

Baseado em posição: Este método permite restaurar o banco até uma posição específica no arquivo binlog. Útil para cenários onde você deseja restaurar até um evento específico registrado no binlog.

--start-position: Começa a leitura do binlog a partir de uma posição específica.

--stop-position: Interrompe a leitura até uma posição específica.

--start-datetime: Define quando o mysqlbinlog deve começar a ler o binlog. A leitura só começa nos eventos com timestamp igual ou superior à data/hora informada.

--stop-datetime: Define quando parar de ler os eventos do binlog. A leitura para antes de eventos que tenham timestamp igual ou maior do que essa data/hora.

### Como identificar o ponto de recuperação?

Antes de aplicar os binlogs, você pode inspecionar os eventos registrados para identificar o ponto exato de recuperação. Use o script `binlog_preview.sh` para gerar uma prévia dos eventos no arquivo binlog

Isso criará um arquivo chamado `RESTORE_PREVIEW_00000x.sql` contendo os eventos decodificados do binlog.

Exemplo de saída do arquivo `RESTORE_PREVIEW_00000x.sql`:

```
BEGIN
/*!*/;
# at 1519
#250412 20:29:46 server id 1  end_log_pos 1582 CRC32 0xfa5bc21f 	Table_map: `demo`.`diretores` mapped to number 116
# has_generated_invisible_primary_key=0
# at 1582
#250412 20:29:46 server id 1  end_log_pos 1636 CRC32 0x6e2ff9cd 	Write_rows: table id 116 flags: STMT_END_F
### INSERT INTO `demo`.`diretores`
### SET
###   @1=9385
###   @2='DIRETOR 9385'
# at 1636
#250412 20:29:46 server id 1  end_log_pos 1667 CRC32 0x0c9129ea 	Xid = 187101
COMMIT/*!*/;
```
### Como identificar a data/hora e a posição?

Data e hora:

A data e hora do evento estão indicadas no formato #YYYYMMDD HH:MM:SS.

> #250412 20:29:46

Isso corresponde a 2025-04-12 20:29:46.

Posição:

A posição do evento está indicada após # at.

> \# at 1636

Isso indica que o evento começa na posição 1636.

## 6. Escolher o método de recuperação:

Existem dois métodos para realizar a recuperação do banco de dados usando binlog:

### 1. Por SQL (Convertendo binlogs para SQL)

Este método converte os arquivos binlog em comandos SQL, que podem ser revisados e aplicados manualmente no banco de dados de recuperação.

Passos:

1. Execute o script `binlog_to_sql_datetime.sh` ou `binlog_to_sql_position.sh` para gerar o arquivo RESTORE.sql.

2. Após gerar o arquivo RESTORE.sql, aplique-o no banco de dados de recuperação usando o script `restore_using_sql.sh`.

Vantagens:

- Permite revisar o conteúdo SQL antes de aplicar.
- Fácil de auditar ou ajustar comandos manualmente.

Desvantagens:

- O processo pode ser mais lento, especialmente para binlogs grandes.
- Pode falhar se o script SQL contiver comandos dependentes de tabelas inexistentes.


### 2. Por BINLOG (Aplicação direta dos binlogs)
Este método aplica os arquivos binlog diretamente no banco de dados de recuperação, sem convertê-los para SQL.

Passos:

1. Execute o script `restore_using_binlog_datetime.sh` ou `restore_using_binlog_position.sh` para aplicar os binlogs diretamente.

Vantagens:

- Mais rápido, pois os comandos são enviados diretamente ao MySQL.
- Menor uso de disco, já que não gera arquivos intermediários.

Desvantagens:

- Menos controle sobre o que será aplicado.
- Difícil auditar ou corrigir erros caso algo dê errado.
- Se houver falha no meio do processo, pode ser difícil identificar o ponto exato.

## 7. Validando a recuperação de dados

Após aplicar os binlogs ou o arquivo SQL, valide os dados recuperados no banco de dados de recuperação.

Execute o script `select_tables_recovery.sh` para consultar as tabelas e verificar os dados.

### Observações Importantes:

Ambiente Real:

Em um ambiente real, é essencial fazer backups dos dados recuperados antes de restaurá-los na base de produção.

Certifique-se de testar o processo de recuperação em um ambiente de teste antes de aplicá-lo em produção.

Logs e Depuração:

Se ocorrerem erros durante a recuperação, verifique os logs do MySQL no contêiner de recuperação:

Use o script `binlog_preview.sh` para inspecionar os eventos registrados nos binlogs e identificar o ponto exato de recuperação.