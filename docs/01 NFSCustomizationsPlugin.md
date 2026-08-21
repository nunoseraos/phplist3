# NFSCustomizationsPlugin

Documento canónico das customizações NFS ao phpList e das diferenças entre os overlays. A integração atual usa phpList `3.7.0` e `NFSCustomizationsPlugin` `0.3.0`.

## Variantes

Existem três plugins independentes, todos na versão `0.3.0`. Saldo e SegurosMais são os overlays operacionais da 3.7.0; SimulaçãoCreditoPessoal fica preservado como referência legada:

```text
deploy/segurosmais/lists/admin/plugins/
deploy/simulacaocreditopessoal/lists/admin/plugins/
deploy/saldo/lists/admin/plugins/
```

Cada pasta contém:

```text
NFSCustomizationsPlugin.php
NFSCustomizationsPlugin/nfs_shortcuts.php
```

Nunca se deve publicar mais do que um overlay na mesma instalação. `deploy/common/root/` contém o núcleo para FTP e deve ser sobreposto apenas pela variante do site de destino.

As fontes remotas verificadas antes da separação eram SegurosMais `0.2.1` e SimulaçãoCreditoPessoal `0.2.2`. Os `nfs_shortcuts.php` eram idênticos. A variante `saldo` começou como cópia independente da variante SimulaçãoCreditoPessoal para poder divergir futuramente.

## Diferenças entre variantes

### Depois da confirmação double opt-in

O retorno é fixo por instalação. Não recebe nem consulta o ID da subscribe page:

| Variante | Destino de todas as confirmações |
|---|---|
| SegurosMais | `https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/` |
| SimulaçãoCreditoPessoal | `https://saldo.pt/simuladores/obrigado-confirmacao` |
| Saldo | `https://saldo.pt/simuladores/obrigado-confirmacao` |

O hook comum em `public_html/lists/index.php` chama `confirmationRedirectUrl()` sem argumentos.

### Imediatamente depois da submissão

Estes redirects continuam filtrados por subscribe page porque correspondem a resultados diferentes:

| Variante | Page | Destino |
|---|---:|---|
| SegurosMais | `5` | `https://segurosmais.pt/resultado/automovel/` |
| SegurosMais | `6` | `https://segurosmais.pt/resultado/saude/` |
| SegurosMais | `7` | `https://segurosmais.pt/resultado/dentario/` |
| SegurosMais | `8` | `https://segurosmais.pt/resultado/vida/` |
| SegurosMais | `9` | `https://segurosmais.pt/resultado/bem-vindo/` |
| SegurosMais | `10` | `https://segurosmais.pt/resultado/casa/` |
| SegurosMais | `11` | `https://segurosmais.pt/resultado/protecao-ao-credito/` |
| SegurosMais | `12` | `https://segurosmais.pt/resultado/credito-pessoal/` |
| SegurosMais | `13` | `https://segurosmais.pt/resultado/credito-consolidado/` |
| SegurosMais | `18` | `https://creditoacertado.pt/resultado/credito-pessoal/` |
| SimulaçãoCreditoPessoal | `14` | `https://creditosim.pt/resultado/credito-pessoal/` |
| SimulaçãoCreditoPessoal | `18` | `https://creditoacertado.pt/resultado/credito-pessoal/` |
| Saldo | `14` | `https://creditosim.pt/resultado/credito-pessoal/` |
| Saldo | `18` | `https://creditoacertado.pt/resultado/credito-pessoal/` |

Uma page não incluída conserva o conteúdo normal de agradecimento do phpList.

### Supressão do email adicional pós-confirmação

O plugin impede o email genérico `confirmationsubject:*`/`confirmationmessage:*` e esconde os respetivos campos no editor:

- SegurosMais: pages `1`, `5` a `13` e `18`;
- SimulaçãoCreditoPessoal: pages `14`, `18`, `999` e `1000`.
- Saldo: começa com as pages `14`, `18`, `999` e `1000`, numa cópia independente.

## Todas as customizações do plugin

### Atalhos administrativos

