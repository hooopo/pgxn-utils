all:
	gem build pgxn_utils.gemspec
install:
	gem install --no-rdoc --no-ri -v=0.1.5 pgxn_utils
