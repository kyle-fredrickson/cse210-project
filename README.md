# cse210-project

This repository contains implementations of SPECK128/256 with counter mode in
* C
* Haskell
* Python
* Racket
* Rust

The nonce and key used in the test script are the test vectors included in the SPECK paper.

To run:
* Clone and CD into the folder.
* Run make, which will compile all projects (except python).
* Run test.sh. It accepts 4 arguments: the folder to look in, the name of the executable (run with ./...), the file to encrypt, and the true encryption to compare against (this will not affect the functioning of the code, but is strictly for testing purposes.).
* ex. ./test.sh c main randomfile.txt trueencryption.enc
* ex. ./test.sh python main.py randomfile.txt trueencryption.enc

Alternatively, you can run the ipynb, which will set up the experiments used in my final report.
