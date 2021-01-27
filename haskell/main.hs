--import Data.ByteString ()
import System.Environment
import System.Exit ( exitSuccess, exitFailure )

import Speck ()

encryptFile file key fileOut = putStr ""

readKey key = 1

main = do
    args <- getArgs
    if length args /= 3
    then exitFailure
    else let [fileIn, key, fileOut] = args
         in (do encryptFile fileIn (readKey key) fileOut
                exitSuccess)
