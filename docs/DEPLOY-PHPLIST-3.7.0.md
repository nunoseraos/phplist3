# Deploy manual — phpList 3.7.0

Este documento descreve a atualização manual de `simulacoes.saldo.pt` por FTP. Os ficheiros foram preparados e testados localmente; nenhuma operação foi executada no servidor.

## Estado e pré-requisito obrigatório

- Núcleo anterior: phpList 3.6.17.
- Núcleo preparado: phpList 3.7.0.
- Package: distribuição completa oficial `phplist-3.7.0.tgz`.
- SHA-256 verificado: `614475133e5c0983f0021b95386a5f03ffe44f4640dd1079a1b083b7def57437`.
- PHP declarado pelo package: `^8.1`; dependências incluídas exigem efetivamente PHP 8.2+.
- Última versão PHP conhecida em Saldo antes deste trabalho: 7.4.

**Não iniciar o upload enquanto o alojamento de Saldo não estiver configurado para PHP 8.2 ou superior.** Apesar de o `composer.json` raiz aceitar 8.1, o `vendor/composer/platform_check.php` oficial bloqueia versões anteriores a 8.2. Recomenda-se PHP 8.2 ou 8.3. Depois da mudança, abrir temporariamente uma página `phpinfo` pelo painel do alojamento ou a informação PHP do admin e confirmar a versão; remover qualquer ficheiro `phpinfo` público logo após a verificação.

O ficheiro local `deploy/common/VERSION` é metadado do artefacto. Não é o mecanismo usado pelo phpList em produção e não deve ser enviado. O package contém `lists/admin/init.php` com a versão 3.7.0 já gerada.

## Caminhos usados

| Conteúdo | Pasta local | Destino remoto Saldo |
|---|---|---|
| Núcleo comum | `deploy/common/root/` | `/public_html/simulacoes/` |
| Overlay Saldo | `deploy/saldo/` | `/public_html/simulacoes/` |
| Configuração | `deploy/saldo/lists/config/config.php` | `/public_html/simulacoes/lists/config/config.php` |
| Plugins Saldo | `deploy/saldo/lists/admin/plugins/` | `/public_html/simulacoes/lists/admin/plugins/` |

No cliente FTP, a raiz apresentada pode começar diretamente em `/simulacoes/` ou mesmo na raiz do subdomínio. O diretório certo é aquele que já contém a pasta remota `lists/` usada por `https://simulacoes.saldo.pt/lists/`.

## Backup obrigatório

Antes de alterar PHP, apagar ou enviar ficheiros:

1. Exportar a base de dados completa pelo painel do alojamento/phpMyAdmin, incluindo estrutura, dados, triggers e opções `DROP TABLE`. Guardar o dump com data e confirmar que não tem zero bytes.
2. Descarregar por FTP a pasta remota completa `/public_html/simulacoes/lists/` para uma pasta local datada. Não basta guardar apenas `config.php`.
3. Guardar separadamente:
   - `lists/config/config.php`;
   - toda a pasta `lists/admin/plugins/`;
   - `.htaccess` existentes na raiz do subdomínio e em `lists/`;
   - `uploadimages/`, `lists/uploadimages/` ou o diretório indicado por `UPLOADIMAGES_DIR`, se existir;
   - o diretório indicado por `$attachment_repository`, se os anexos estiverem ativos e o diretório for acessível;
   - qualquer ficheiro ou pasta criado manualmente dentro da instalação.
4. Registar a versão PHP atual, as extensões ativas e os cron jobs de `processqueue`/`processbounces`.
5. Verificar que o backup FTP contém `lists/admin/init.php`, `lists/base/vendor/`, `lists/config/config.php` e `lists/admin/plugins/`.

As passwords existentes no `config.php` ou no painel nunca devem ser copiadas para documentação ou para Git.

## Elementos persistentes: não apagar

Não apagar nem substituir por versões genéricas:

