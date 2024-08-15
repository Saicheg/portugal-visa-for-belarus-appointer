FROM ruby:3.3.4-alpine

SHELL ["/bin/sh", "-o", "pipefail", "-e", "-u", "-x", "-c"]

RUN gem install bundler

COPY Gemfile Gemfile.lock ./

RUN bundle install

ADD run.rb /run.rb
RUN chmod +x /run.rb

ENTRYPOINT ["/run.rb"]
