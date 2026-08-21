# Atualização NFSList — phpList 3.6.17 → 3.7.0

## Objetivo

Atualizar este repositório da versão **phpList 3.6.17 para phpList 3.7.0**, preservando integralmente a arquitetura existente de núcleo comum + overlays específicos de cada instalação.

As instalações relevantes são:

| Overlay | Instalação | Estado |
|---|---|---|
| `saldo` | `simulacoes.saldo.pt` | **Primeiro deploy / instalação de teste** |
| `segurosmais` | `escolhas.segurosmais.pt` | Preparar para 3.7.0, mas **não será atualizado já** |
| `simulacaocreditopessoal` | `escolhas.simulacaocreditopessoal.com` | Instalação a descontinuar; **não preparar novo deploy salvo necessidade técnica justificada** |

A atualização efetiva no servidor será feita **manualmente por mim através de FTP**.

Tu **NÃO tens autorização para fazer deploy, FTP, SSH, alterações em produção ou alterações nas bases de dados de produção**.

O teu trabalho termina na preparação e validação local dos ficheiros e na produção de instruções inequívocas para eu executar manualmente.

---

# 1. Antes de alterar qualquer coisa

Começa por garantir que tens consciência:

1. a estrutura atual do repositório;
2. a documentação existente em `docs/`;
3. os scripts de geração de deploy;
4. os testes;
5. `public_html/lists/`;
6. `upstream-packages/`;
7. `deploy/common/`;
8. os overlays:
   - `deploy/saldo/`;
   - `deploy/segurosmais/`;
   - `deploy/simulacaocreditopessoal/`;
9. os plugins existentes em cada instalação;
10. quaisquer patches ou hooks NFS aplicados ao phpList 3.6.17.

Não reinventes o processo de deploy sem existir uma razão técnica concreta.

---

# 2. Segurança antes da alteração

Antes de modificar ficheiros:

- confirma o estado do Git;
- identifica alterações locais ainda não integradas;
- não sobrescrevas trabalho existente;
- não uses `git clean`;
- não apagues ficheiros ignorados pelo Git;
- tem especial cuidado com `config.php`, plugins e outros ficheiros privados ignorados;
- identifica claramente quais os ficheiros NFS que diferem do phpList upstream 3.6.17.

Os `config.php` reais podem conter credenciais.

**Nunca apresentar, copiar para documentação, fazer commit ou expor credenciais.**

Se encontrares alterações locais não relacionadas com esta atualização, preserva-as.

Cria um ponto de recuperação Git adequado antes da atualização.

---

# 3. Obter phpList 3.7.0

Obtém a **distribuição oficial completa de produção do phpList 3.7.0** através da fonte oficial do projeto.

Não assumas que um source archive do GitHub equivale à distribuição completa.

Confirma:

- versão;
- origem;
- estrutura do package;
- dependências incluídas;
- checksum, se oficialmente disponibilizado.

Guarda a distribuição segundo a convenção já existente em:

`upstream-packages/`

Não alteres a política de `.gitignore` deste diretório sem necessidade.

---

# 4. Comparação obrigatória 3.6.17 → 3.7.0

Antes de integrar a nova versão, compara:

1. distribuição oficial 3.6.17;
2. nosso `public_html/lists/`;
3. distribuição oficial 3.7.0.

Quero distinguir claramente:

### A. Alterações upstream

Ficheiros que mudaram exclusivamente porque o phpList mudou entre 3.6.17 e 3.7.0.

### B. Customizações NFS

Ficheiros em que nós modificámos código upstream.

### C. Ficheiros específicos das instalações

Configurações, plugins ou outros elementos pertencentes aos overlays.

### D. Ficheiros obsoletos

Ficheiros existentes na distribuição 3.6.17 que **deixaram de existir na distribuição 3.7.0**.

Este último ponto é especialmente importante para o meu deploy por FTP.

Um cliente FTP que simplesmente "sobreponha" ficheiros **não elimina ficheiros que desapareceram da nova distribuição**.

Quero, portanto, que determines explicitamente se existem ficheiros ou diretórios que têm de ser eliminados manualmente do servidor.

---

# 5. Integrar phpList 3.7.0

Atualiza:

`public_html/lists/`

para que passe a representar o nosso núcleo baseado em **phpList 3.7.0**.

Preserva exclusivamente as customizações NFS que continuem necessárias.

Para cada patch/hook NFS existente:

1. identifica a finalidade;
2. verifica se continua necessário em 3.7.0;
3. verifica se o código upstream relacionado mudou;
4. reaplica-o de forma compatível quando necessário;
5. elimina-o apenas se conseguires demonstrar que deixou de ser necessário.

Não faças alterações específicas de Saldo ou SegurosMais no núcleo comum.

---

# 6. Compatibilidade dos plugins

Analisa os plugins existentes em:

`deploy/saldo/lists/admin/plugins/`