- `lists/config/config.php` — usar apenas a cópia própria de `deploy/saldo/`;
- `lists/admin/plugins/` — não apagar em bloco; é o conjunto específico de Saldo;
- uploads e imagens criados pelo utilizador (`uploadimages/`, `lists/uploadimages/` ou caminho configurado);
- repositório de anexos configurado;
- dumps, logs ou ficheiros operacionais guardados fora do package;
- cron jobs e credenciais do alojamento;
- base de dados.

`config_extended.php` é apenas a referência oficial de opções. O phpList não o carrega automaticamente e ele não substitui `config.php`.

## Limpeza antes do upload

A comparação direta entre os packages oficiais 3.6.17 e 3.7.0 não encontrou ficheiros comuns removidos. Contudo, o gerador NFS anterior sobrepunha a árvore de desenvolvimento e podia ter deixado dependências antigas e ficheiros de desenvolvimento no servidor. Para tornar a limpeza exaustiva sem apagar 9 650 ficheiros um a um, executar estas operações **depois do backup e antes do upload do núcleo**:

```text
/public_html/simulacoes/lists/base/vendor/              → APAGAR (será recriada integralmente pelo núcleo 3.7.0)
/public_html/simulacoes/lists/admin/tests/               → APAGAR, se existir
/public_html/simulacoes/lists/admin/ui/default/          → APAGAR, se existir
/public_html/simulacoes/lists/base/.github/              → APAGAR, se existir
/public_html/simulacoes/lists/base/.travis.yml           → APAGAR, se existir
/public_html/simulacoes/lists/base/config/parameters.php → APAGAR, se existir
/public_html/simulacoes/lists/base/public/app.php        → APAGAR, se existir
/public_html/simulacoes/lists/base/public/app_dev.php    → APAGAR, se existir
/public_html/simulacoes/lists/base/public/app_test.php   → APAGAR, se existir
/public_html/simulacoes/lists/base/var/.htaccess         → APAGAR, se existir
```

Não apagar `lists/base/` nem `lists/base/config/`, `lists/base/public/` ou `lists/base/var/` completos. A 3.7.0 continua a usar essas pastas.

## Upload do núcleo comum

1. No painel do alojamento, interromper temporariamente os cron jobs da fila e dos bounces. Não iniciar campanhas durante a manutenção.
2. No computador, abrir exatamente:

   ```text
   /Users/nunosoares/Dev/NFSlist/deploy/common/root/
   ```

3. Nessa pasta existe `lists/`. Selecionar a própria pasta `lists`.
4. No FTP, entrar exatamente na raiz web de Saldo:

   ```text
   /public_html/simulacoes/
   ```

5. Enviar a pasta local `lists` para essa raiz. Quando o cliente perguntar, escolher **Overwrite/Substituir sempre** para todos os ficheiros da fila.
6. Confirmar que o resultado remoto continua a ser `/public_html/simulacoes/lists/`. Não enviar `lists` estando já dentro de `lists/`, porque isso criaria `lists/lists/`.
7. Não enviar:
   - a pasta local `common`;
   - a pasta local `root`;
   - `deploy/common/VERSION`;
   - `deploy/common.sha256`;
   - `upstream-packages/`;
   - qualquer pasta de outro site.

O núcleo comum não contém `lists/config/config.php` nem a pasta `lists/admin/plugins/`; por isso o upload não deve apagar esses elementos persistentes.

## Aplicar o overlay Saldo

1. No computador, abrir exatamente:

   ```text
   /Users/nunosoares/Dev/NFSlist/deploy/saldo/
   ```

2. Selecionar a pasta local `lists`.
3. No FTP, permanecer em:

   ```text
   /public_html/simulacoes/
   ```

