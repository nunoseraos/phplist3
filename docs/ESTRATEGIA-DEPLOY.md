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

`public_html/lists/` continua a ser a fonte canónica porque conserva a estrutura oficial do projeto phpList e permite integrar versões futuras com menos conflitos. `deploy/common/` é gerado a partir dessa fonte para utilização por FTP e não deve ser editado manualmente.

## Núcleo comum

O núcleo contém:

- todos os ficheiros oficiais da versão phpList em uso;
- os hooks e patches NFS que são necessários em todas as instalações;
- bibliotecas, assets e restantes ficheiros iguais nos três sites.

O núcleo não contém:

- `lists/config/config.php`;
- a variante de `NFSCustomizationsPlugin`;
- uploads, anexos, ficheiros temporários ou dados criados em produção;
- credenciais de FTP.

O `config_extended.php` oficial pode permanecer no núcleo como documentação de referência. O phpList não o carrega automaticamente. Se alguma instalação passar a usar uma variante própria, essa variante deve ser colocada no respetivo overlay.

## Overlays das instalações

Cada pasta em `deploy/<instalação>/` reproduz os caminhos relativos do servidor. Pode conter qualquer ficheiro ou subpasta que seja diferente do núcleo comum.

Regras:

1. Cada instalação tem o seu próprio `config.php`.
2. Cada instalação tem uma cópia independente do plugin, mesmo quando duas variantes começam iguais.
3. Uma alteração específica nunca é feita no núcleo comum.
4. Um ficheiro só passa para o núcleo quando for comprovadamente igual e necessário nas três instalações.
5. O plugin de `saldo` começa igual ao de `simulacaocreditopessoal`, mas pode evoluir separadamente.

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
2. Integrá-la em `public_html/lists/`.
3. Reaplicar e testar apenas os hooks NFS comuns.
4. Não alterar automaticamente os overlays das instalações.
5. Gerar novamente `deploy/common/` e os manifestos de verificação.
6. Testar o núcleo com cada um dos três overlays.
7. Fazer backup de ficheiros e base de dados antes do deploy.
8. Publicar primeiro o núcleo e depois o overlay correto.

## Limpeza proposta do repositório

Depois de a nova estrutura estar criada e validada, podem ser removidos do workspace:

- `_inputs/` e `_workbench/`: ficheiros temporários já analisados;
- `inputs/`: ZIP e DOCX históricos já incorporados nas customizações;
- `legacy/`: snapshot 3.6.14 já analisado;
- `database/`: dump SQL e análise histórica; devem ser arquivados fora do repositório antes da remoção;
- `docs/backups/`: cópias antigas de plugin e configuração; devem ser arquivadas fora do repositório;
- `DOCUMENTACAO.md`: documento antigo e desatualizado;
- `doc/credito-saldo-migration-map.md`;
- `doc/estado-atual-e-upgrade-2-sites.md`;
- `doc/nfs-customizations-map.md`;
- `doc/phplist-upgrade-upload-runbook.md`;
- `doc/Log of events.pdf`;
- `docs/superpowers/`: planos internos de implementação já concluídos;
- todos os `.DS_Store`;
- a estrutura antiga `deploy/*/public_html/lists`, depois de migrada para `deploy/*/lists`;
- o plugin genérico em `public_html/lists/admin/plugins/NFSCustomizationsPlugin*`, depois de as três variantes estarem nos overlays;
- a worktree temporária `.worktrees/NFSlist-phplist-3.6.17`, depois de integrar o branch da atualização;
- ficheiros privados antigos `scripts/deploy-ftps*.env`, depois de migrar qualquer credencial ainda necessária para a estrutura local ignorada pelo Git.

Devem permanecer:

- `.git/`, `.github/` e metadados necessários ao versionamento;
- `public_html/lists/`, como fonte do núcleo comum;
- `deploy/common/` gerado e os três overlays;
- `scripts/` e `tests/` necessários para atualizar e validar;
- `docs/ESTRATEGIA-DEPLOY.md` e `docs/NFSCustomizationsPlugin.md`;
- documentação e ficheiros oficiais do phpList necessários para manter o fork e integrar novas versões.

Nenhuma limpeza deve usar `git clean` de forma genérica, porque os `config.php` reais e outros ficheiros privados são deliberadamente ignorados pelo Git. A remoção deve ser feita apenas sobre caminhos explicitamente aprovados.
