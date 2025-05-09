FROM fluent/fluentd-kubernetes-daemonset:v1.18-debian-logzio-amd64-1

USER root
WORKDIR /fluentd

COPY Gemfile* /fluentd/
RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps libjemalloc2 \
 && bundle install --gemfile=/fluentd/Gemfile --path=/fluentd/vendor/bundle \
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

# Default values for fluent.conf
ENV LOGZIO_BUFFER_TYPE "file"
ENV LOGZIO_BUFFER_PATH "/var/log/fluentd-buffers/stackdriver.buffer"
ENV LOGZIO_OVERFLOW_ACTION "block"
ENV LOGZIO_CHUNK_LIMIT_SIZE "2M"
ENV LOGZIO_QUEUE_LIMIT_LENGTH "6"
ENV LOGZIO_FLUSH_INTERVAL "5s"
ENV LOGZIO_RETRY_MAX_INTERVAL "30"
ENV LOGZIO_RETRY_FOREVER "true"
ENV LOGZIO_FLUSH_THREAD_COUNT "2"
ENV INCLUDE_NAMESPACE ""

# Defaults value for system.conf
ENV LOGZIO_LOG_LEVEL "info"
