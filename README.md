# Sprint Ágil – Refatoração de Banco de Dados: Pet Shop e Veterinária

Exercício 6 (1CDD) – Cenário 13 · Dupla: [Nome A] e [Nome B]

## Problema
A tabela `Animais` guardava vacinas e banhos em colunas numeradas (`vacina1..3`, `banho1..3`) e repetia os dados do tutor em cada animal.

## Solução
Modelo normalizado (3FN) com as tabelas `tutores`, `especies`, `racas`, `animais`, `vacinas`, `aplicacoes_vacina`, `servicos` e `atendimentos_servico`, com PK, FK, UNIQUE, CHECK e 6 índices.

## Arquivos
- `schema_e_consultas.sql`: estrutura antiga, novo modelo, migração dos dados, novos registros e consultas.
- `validacao.sql`: tabela única que confere a migração (esperado x obtido).

## Como executar
1. Abrir https://sqliteonline.com e escolher **SQLite**.
2. Colar e rodar `schema_e_consultas.sql`.
3. Colar e rodar `validacao.sql` (todas as linhas devem mostrar OK).

## Kanban
[colar link do Trello/Jira]