4. Enviar a pasta `lists` e escolher **Overwrite/Substituir sempre**.
5. Confirmar no servidor:
   - `lists/config/config.php` existe e tem a data/tamanho esperados da variante Saldo;
   - `lists/admin/plugins/NFSCustomizationsPlugin.php` existe;
   - não existe `lists/index.php` proveniente do overlay — esse ficheiro deve ser o do núcleo comum;
   - não foi criada uma pasta `lists/lists/`.

Nunca aplicar `deploy/segurosmais/` ou `deploy/simulacaocreditopessoal/` nesta instalação.

## Configuração 3.7.0

Nenhuma alteração silenciosa foi feita aos `config.php` reais.

| Parâmetro | Saldo/SegurosMais | Recomendação | Obrigatório? |
|---|---|---|---|
| PHP | último Saldo conhecido abaixo de 8.2 | configurar PHP 8.2+ antes do upload | sim |
| `$database_connection_ssl` | já declarado | conservar o valor atual | não alterar |
| `$database_connection_ssl_force` | ausente | definir apenas se MySQL usar `require_secure_transport=ON` | não, salvo exigência do servidor DB |
| `$database_connection_ssl_ca` | ausente | indicar o CA apenas quando SSL da BD for usado e validado | não, salvo SSL da BD |
| `TEST_EMAIL_ALWAYS_TO` | ausente | opcional; limita emails de teste a um endereço | não |

Se a base de dados é local e não exige TLS, não adicionar os dois novos parâmetros SSL só por existirem no exemplo.

## Plugins analisados

“Sintaxe OK” significa que todos os ficheiros passaram no interpretador previsto (Saldo em PHP 8.2; SegurosMais em PHP 8.3); funcionalidades que dependem da BD, cron, SMTP, browser ou serviços externos continuam a precisar do teste pós-deploy.

| Plugin | Saldo | SegurosMais | Compatibilidade 3.7.0 / ação |
|---|---:|---:|---|
| `NFSCustomizationsPlugin` | 0.3.0 | 0.3.0 | testes comportamentais e lint OK; manter |
| `Autoresponder` | 3.2.0 | 3.6.4 | sintaxe OK; testar cron/autoresponders |
| `BounceStatisticsPlugin` | 2.1.3 | 2.3.0 | sintaxe OK; testar leitura de bounces |
| `CKEditorPlugin` | 2.7.1 | 2.6.9 | sintaxe OK; package traz 2.8.2; manter por agora e testar edição/envio antes de atualizar |
| `CampaignsPlugin` | 2.3.2 | 2.4.4 | sintaxe OK; testar gestão de campanhas |
| `CaptchaPlugin` | 2.4.0 | 2.4.0 | sintaxe OK; testar página pública se ativo |
| `CommonPlugin` | 3.29.1 | 3.33.0 | sintaxe OK; package traz 3.35.2; testar dependentes e CSS inline |
| `MessageStatisticsPlugin` | 2.1.26 | 2.4.2 | sintaxe OK; testar relatórios |
| `SegmentPlugin` | 2.13.2 | 2.13.2 | sintaxe OK; package traz 2.14.1; testar segmentos |
| `SubscribersPlugin` | 2.19.1 | 2.38.0 | sintaxe OK; testar pesquisa/histórico |
| `UpdaterPlugin` | 1.2.1 | 1.2.1 | sintaxe OK; manter desativado para não substituir o fork NFS; package traz 1.2.2 |
| `HousekeepingPlugin` | 1.3.4 | — | Saldo: sintaxe OK; testar tarefas antes de agendar |
| `RecaptchaPlugin` | 1.5.0 | — | Saldo: sintaxe OK; testar chaves/fluxo se ativo |
| `campaignslicer` | 0.2 | 0.2 | sintaxe OK; teste funcional necessário |
| `dateplaceholder` | 0.2 | 0.2 | sintaxe OK; enviar campanha de teste |
| `disposablemailblock` | 0.1 | 0.1 | sintaxe OK; testar apenas se ativo |
| `domainthrottlemap` | 0.1 | 0.1 | sintaxe OK; testar fila se ativo |
| `embedremoteimages` | 0.1 | 0.1 | sintaxe OK; testar campanha com imagem remota |
| `inviteplugin` | 0.4 | 0.4 | sintaxe OK; teste funcional necessário |
| `restapi` | 3 | 3 | sintaxe OK; testar autenticação e endpoints se usados |
| `restapi_test` | sem versão | sem versão | manter desativado; não usar em produção |
| `subjectLinePlaceholdersPlugin` | 1.0a4 | 1.0a4 | sintaxe OK; enviar campanha de teste |
| `fckphplist` | 0.2 | — | Saldo: legado; manter desativado se CKEditor for o editor ativo |

