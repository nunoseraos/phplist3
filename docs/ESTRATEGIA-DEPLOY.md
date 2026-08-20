# Estratégia de atualização e deploy do phpList

## Objetivo

Este repositório mantém um núcleo comum do phpList e um overlay independente para cada instalação. O núcleo é atualizado quando surge uma nova versão do phpList; os overlays preservam tudo o que é particular de cada site.

Instalações atuais:

- `segurosmais`: `escolhas.segurosmais.pt`;
- `simulacaocreditopessoal`: `escolhas.simulacaocreditopessoal.com`;
- `saldo`: `simulacoes.saldo.pt`.

## Estrutura

```text
NFSlist/
├── public_html/lists/                 # fonte canónica do núcleo comum
├── upstream-packages/                 # distribuição oficial completa, local e ignorada
├── deploy/
│   ├── common/                        # núcleo gerado, pronto para FTP
│   │   ├── VERSION
│   │   └── lists/
│   ├── segurosmais/
│   │   └── lists/
│   │       ├── config/config.php
│   │       └── admin/plugins/NFSCustomizationsPlugin.php
│   ├── simulacaocreditopessoal/
│   │   └── lists/
│   │       ├── config/config.php
│   │       └── admin/plugins/NFSCustomizationsPlugin.php
│   └── saldo/
│       └── lists/
│           ├── config/config.php
│           └── admin/plugins/NFSCustomizationsPlugin.php
├── scripts/                           # geração e validação dos deploys
├── tests/                             # testes das customizações
└── docs/                              # documentação NFS
```

`public_html/lists/` continua a ser a fonte canónica porque conserva a estrutura oficial do projeto phpList e permite integrar versões futuras com menos conflitos. Como os arquivos de código do GitHub não incluem todas as dependências de produção, o gerador começa numa distribuição oficial completa guardada em `upstream-packages/` e aplica por cima a fonte canónica atualizada. `deploy/common/` é o resultado pronto para FTP e não deve ser editado manualmente.

## Núcleo comum

O núcleo contém:

- todos os ficheiros oficiais da versão phpList em uso;
- dependências de produção, interface administrativa e idiomas incluídos na distribuição oficial;
- os hooks e patches NFS que são necessários em todas as instalações;
- bibliotecas, assets e restantes ficheiros iguais nos três sites.

O núcleo não contém:

- `lists/config/config.php`;
- toda a pasta `lists/admin/plugins/`, porque as instalações usam conjuntos e versões diferentes;
- uploads, anexos, ficheiros temporários ou dados criados em produção;
- credenciais de FTP.

O `config_extended.php` oficial pode permanecer no núcleo como documentação de referência. O phpList não o carrega automaticamente. Se alguma instalação passar a usar uma variante própria, essa variante deve ser colocada no respetivo overlay.

## Overlays das instalações

Cada pasta em `deploy/<instalação>/` reproduz os caminhos relativos do servidor. Pode conter qualquer ficheiro ou subpasta que seja diferente do núcleo comum.

Regras:

1. Cada instalação tem o seu próprio `config.php`.
2. Cada instalação tem uma cópia independente do plugin, mesmo quando duas variantes começam iguais.
3. Cada overlay contém o conjunto completo de plugins de produção compatível com essa instalação.
4. Uma alteração específica nunca é feita no núcleo comum.
5. Um ficheiro só passa para o núcleo quando for comprovadamente igual e necessário nas três instalações.
6. O conjunto de plugins de `saldo` começa igual ao de `simulacaocreditopessoal`, mas pode evoluir separadamente.

Os `config.php` reais ficam no workspace para poderem ser revistos e enviados por FTP, mas são ignorados pelo Git porque contêm passwords. Para documentar a estrutura sem expor segredos, cada instalação pode ter um `config.php.example` versionado.

## Deploy manual por FTP

Para qualquer instalação:

1. Copiar todo o conteúdo de `deploy/common/` para a raiz web da instalação.
2. Copiar todo o conteúdo de `deploy/<instalação>/` para a mesma raiz, aceitando a substituição de ficheiros.
3. Confirmar que o `config.php` e o plugin presentes no servidor pertencem à instalação correta.
4. Abrir o admin do phpList e executar `Upgrade` quando a versão da base de dados estiver atrasada.
5. Validar uma subscrição, a confirmação double opt-in, o redirect final e o envio de email.

Exemplo para `simulacoes.saldo.pt`:

```text
deploy/common/  -> raiz FTP de simulacoes.saldo.pt
deploy/saldo/   -> mesma raiz FTP, por cima do núcleo
```

## Atualização para uma nova versão do phpList

1. Obter e verificar a versão oficial pretendida.
2. Guardar em `upstream-packages/` a distribuição completa de produção e o respetivo checksum oficial.
3. Integrar a fonte da nova versão em `public_html/lists/`.
4. Reaplicar e testar apenas os hooks NFS comuns.
5. Não alterar automaticamente os overlays das instalações.
6. Gerar novamente `deploy/common/` e os manifestos de verificação.
7. Testar o núcleo com cada um dos três overlays.
8. Fazer backup de ficheiros e base de dados antes do deploy.
9. Publicar primeiro o núcleo e depois o overlay correto.

## Estado local e arquivo da limpeza

Em `2026-08-20`, o material histórico e redundante foi retirado do workspace e preservado em:

```text
/Users/nunosoares/Dev/NFSlist-backups/20260820-repository-cleanup/
```

O arquivo conserva os caminhos relativos, os ficheiros únicos da worktree removida e um manifesto SHA-256. A worktree temporária foi eliminada depois de o branch `upgrade/phplist-3.6.17` ser integrado em `custom`.

Permanecem no workspace:

- `public_html/lists/`, como fonte do núcleo comum;
- `upstream-packages/`, com a distribuição oficial completa usada pelo gerador;
- `deploy/common/` gerado e ignorado pelo Git;
- os três overlays e respetivos `config.php.example`;
- os conjuntos completos de plugins de produção nos respetivos overlays, ignorados pelo Git exceto o plugin NFS versionado;
- os `config.php` reais de SegurosMais e SimulaçãoCreditoPessoal, ignorados pelo Git;
- o caminho preparado para o novo `config.php` independente de Saldo;
- scripts, testes e os dois documentos canónicos;
- `_workbench/`, como documentação privada permanente do utilizador, sempre ignorada pelo Git.

Nunca executar `git clean` de forma genérica neste repositório: os `config.php` reais e outros ficheiros privados são deliberadamente ignorados pelo Git.
