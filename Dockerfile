# development machine
#
# VERSION: see `TAG`
FROM ubuntu:14.04
MAINTAINER Joao Paulo Dubas "joao.dubas@gmail.com"

# install system deps
RUN apt-get -y -qq --force-yes update \
    && apt-get -y -qq --force-yes install \
        linux-headers-generic \
        software-properties-common \
    && add-apt-repository -y ppa:fcwu-tw/ppa \
    && apt-get -y -qq --force-yes update \
    && apt-get -y -qq --force-yes install \
        build-essential \
        locales \
        python-setuptools \
        python-dev \
        ruby-dev \
        vim \
        vim-nox \
        vim-scripts \
        tmux \
        git \
        make \
        cmake \
        curl \
        zsh \
        openssl \
        sudo

# prepare locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen --purge --lang en_US \
    && locale-gen --purge --lang pt_BR \
    && locale-gen
ENV LANG en_US.utf8

# install virtualenv
RUN easy_install pip \
    && pip install virtualenv virtualenvwrapper

# create docker group and app user
RUN groupadd -g 999 docker \
    && useradd \
        -G sudo,docker \
        -d /home/app \
        -m \
        -p $(openssl passwd 123app4) \
        -s $(which zsh) \
        app
USER app

# prepare home dir
ENV HOME /home/app
ENV HOMESRC ${HOME}/local/src
ENV HOMEBIN ${HOME}/local/bin
RUN mkdir -p $HOME/public \
    && mkdir -p $HOMESRC \
    && mkdir -p $HOMEBIN

# install iojs
ENV JS_VERSION v5.6.0
ENV JS_FILENAME nodejs-${JS_VERSION}-linux-x64
ENV JS_TARNAME ${JS_FILENAME}.tar.xz
ENV JS_URL https://nodejs.org/dist/${JS_VERSION}/${JS_TARNAME}
RUN curl -L ${JS_URL} | tar -C ${HOMESRC} -xJf - \
    && ln -s ${HOMESRC}/${JS_FILENAME} ${HOMESRC}/nodejs \
    && ln -s ${HOMESRC}/nodejs/bin/* ${HOMEBIN}/

# install golang
ENV GOROOT ${HOMESRC}/go
ENV GOPATH ${HOME}/local/go
ENV GOBIN ${GOPATH}/bin
ENV GO_VERSION 1.6
ENV GO_FILENAME go${GO_VERSION}.linux-amd64
ENV GO_TARNAME ${GO_FILENAME}.tar.gz
ENV GO_URL https://storage.googleapis.com/golang/${GO_TARNAME}
RUN curl -L ${GO_URL} | tar -C ${HOMESRC} -xzf - \
    && ln -s ${HOMESRC}/go/bin/* ${HOMEBIN}/ \
    && mkdir -p ${GOPATH}/src \
    && mkdir -p ${GOPATH}/bin \
    && mkdir -p ${GOPATH}/pkg

# clone dotfiles
ENV DOTFILE ${HOMESRC}/dotfiles
RUN git clone https://github.com/joaodubas/webfaction-dotfiles.git \
        ${DOTFILE} \
    && cd ${DOTFILE} \
    && git submodule update --init --recursive

# link to home
RUN ln -s ${DOTFILE}/.bash_aliases ${HOME} \
    && ln -s ${DOTFILE}/.bash_personal ${HOME} \
    && ln -s ${DOTFILE}/.tmux.conf ${HOME} \
    && ln -s ${DOTFILE}/.vimrc ${HOME} \
    && ln -s ${DOTFILE}/.vim ${HOME} \
    && ln -s ${DOTFILE}/.gitignore_global ${HOME} \
    && cp ${DOTFILE}/.gitconfig ${HOME}/

# install vim bundles
RUN printf 'y' | vim +BundleInstall +qall \
    && echo "install command t" \
    && cd ${DOTFILE}/.vim/bundle/Command-T/ruby/command-t \
    && ruby extconf.rb \
    && make \
    && echo "install tern"\
    && cd ${DOTFILE}/.vim/bundle/tern_for_vim \
    && ${HOMEBIN}/npm install \
    && echo "install ycm" \
    && cd ${DOTFILE}/.vim/bundle/YouCompleteMe \
    && sh install.sh \
    && echo "install vim-go deps" \
    && printf 'y' | vim +GoInstall +qall

# install oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git \
        ${HOME}/.oh-my-zsh \
    && cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template ${HOME}/.zshrc \
    && echo '\n' >> ${HOME}/.zshrc \
    && echo '# local resources' >> ${HOME}/.zshrc \
    && echo 'source $HOME/.bash_aliases' >> ${HOME}/.zshrc

# install docker-compose
ENV COMPOSE_VERSION 1.6.0
ENV COMPOSE_URL https://github.com/docker/compose/releases/download
RUN curl \
        -L ${COMPOSE_URL}/${COMPOSE_VERSION}/docker-compose-Linux-x86_64 \
        -o ${HOMEBIN}/docker-compose \
    && chmod 750 ${HOMEBIN}/docker-compose \
    && chown app:app ${HOMEBIN}/docker-compose

# conf container
ENV TERM xterm-256color
VOLUME ["/home/app/public"]
WORKDIR /home/app
CMD ["/usr/bin/zsh"]
