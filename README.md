<div align="center">
  <img src="https://odoocdn.com/web/image/res.company/1/logo?unique=7879e6c" alt="Odoo Logo" width="200"/>
  <h1>Odoo 16 com Localização Brasileira</h1>
  <p>
    Um ambiente Docker completo e robusto para desenvolvimento e implantação do Odoo 16, pré-configurado com os principais módulos da localização brasileira (OCA).
  </p>
  <p>
    <a href="https://hub.docker.com/r/erickdevit/odoobr">
      <img src="https://img.shields.io/docker/v/erickdevit/odoobr/16?label=Docker%20Hub&logo=docker&color=blue" alt="Docker Hub Version">
    </a>
    <a href="https://github.com/OCA/l10n-brazil">
      <img src="https://img.shields.io/badge/OCA-l10n--brazil-875A7B.svg" alt="OCA l10n-brazil">
    </a>
  </p>
</div>

---

## 🚀 Visão Geral

Este projeto encapsula uma instância do Odoo 16 e um banco de dados PostgreSQL em containers Docker, gerenciados por Docker Compose. A imagem do Odoo já inclui as dependências e os módulos da OCA Brasil, tornando o ambiente pronto para uso imediato.

### ✨ Principais Características

-   **Odoo 16**: Versão estável e atualizada.
-   **Localização Brasileira**: Inclui os repositórios essenciais da OCA (`l10n-brazil`, `account-payment`, etc.).
-   **Dockerizado**: Ambiente isolado, portátil e fácil de replicar.
-   **Pronto para Desenvolvimento**: Monte seus addons customizados e veja as alterações em tempo real.

## 📋 Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas:

-   Docker
-   Docker Compose
-   Git 

## ⚙️ Configuração Inicial

Siga estes passos para preparar seu ambiente local.

1.  **Clone o Repositório**
    ```bash
    git clone https://github.com/erickdevit/odoobr.git
    cd odoobr
    ```

2.  **Crie o Diretório de Addons Customizados**
    Este diretório é onde você colocará seus próprios módulos. Ele será montado dentro do container.
    ```bash
    mkdir -p addons/custom
    ```

3.  **Configure o `odoo.conf`**
    Abra o arquivo `odoo.conf` e revise as configurações. É **extremamente importante** alterar a senha mestre (`admin_passwd`) para um valor seguro.
    ```ini
    [options]
    ; Substitua 'mastersenha' por uma senha forte e segura
    admin_passwd = sua_senha_super_segura
    ...
    ```

## ▶️ Como Executar

Você pode iniciar o ambiente de duas maneiras, dependendo da sua necessidade.

### Opção 1: Usar a Imagem Pronta do Docker Hub (Recomendado)

Esta é a forma mais rápida e simples, ideal para quem quer apenas rodar a aplicação ou implantá-la em um servidor.

1.  **Verifique o `docker-compose.yml`**
    Garanta que o serviço `odoo` está configurado para usar a imagem do Docker Hub:
    ```yaml
    services:
      odoo:
        image: erickdevit/odoobr:16
        # ...
    ```

2.  **Inicie os Serviços**
    Este comando fará o download da imagem (se necessário) e iniciará os containers em segundo plano (`-d`).
    ```bash
    docker-compose up -d
    ```

### Opção 2: Construir a Imagem Localmente (Para Desenvolvedores)

Use esta opção se você fez alterações no `Dockerfile`, `requirements.txt` ou nos scripts de inicialização (`entrypoint.sh`, `wait-for-psql.py`).

1.  **Ajuste o `docker-compose.yml`**
    Comente a linha `image` e descomente (ou adicione) a linha `build: .`:
    ```yaml
    services:
      odoo:
        # image: erickdevit/odoobr:16
        build: .
        # ...
    ```

2.  **Construa e Inicie os Serviços**
    O comando `--build` força o Docker Compose a reconstruir a imagem antes de iniciar os containers.
    ```bash
    docker-compose up -d --build
    ```

---

Após iniciar, acesse o Odoo em seu navegador: **http://localhost:8069**

## 🛠️ Gerenciando o Ambiente

| Ação                               | Comando                               |
| ---------------------------------- | ------------------------------------- |
| **Ver logs em tempo real**         | `docker-compose logs -f odoo`         |
| **Parar os containers**            | `docker-compose stop`                 |
| **Reiniciar os containers**        | `docker-compose restart`              |
| **Parar e remover containers**     | `docker-compose down`                 |
| **Remover tudo (incluindo dados)** | `docker-compose down -v`              |

> ⚠️ **Atenção:** O comando `docker-compose down -v` removerá os volumes do Docker, o que significa que **todos os dados do seu banco de dados e o filestore do Odoo serão permanentemente apagados.**

## 🏗️ Estrutura do Projeto

-   `Dockerfile`: Define a receita para construir a imagem Docker do Odoo, instalando todas as dependências do sistema, pacotes Python e clonando os repositórios da OCA.
-   `docker-compose.yml`: Orquestra a inicialização e a rede entre os serviços `odoo` e `db` (PostgreSQL).
-   `odoo.conf`: Arquivo de configuração principal do Odoo. É montado como um volume para permitir alterações sem reconstruir a imagem.
-   `requirements.txt`: Lista de dependências Python necessárias para os módulos da localização brasileira.
-   `addons/custom`: Diretório local para seus módulos customizados. É montado em `/mnt/extra-addons/custom` dentro do container.

## 🔄 Ciclo de Desenvolvimento e Contribuição

Se você precisa atualizar a imagem base (por exemplo, adicionar uma nova dependência no `Dockerfile` ou um novo repositório da OCA), o fluxo de trabalho é o seguinte:

1.  **Faça suas alterações** nos arquivos do projeto.
2.  **Construa a nova imagem** localmente, atribuindo uma tag:
    ```bash
    docker build -t odoobr:latest .
    ```
3.  **Tagueie a imagem** para o seu repositório no Docker Hub:
    ```bash
    # Substitua 'seu-usuario' e 'sua-tag'
    docker tag odoobr:latest seu-usuario/odoobr:sua-tag
    ```
4.  **Faça login e envie** a imagem para o Docker Hub:
    ```bash
    docker login
    docker push seu-usuario/odoobr:sua-tag
    ```

## 🎯 Funcionalidades

#### Localização Brasileira
-   ✅ Plano de contas brasileiro
-   ✅ Regimes fiscais (Simples, Lucro Presumido, Real)
-   ✅ CNAE e códigos fiscais
-   ✅ Validações de CPF/CNPJ

#### Pagamentos
-   ✅ Módulos de pagamento bancário
-   ✅ Integração com bancos brasileiros
-   ✅ Gestão de parceiros


## 🤝 Contribuição

1.  Fork o projeto
2.  Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3.  Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4.  Push para a branch (`git push origin feature/AmazingFeature`)
5.  Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Autor

**Erick Dev** - [GitHub](https://github.com/erickdevit)

## 🙏 Agradecimentos

-   [OCA (Odoo Community Association)](https://odoo-community.org/)
-   [l10n-brazil](https://github.com/OCA/l10n-brazil)
-   [account-payment](https://github.com/OCA/account-payment)
-   [bank-payment](https://github.com/OCA/bank-payment)

---

⭐ **Se este projeto te ajudou, considere dar uma estrela!**