e

`deploy/segurosmais/lists/admin/plugins/`

Verifica a compatibilidade com phpList 3.7.0 e com a versão PHP prevista nas respetivas instalações.

Não atualizes plugins cegamente apenas porque existe uma versão mais recente.

Para cada plugin, determina:

- versão existente;
- se funciona com phpList 3.7.0;
- se necessita atualização;
- se existe alguma alteração incompatível;
- se a nossa customização depende do comportamento atual.

Dedica atenção especial a:

`NFSCustomizationsPlugin.php`

porque contém comportamento específico nosso.

---

# 7. Configurações

Não substituas os `config.php` específicos das instalações por configurações genéricas do phpList 3.7.0.

Compara, contudo, o sistema de configuração da 3.7.0 com o da 3.6.17.

Determina se apareceram:

- novas opções relevantes;
- opções removidas;
- opções renomeadas;
- alterações de defaults;
- configurações necessárias à compatibilidade.

Se alguma alteração for recomendável no `config.php` de Saldo ou SegurosMais, **não a faças silenciosamente**.

Documenta:

- parâmetro;
- valor atual, sem revelar segredos;
- alteração proposta;
- razão;
- se é obrigatória ou opcional.

---

# 8. Gerar os novos deploys

Depois de o núcleo estar corretamente atualizado para 3.7.0, usa/adapta os mecanismos existentes para gerar novamente:

`deploy/common/`

O ficheiro:

`deploy/common/VERSION`

deve identificar inequivocamente a versão **3.7.0**.

Prepara e valida a composição:

### Saldo

`deploy/common/`  
+  
`deploy/saldo/`

### SegurosMais

`deploy/common/`  
+  
`deploy/segurosmais/`

Não precisamos neste momento de preparar um deploy operacional para `simulacaocreditopessoal`, porque essa instalação será descontinuada, salvo se existir uma dependência técnica do processo atual que torne isso inevitável.

Se existir, explica-a antes de alterar o processo.

---

# 9. Testes

Executa todos os testes existentes.

Acrescenta testes quando forem necessários para cobrir alterações introduzidas pela migração 3.6.17 → 3.7.0.

Valida pelo menos:

- integridade estrutural do package;
- versão correta;
- ausência de `config.php` errado no núcleo;
- isolamento dos overlays;
- plugins;
- hooks NFS;
- geração de `deploy/common/`;
- composição Saldo;
- composição SegurosMais;
- inexistência de credenciais versionadas;
- inexistência de ficheiros 3.6.17 que tenham sobrevivido indevidamente ao processo de geração.

Se algum teste falhar, investiga a causa.

Não contornes testes para obter um resultado verde.

---

# 10. Não fazer deploy

**PARA AQUI no que respeita a qualquer servidor.**

Não:

- ligar por FTP;
- ligar por SFTP;
- ligar por SSH;
- fazer upload;
- apagar ficheiros remotos;
- executar migrations em produção;
- abrir o upgrade da instalação em produção;
- alterar bases de dados de produção.

Eu farei manualmente o primeiro deploy em:

**Saldo — `simulacoes.saldo.pt`**

SegurosMais só será atualizado posteriormente, depois de Saldo ter funcionado corretamente durante um período de teste.

---

# 11. Criar instruções FTP específicas

No final cria:

`docs/DEPLOY-PHPLIST-3.7.0.md`

Este documento destina-se **a mim**, não a outro programador.

Não quero instruções vagas como:

> "Fazer deploy do common e depois do overlay."

Quero uma receita operacional sem ambiguidades.

## 11.1 Saldo

Indica exatamente:

### Backup

O que devo guardar antes de começar:

- base de dados;
- `config.php`;
- plugins;
- outros ficheiros específicos que consideres necessários.

### Upload

Diz-me exatamente:

- que pasta local abrir;
- qual o diretório remoto correspondente;
- que ficheiros/pastas selecionar;
- se devo enviar conteúdo ou a própria pasta;
- quando devo escolher "overwrite";
- se devo usar sempre overwrite;
- que elementos **não devo enviar**.

Exemplo do nível de precisão pretendido:

> Abrir localmente `deploy/common/lists/`.
>
> No servidor entrar no diretório `.../lists/`.
>
> Selecionar TODO o conteúdo de `deploy/common/lists/` e enviar para o diretório remoto `lists/`, escolhendo **Overwrite/Substituir** quando o FileZilla perguntar por ficheiros já existentes.
>
> Não enviar a pasta local `lists` para dentro da pasta remota `lists`, pois isso produziria `lists/lists/`.

Isto é apenas um exemplo. Determina os caminhos reais a partir da estrutura do projeto.

Depois explica da mesma forma a aplicação de:

`deploy/saldo/`

por cima do núcleo.

### Eliminações

