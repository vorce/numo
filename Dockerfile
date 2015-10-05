FROM docker.meltwater.com/centos-base:latest

RUN yum -y install git unzip gcc expat-devel && \
	yum clean all

# erlang-solutions-1.0-1.noarch.rpm package contains no files at all, must be broken..
#RUN yum install -y http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
ADD erlang-solutions.repo /etc/yum.repos.d/
RUN yum install -y esl-erlang

# Elixir
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV ELIXIR_VERSION 1.1.1
RUN curl -sLo /tmp/elixir.zip https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip && \
	mkdir /elixir && cd /elixir && unzip /tmp/elixir.zip
ENV PATH ${PATH}:/elixir/bin

RUN yum install -y nodejs npm
RUN npm install -g brunch

# Numo
COPY . /service
WORKDIR /service

RUN mix local.rebar
RUN mix local.hex --force
RUN yes | mix deps.get --only prod
RUN MIX_ENV=prod mix compile

RUN brunch build --production
RUN MIX_ENV=prod mix phoenix.digest

ENTRYPOINT ["./start.sh"]

