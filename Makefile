build:
	gem build ad_localize.gemspec

install: clean build
	gem install ad_localize-*.gem

clean:
	rm -f ad_localize-*.gem

tests:
	bundle exec rake test
