FROM 855953295449.dkr.ecr.us-east-1.amazonaws.com/devleads/base:v1

ADD Gemfile /app/gems
ADD Gemfile.lock /app/gems
WORKDIR /app/gems
RUN bundle install --path /app/gems

WORKDIR /app
COPY . /app

RUN bundle check --path /app/gems || bundle install --path /app/gems

EXPOSE 9292

# Everything has been performed as root, so we need to give perms to our user
RUN chown -R devleads:devleads /app

USER devleads

CMD bundle exec rackup --host 0.0.0.0