Adiciona `NFS Shortcuts` ao menu Subscribers com ligações para pesquisa e histórico de subscritores, relatórios, campanhas, autoresponders, estatísticas, Event Log, subscribe pages e reconcile.

### Validação do código postal

Valida `attribute9` quando preenchido e submetido. O formato obrigatório é `NNNN-NNN`; vazio continua permitido.

### Redirect depois da submissão

`parseThankyou()` aplica o mapa da variante e inclui redirect JavaScript, fallback `noscript` e link manual.

### Confirmação double opt-in

`subscriberConfirmation()` marca a confirmação na sessão para suprimir o email adicional nas pages configuradas. `hidePostConfirmationMessageFields()` esconde os campos dessa mensagem. `confirmationRedirectUrl()` devolve sempre o destino fixo da variante.

### Remoção da assinatura phpList

`parseOutgoingTextMessage()` e `parseOutgoingHTMLMessage()` removem as variantes conhecidas de `powered by phpList` dos emails enviados.

### Auto-supressão de hard failures SMTP

No início de `processqueue`, analisa o Event Log e coloca automaticamente em blacklist destinatários com falhas definitivas repetidas. Também atualiza o subscritor e regista a operação.

Valores por omissão: `2` falhas numa janela de `168` horas, analisando no máximo `2000` eventos.

### Monitorização da fila

Deteta autoresponders suspensos e campanhas presas em `inprocess`, envia alerta e usa hash/timestamp para evitar repetições.

Valores por omissão: campanha presa após `6` horas e cooldown de `360` minutos.

## Constantes suportadas no config.php

| Constante | Função | Omissão |
|---|---|---|
| `NFS_VALIDATE_ATTRIBUTE9` | Validação do código postal | `true` |
| `NFS_REMOVE_PHPLIST_SIGNATURE` | Remoção da assinatura phpList | `true` |
| `NFS_THANKYOU_REDIRECTS` | Substitui o mapa completo pós-submissão | mapa da variante |
| `NFS_SUPPRESS_POST_CONFIRMATION_EMAIL` | Supressão do email adicional | `true` |
| `NFS_SUPPRESS_POST_CONFIRMATION_EMAIL_PAGES` | Substitui as pages da supressão | pages da variante |
| `NFS_AUTO_SUPPRESS_HARD_FAILS` | Auto-supressão SMTP | `true` |
| `NFS_AUTO_SUPPRESS_THRESHOLD` | Limiar de falhas | `2` |
| `NFS_AUTO_SUPPRESS_WINDOW_HOURS` | Janela de análise | `168` |
| `NFS_AUTO_SUPPRESS_MAX_SCAN` | Máximo de eventos | `2000` |
| `NFS_QUEUE_ALERTS_ENABLED` | Alertas da fila | `true` |
| `NFS_QUEUE_ALERT_EMAIL` | Destinatário dos alertas | endereço definido no plugin |
| `NFS_QUEUE_STUCK_HOURS` | Idade de campanha presa | `6` |
| `NFS_QUEUE_ALERT_COOLDOWN_MINUTES` | Cooldown entre alertas iguais | `360` |

O destino depois do opt-in não tem override: faz parte da identidade do artefacto. `NFS_SITE_PROFILE`, `NFS_CONFIRMATION_REDIRECT_URL` e `NFS_CONFIRMATION_REDIRECTS` não são usados nas variantes `0.3.0`.

## Integração com o core phpList

O plugin depende destes hooks mantidos no fork:

- `admin/subscribelib2.php`: validação e redirect pós-submissão;
- `index.php`: confirmação do subscritor e redirect final;
- `admin/sendemaillib.php`: remoção da assinatura;
- `admin/spageedit.php`: ocultação dos campos da mensagem suprimida;
- `admin/connect.php`: atalhos administrativos;
- `processqueue`: hard failures e monitorização da fila.

Estes pontos foram revistos contra o código upstream e o package de produção 3.7.0. Os hooks genéricos de `subscribelib2.php`, `sendemaillib.php`, `defaultplugin.php` e `processqueue.php` já existem no package. Continuam a ser necessários cinco patches NFS próprios:

