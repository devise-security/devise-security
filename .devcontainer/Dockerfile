# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.191.1/containers/ruby/.devcontainer/base.Dockerfile

# [Choice] Ruby version: 3, 3.3, 3.2, 3.1, 3.0, 2, 2.7, 2.6
ARG VARIANT="3"
FROM mcr.microsoft.com/devcontainers/ruby:${VARIANT}

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libtiff-dev \
        postgresql-client \
        postgresql-contrib \
        libpq-dev

# Install ImageMagick
ARG IMAGEMAGICK_VERSION="7.1.0-5"
RUN wget -qO /tmp/im.tar.xz https://imagemagick.org/archive/releases/ImageMagick-$IMAGEMAGICK_VERSION.tar.xz \
    && wget -qO /tmp/im.sig https://imagemagick.org/archive/releases/ImageMagick-$IMAGEMAGICK_VERSION.tar.xz.asc \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv 89AB63D48277377A \
    && gpg --batch --verify /tmp/im.sig /tmp/im.tar.xz \
    && tar xJf /tmp/im.tar.xz -C /tmp \
    && cd /tmp/ImageMagick-$IMAGEMAGICK_VERSION \
    && ./configure --with-rsvg && make -j 9 && make install \
    && ldconfig /usr/local/lib \
    && rm -rf /tmp/*

# Install MongoDB Shell
ARG MONGOSH_VERSION="2.3.4"
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "arm64" ]; then \
        wget -qO /tmp/mongosh.deb "https://downloads.mongodb.com/compass/mongodb-mongosh_${MONGOSH_VERSION}_${ARCH}.deb" \
        && apt-get install -y /tmp/mongosh.deb \
        && rm -rf /tmp/*; \
    fi

# Install supported Ruby versions
# https://www.ruby-lang.org/en/downloads/releases/
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm \
    && rvm install 3.1.6 \
    && rvm install 3.2.6 \
    && rvm install 3.3.6 \
    && rvm install 3.4.1"

# Set the default bundle path
ENV BUNDLE_PATH=/usr/local/bundle

# Install gem dependencies
RUN mkdir -p /tmp/gem/lib/devise-security
COPY gemfiles /tmp/gem/gemfiles
COPY lib/devise-security/version.rb /tmp/gem/lib/devise-security
COPY .ruby-version Appraisals devise-security.gemspec Gemfile Gemfile.lock /tmp/gem/
RUN mkdir -p ${BUNDLE_PATH} \
    && gem install bundler:2.6.2 \
    && cd /tmp/gem \
    && bundle install --jobs=3 --retry=3 \
    && bundle exec appraisal install \
    && rm -rf /tmp/gem
VOLUME ["/usr/local/bundle"]

RUN chown -R vscode:vscode /usr/local/rvm ${BUNDLE_PATH}
