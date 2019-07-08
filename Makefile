.PHONY: all creds setup clean

all: creds setup clean

creds:
	lpass show 8263852225259424347 --notes > .envrc

setup:
	./setup.sh

clean:
	rm .envrc