| Ficheiro | Finalidade | Decisão 3.7.0 |
|---|---|---|
| `admin/connect.php` | atalhos NFS e correção do `pi` em Recently visited | preservar |
| `admin/lib.php` | não tentar notificação de login sem email de destino | preservar |
| `admin/pluginlib.php` | incluir o plugin NFS nos plugins auto-ativáveis | preservar |
| `admin/spageedit.php` | esconder os campos da mensagem pós-confirmação | reaplicado sobre o código 3.7.0 |
| `index.php` | redirect final depois do double opt-in | preservar |

O build aplica ainda `admin/bouncerules.php` e `admin/massremove.php` da árvore upstream 3.7.0 porque contêm verificações CSRF posteriores ao conteúdo do package de produção. `admin/init.php` e `admin/structure.php` ficam sempre nas variantes geradas do package; isto garante que o admin apresenta a versão `3.7.0` sem depender de procurar um ficheiro `VERSION` por caminho relativo.

Aplica também `admin/CsvReader.php`: em PHP 8.2, o código oficial deixa de reconhecer ficheiros CSV com line endings `CR`. A correção normaliza apenas separadores de registo, preserva quebras dentro de campos entre aspas e passou os 19 testes PHPUnit, incluindo CR, CRLF e LF.

## Deployment e verificação

1. Confirmar as distribuições oficiais verificadas em `upstream-packages/` e executar `./scripts/build-nfs-site-artifacts.sh`; são gerados o núcleo `deploy/common/root/` e o manifesto `deploy/common.sha256`.
2. Executar `./tests/phplist_370_upgrade_test.sh`, `./tests/run-nfs-site-overlays-test.sh`, `./tests/nfs_upgrade_checklist_test.sh` e `./tests/nfs_artifacts_test.sh`.
3. Confirmar o `config.php` privado em `deploy/<instalação>/lists/config/`. O núcleo exclui esse ficheiro; `config_extended.php` permanece como referência comum porque não é carregado automaticamente.
4. Confirmar o conjunto completo `lists/admin/plugins/` no overlay. Esta pasta não pertence ao núcleo porque as instalações têm versões diferentes e requisitos PHP distintos.
5. Fazer lint do núcleo e dos overlays com a versão PHP real de cada site. As dependências incluídas no package phpList 3.7.0 exigem efetivamente PHP 8.2 ou superior.
6. Obter backups verificáveis da pasta remota e da base de dados antes do primeiro upload.
7. Publicar o conteúdo de `deploy/common/root/` e depois exatamente um dos overlays `segurosmais` ou `saldo`.
8. Confirmar no admin `phpList version 3.7.0`, as proteções CSRF, o nome do plugin específico e apenas o URL opt-in desse site.
9. Testar submissão, email de opt-in, confirmação, redirect final, ausência do email adicional, campanha de teste, fila e bounces.

Os testes automatizados carregam as classes operacionais reais em PHP 8.2, confirmam os destinos fixos e verificam que cada mapa pós-submissão rejeita uma page exclusiva da outra variante. Foi ainda executado lint de todos os ficheiros dos plugins: 677 ficheiros de Saldo em PHP 8.2 e 624 de SegurosMais em PHP 8.3.

## Estado de produção

Em `2026-08-21`, Saldo e SegurosMais ficaram compostos e validados localmente contra phpList 3.7.0, sem qualquer acesso a produção. SimulaçãoCreditoPessoal não recebeu novo deploy. A publicação de Saldo depende primeiro de confirmar PHP 8.2 ou superior no alojamento e de seguir `docs/DEPLOY-PHPLIST-3.7.0.md`.

O núcleo usa o package oficial SourceForge `phplist-3.7.0.tgz`, SHA-256 `614475133e5c0983f0021b95386a5f03ffe44f4640dd1079a1b083b7def57437`. A distribuição oficial 3.6.17 também foi obtida e validada para a comparação, SHA-256 `bcc790fd451862f03f2a0476d8ce9e8a794211d946613e0f7415dd4cde08e3d8`.
