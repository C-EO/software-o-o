FROM registry.opensuse.org/opensuse/infrastructure/software.opensuse.org/containers/software/base:latest

# Add our user
ARG CONTAINER_USERID
RUN useradd -m software  -u $CONTAINER_USERID -p software

# We copy the Gemfiles into this intermediate build stage so it's checksum
# changes and all the subsequent stages (a.k.a. the bundle install call below)
# have to be rebuild. Otherwise, after the first build of this image,
# docker would use it's cache for this and the following stages.
ADD Gemfile /software/Gemfile
ADD Gemfile.lock /software/Gemfile.lock
RUN chown -R software /software

USER software
WORKDIR /software

# Setup bundler
# We always want to build for our platform instead of using precompiled gems
ENV BUNDLE_FORCE_RUBY_PLATFORM=true
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# Refresh our bundle
RUN bundle config set --local path 'vendor/bundle'; \
    bundle install --jobs=3 --retry=3

# Run our command
CMD ["rails", "server", "-b", "0.0.0.0"]