Produz uma lista **exaustiva** dos ficheiros/diretórios remotos que eu tenha de apagar porque existiam na 3.6.17 e deixaram de existir na 3.7.0.

Para cada elemento indica:

`caminho remoto → APAGAR`

Se não houver nenhum, escreve explicitamente:

> Não existem ficheiros da 3.6.17 que necessitem de eliminação manual.

Não assumas que o FTP elimina automaticamente ficheiros obsoletos.

### Ficheiros que nunca devem ser eliminados/sobrescritos inadvertidamente

Identifica explicitamente os elementos persistentes da instalação que não pertencem ao package de atualização.

Quero especial atenção a:

- configuração;
- plugins;
- uploads;
- anexos;
- temporários relevantes;
- ficheiros gerados pela instalação;
- quaisquer outros dados persistentes.

---

# 12. Ordem exata da atualização de Saldo

O documento deve terminar com uma checklist operacional numerada semelhante a:

1. colocar phpList em estado adequado para manutenção, se necessário;
2. fazer backup da BD;
3. fazer backup dos ficheiros específicos;
4. enviar núcleo 3.7.0;
5. eliminar ficheiros obsoletos identificados;
6. aplicar overlay Saldo;
7. confirmar `config.php`;
8. confirmar plugins;
9. abrir administração;
10. executar o mecanismo oficial de Upgrade do phpList, se solicitado;
11. confirmar versão;
12. testar subscrição;
13. testar double opt-in;
14. testar página de confirmação;
15. testar unsubscribe;
16. testar envio;
17. testar queue/cron;
18. testar bounces, se aplicável;
19. verificar logs;
20. retirar manutenção.

Mas não copies cegamente esta lista.

Adapta-a ao comportamento real do phpList 3.7.0 e à nossa instalação.

Para **cada passo que envolva interface phpList**, indica-me exatamente onde devo ir e o que devo esperar ver.

---

# 13. Rollback

Inclui também um procedimento de rollback para Saldo.

Quero saber exatamente o que fazer se:

- o site deixar de funcionar;
- o admin apresentar erro;
- o upgrade da BD falhar;
- os plugins falharem;
- os envios deixarem de funcionar.

Distingue:

### Rollback antes de alterar a base de dados

e

### Rollback depois de executar o upgrade da base de dados

Não assumas que repor apenas os ficheiros 3.6.17 é seguro depois de a BD ter sido migrada.

Se for necessário restaurar simultaneamente ficheiros + dump da BD, diz isso explicitamente.

---

# 14. Preparar SegurosMais, mas não implementar

Repete a análise necessária para garantir que:

`deploy/common/ + deploy/segurosmais/`

está preparado para phpList 3.7.0.

No entanto, **não precisamos ainda das instruções operacionais extensas de publicação de SegurosMais**.

No documento basta criar uma secção:

`## SegurosMais — preparado para atualização posterior`

indicando:

- resultado da validação;
- diferenças relevantes relativamente a Saldo;
- plugins/configurações que mereçam atenção;
- qualquer razão pela qual o procedimento de atualização não possa ser igual.

**Não fazer deploy.**

---

# 15. Relatório final

Quando terminares, apresenta-me um relatório com esta estrutura:

## Resultado

- versão anterior;
- versão nova;
- commit/branch utilizado;
- testes executados;
- resultado dos testes.

## Alterações NFS preservadas

Tabela:

| Ficheiro | Customização | Decisão | Razão |
|---|---|---|---|

## Plugins

| Instalação | Plugin | Versão | Compatível 3.7.0 | Ação |
|---|---|---:|---|---|

## Configuração

Alterações necessárias ou recomendadas.

## Ficheiros obsoletos

Lista dos ficheiros 3.6.17 que devem ser removidos durante o deploy.

## Saldo

Confirma explicitamente:

**PRONTO PARA DEPLOY MANUAL: SIM/NÃO**

Se SIM, aponta para:

`docs/DEPLOY-PHPLIST-3.7.0.md`

## SegurosMais

Confirma:

**PREPARADO PARA DEPLOY POSTERIOR: SIM/NÃO**

## Riscos ou questões pendentes

Não escondas incertezas.

Se alguma coisa não puder ser validada localmente, identifica-a como:

**VALIDAÇÃO NECESSÁRIA EM PRODUÇÃO**

e explica exatamente como eu a devo validar.

---

# 16. Regra fundamental

O objetivo não é simplesmente fazer com que o código indique "3.7.0".

O objetivo é obter uma atualização **reproduzível, auditável e reversível** de phpList 3.6.17 para 3.7.0, preservando as customizações NFS e permitindo que uma pessoa sem conhecimento detalhado da estrutura interna do phpList faça o deploy manual por FTP sem ter de adivinhar nenhuma operação.

Na dúvida entre uma operação destrutiva e preservar um ficheiro, **preserva e documenta a dúvida**.

Nunca executes uma operação destrutiva com base numa suposição.