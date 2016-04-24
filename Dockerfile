FROM ruby:2.3.0
# Todo - flesh me out!

RUN mkdir -p /app/gems
WORKDIR /app/gems
ADD Gemfile /app/gems
ADD Gemfile.lock /app/gems
RUN bundle install --path /app/gems

WORKDIR /app
ADD . /app
RUN bundle check --path /app/gems || bundle install --path /app/gems


EXPOSE 9292

CMD bundle exec unicorn -c config/unicorn.rb
