BIN = main

all: c/$(BIN) haskell/$(BIN) racket/$(BIN) python/main.py rust/$(BIN)

c/$(BIN): c/main.c c/speck.c
	@echo "Compiling C."
	@gcc c/main.c c/speck.c -o c/$(BIN)

haskell/$(BIN): haskell/main.hs haskell/Speck.hs
	@echo "Compiling Haskell."
	@ghc haskell/main haskell/Speck.hs

racket/$(BIN): racket/main.rkt racket/speck.rkt
	@echo "Compiling Racket."
	@raco exe -o racket/$(BIN) racket/main.rkt

rust/$(BIN): rust/main.rs rust/speck.rs
	@echo "Compiling Rust."
	@rustc rust/main.rs -o rust/$(BIN)

clean:
	@[ -f c/$(BIN) ] && rm c/$(BIN) || true
	@[ -f haskell/$(BIN) ] && rm haskell/$(BIN); rm haskell/*.hi; rm haskell/*.o || true
	@[ -d python/__pycache__ ] && rm -r python/__pycache__ || true
	@[ -f racket/$(BIN) ] && rm racket/$(BIN) || true
	@[ -f rust/$(BIN) ] && rm rust/$(BIN) || true
	@rm */out.*
