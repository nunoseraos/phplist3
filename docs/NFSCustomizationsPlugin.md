# NFSCustomizationsPlugin

Documento canónico das customizações NFS ao phpList e das diferenças entre os dois artefactos de deployment.

## Variantes

Existem dois plugins independentes, ambos na versão `0.3.0`:

```text
deploy/segurosmais/public_html/lists/admin/plugins/
deploy/simulacaocreditopessoal/public_html/lists/admin/plugins/
```

Cada pasta contém:

```text
NFSCustomizationsPlugin.php
NFSCustomizationsPlugin/nfs_shortcuts.php
```

Nunca se devem publicar os dois overlays na mesma instalação. A base `public_html/lists` é comum; em staging, deve ser sobreposta apenas pela variante do site de destino.

As fontes remotas verificadas antes da separação eram SegurosMais `0.2.1` e SimulaçãoCreditoPessoal `0.2.2`. Os dois `nfs_shortcuts.php` eram idênticos.

## Diferenças entre variantes

### Depois da confirmação double opt-in

O retorno é fixo por instalação. Não recebe nem consulta o ID da subscribe page:

| Variante | Destino de todas as confirmações |
|---|---|
| SegurosMais | `https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/` |
| SimulaçãoCreditoPessoal | `https://saldo.pt/simuladores/obrigado-confirmacao` |

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

Uma page não incluída conserva o conteúdo normal de agradecimento do phpList.

### Supressão do email adicional pós-confirmação

O plugin impede o email genérico `confirmationsubject:*`/`confirmationmessage:*` e esconde os respetivos campos no editor:

- SegurosMais: pages `1`, `5` a `13` e `18`;
- SimulaçãoCreditoPessoal: pages `14`, `18`, `999` e `1000`.

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

Estes pontos devem ser revistos depois de cada merge com uma nova versão upstream do phpList.

## Deployment e verificação

1. Preparar staging a partir de `public_html/lists`.
2. Aplicar exatamente um overlay de `deploy/`.
3. Preservar `config/config.php`, `config/config_extended.php`, uploads e plugins externos do servidor.
4. Executar `./scripts/nfs-upgrade-checklist.sh`.
5. Executar `./tests/run-nfs-site-overlays-test.sh`.
6. Fazer lint PHP e backup remoto antes do upload.
7. Em staging, testar submissão, email de opt-in, confirmação, redirect final e ausência do email adicional.

Os testes automatizados carregam as duas classes reais em PHP 7.2, confirmam os destinos fixos e verificam que cada mapa pós-submissão rejeita uma page exclusiva da outra instalação.