Não foram introduzidos CKEditor5, Imap2 ou outros plugins novos do package, porque isso mudaria comportamento específico dos sites sem necessidade para a atualização do núcleo.

## Ordem exata da atualização de Saldo

1. Confirmar no painel do alojamento que Saldo usa PHP 8.2+ e que `mysqli`, `mbstring`, `iconv` e `curl` continuam disponíveis.
2. Fazer e verificar os backups de BD e ficheiros descritos acima.
3. Interromper os cron jobs `processqueue` e `processbounces`; anotar os comandos/horários para os repor.
4. Evitar logins e campanhas durante a janela; usar o modo de manutenção do alojamento, se existir, sem alterar o `config.php` para inventar uma opção.
5. Executar a limpeza pré-upload indicada, começando por `lists/base/vendor/`.
6. Enviar `deploy/common/root/lists` para `/public_html/simulacoes/`, com overwrite.
7. Enviar `deploy/saldo/lists` para `/public_html/simulacoes/`, com overwrite.
8. Confirmar por FTP o `config.php`, o conjunto de plugins e a inexistência de `lists/lists/`.
9. Abrir `https://simulacoes.saldo.pt/lists/admin/` e autenticar. O rodapé/cabeçalho deve indicar `phpList version 3.7.0`, nunca `dev`.
10. Na página inicial do admin, procurar “Your database is out of date…”/“Upgrade”. Se aparecer, seguir a ligação. Em alternativa abrir `https://simulacoes.saldo.pt/lists/admin/?page=upgrade`.
11. Na página “Upgrade phpList Database”, confirmar que a origem é 3.6.17 e o alvo é 3.7.0; clicar **Upgrade** uma única vez e esperar por **Upgrade successful**. Não fechar nem recarregar enquanto estiver a trabalhar.
12. Se a página disser que a BD já está na versão correta, não forçar. Se disser que outro processo está a atualizar, não usar **Force Upgrade** sem confirmar que não há processo ativo.
13. Ir a **Config → Manage plugins** (`?page=plugins`). Confirmar `NFS Customizations - Saldo`, versão 0.3.0, ativo e sem falha de dependências. Confirmar que `UpdaterPlugin`, `restapi_test` e `fckphplist` ficam desativados salvo uso deliberado.
14. Ir a **Config → Subscribe pages** (`?page=spage`). Abrir as pages 14 e 18 e confirmar que os campos da mensagem adicional pós-confirmação permanecem escondidos.
15. Abrir a página pública de subscrição usada por Saldo, submeter um endereço de teste e confirmar o redirect pós-submissão correspondente à page.
16. Abrir o email double opt-in, clicar uma vez e confirmar o redirect final para `https://saldo.pt/simuladores/obrigado-confirmacao`. Confirmar que não chega um segundo email genérico pós-confirmação.
17. Usar o link de unsubscribe do email de teste e confirmar que o estado do subscritor muda corretamente.
18. Em **Campaigns**, criar/enviar uma campanha de teste apenas para uma lista de teste. Validar HTML, texto, assunto/placeholders, imagens e ausência da assinatura phpList removida pelo plugin.
19. Reativar primeiro o cron da fila. Confirmar em **System → Send the queue**/`?page=processqueue` e no Event Log que termina sem erros; verificar alertas NFS de fila/autoresponder.
20. Se bounces forem usados, reativar o respetivo cron e confirmar em `?page=processbounces` que o mailbox é lido sem erro.
21. Ir a **System → Event log** (`?page=eventlog`) e procurar erros PHP, SMTP, plugins e BD. Verificar também os logs do alojamento.
22. Retirar a manutenção apenas depois dos testes; manter os backups até terminar o período de observação.

