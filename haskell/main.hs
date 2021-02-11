--import Data.ByteString ()
import System.Environment
import System.Exit ( exitSuccess, exitFailure )
import System.IO

import Speck ()

encryptFile file key nonce fileOut = putStr ""

readKey key = key

main = do
    args <- getArgs
    if length args /= 4
    then exitFailure
    else let [fileIn, key, nonce, fileOut] = args
         in do inFile <- openBinaryFile fileIn ReadMode
               fSize <- hFileSize inFile
               print fSize
               hClose inFile
               exitSuccess
