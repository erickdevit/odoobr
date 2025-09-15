FROM ubuntu:22.04

# Definindo variáveis de ambiente
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Gerar C.UTF-8 para postgres e dados de localidade em geral
ENV LANG C.UTF-8

# Identificar a arquitetura de destino para instalar o pacote wkhtmltopdf correto
ARG TARGETARCH

# Instala  deps, lessc e less-plugin-clean-css e wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils 

# Instala o Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends nodejs


# Instala o wkhtmltopdf
RUN apt install wkhtmltopdf -y

# Instala os requerimentos python do OCA Brasil
COPY ./requirements.txt /tmp/
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    find /usr/local/lib/python*/dist-packages/ -type d -name '__pycache__' -exec rm -r {} + || true

# Instala o cliente postgresql mais recente
RUN apt install postgresql -y

# Instala o Odoo
ENV ODOO_VERSION 16.0
ARG ODOO_RELEASE=20250909
ARG ODOO_SHA=86371b3510555e464caae06eba3373f75fbbb4f5
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copia o entrypoint e o arquivo de configuração do Odoo

COPY ./odoo.conf /etc/odoo/

# Adiciona o diretório de addons customizáveis.
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons
    

# Clonando repositórios OCA necessários
RUN git clone --depth=1 --branch=16.0 https://github.com/OCA/l10n-brazil.git /mnt/extra-addons/l10n-brazil && \
    git clone --depth=1 --branch=16.0 https://github.com/OCA/product-attribute.git /mnt/extra-addons/product-attribute && \
    git clone --depth=1 --branch=16.0 https://github.com/OCA/account-payment.git /mnt/extra-addons/account-payment && \
    git clone --depth=1 --branch=16.0 https://github.com/OCA/bank-payment.git /mnt/extra-addons/bank-payment && \
    pip3 install --no-cache-dir -r /mnt/extra-addons/l10n-brazil/requirements.txt && \
    sed -i 's/list | tuple/(list, tuple)/g' /mnt/extra-addons/l10n-brazil/l10n_br_base/models/party_mixin.py


# Ajusta as permissões dos arquivos e define os volumes
RUN chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Define as portas padrão do Odoo
EXPOSE 8069 8071 8072

# Setando variáveis de ambiente
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Usa o usuário odoo para rodar o serviço
USER odoo


CMD ["odoo"]