## Rollback de Saldo

### Antes de executar o upgrade da base de dados

Se o site/admin falhar antes de a BD ser alterada:

1. Parar novamente os cron jobs.
2. Retirar os ficheiros 3.7.0 da pasta remota `lists/` substituindo-os pela cópia FTP completa feita antes da atualização.
3. Restaurar explicitamente o `config.php`, plugins, `.htaccess` e ficheiros persistentes do backup.
4. Repor a versão PHP anterior apenas se ela era compatível com a cópia restaurada.
5. Abrir o admin e confirmar phpList 3.6.17; depois reativar os cron jobs.

Como a BD ainda não foi migrada, não é necessário restaurar o dump se nenhuma escrita ocorreu. Na dúvida, restaurar também a BD para manter ficheiros e dados do mesmo instante.

### Depois de iniciar ou concluir o upgrade da base de dados

Não executar phpList 3.6.17 contra uma BD parcial ou já marcada como 3.7.0.

1. Manter o site e os cron jobs parados.
2. Restaurar **simultaneamente** a pasta completa 3.6.17 e o dump da BD criado imediatamente antes do deploy.
3. Restaurar `config.php`, plugins, uploads/anexos e permissões.
4. Confirmar que o ficheiro e a BD são ambos 3.6.17 antes de voltar a abrir o site.
5. Só depois reativar os cron jobs e testar login, subscrição e envio.

Se o upgrade mostrar **Upgrade failed**, guardar a mensagem e os logs antes de restaurar. Não clicar repetidamente em Upgrade ou Force Upgrade.

### Falha isolada de plugin

Se o admin continuar acessível e apenas um plugin não essencial falhar, desativá-lo em **Config → Manage plugins**, guardar o erro e testar o núcleo. Para `NFSCustomizationsPlugin`, plugins de fila/autoresponder ou qualquer falha que afete subscrições/envios, interromper os cron jobs e considerar o rollback completo. Não substituir plugins por versões aleatórias durante a ocorrência.

## SegurosMais — preparado para atualização posterior

`deploy/common/root/ + deploy/segurosmais/` passou a composição local, os hooks e o isolamento de URLs. Todos os 624 ficheiros PHP dos plugins passaram lint em PHP 8.3. A variante NFS redireciona confirmações para `https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/` e conserva o mapa próprio de subscribe pages.

SegurosMais não foi publicado. Antes da atualização posterior devem ser repetidos backup, confirmação de PHP 8.2+, upgrade da BD e testes funcionais. Os plugins diferem de Saldo nas versões indicadas na tabela e não devem ser copiados entre sites.

## Resultado local

- **Saldo — PRONTO PARA DEPLOY MANUAL: NÃO**, enquanto PHP 8.2+ não estiver confirmado no alojamento. Os ficheiros locais estão preparados.
- Depois de cumprir o pré-requisito PHP: **PRONTO PARA DEPLOY MANUAL: SIM**, seguindo integralmente este documento.
- **SegurosMais — PREPARADO PARA DEPLOY POSTERIOR: SIM**, sem deploy efetuado.
- **VALIDAÇÃO NECESSÁRIA EM PRODUÇÃO:** PHP/extensões, upgrade real da BD, SMTP, cron/fila, bounces, integrações externas e testes funcionais dos plugins.

O núcleo inclui uma correção local para importação CSV com line endings `CR` em PHP 8.2. Os testes PHPUnit passaram com 19 testes e 26 assertions.
