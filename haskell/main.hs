import Data.Bits ( Bits((.|.), shiftL) )
import Data.ByteString as BS ( append, length, pack, readFile, replicate, unpack, writeFile, ByteString )
import Data.ByteString.Builder ( toLazyByteString, word64LE )
import Data.ByteString.Lazy as BL ( unpack )
import Data.List.Split ( chunksOf )
import Data.Word ( Word8, Word64 )
import Numeric ( readHex )
import System.Environment ( getArgs )
import System.Exit ( exitSuccess, exitFailure )
import Text.Printf ( printf )

import Speck ( speckCtr, keySchedule )

encryptFile file key nonce fileOut = Prelude.putStr ""

read64Hex :: String -> [Word64]
read64Hex hexStr = let hexStrs = reverse (chunksOf 16 hexStr) in
    map (fst . last . readHex) hexStrs

bytesToWord64LE :: [Word8]-> Word64
bytesToWord64LE =
    foldr (\ a b -> (b `shiftL` 8) .|. fromIntegral a) 0

word64ToBytesLE :: Word64 -> [Word8]
word64ToBytesLE = BL.unpack . toLazyByteString . word64LE

chunk64 :: [Word8] -> [Word64]
chunk64 bytes = let split = chunksOf 8 bytes in
    map bytesToWord64LE split

dechunk64 :: [Word64] -> [Word8]
dechunk64 words = let b = map word64ToBytesLE words in
    concat b

pad128File :: ByteString -> ByteString
pad128File bytes = let len = toInteger (BS.length bytes)
                       pad = (BS.replicate . fromIntegral) (-len `mod` 16 + 16) 0
    in BS.append bytes pad


prettyPrint :: String -> [Word64] -> IO ()
prettyPrint str xs =
    let prettyPrint' :: String -> Int -> [Word64] -> IO ()
        prettyPrint' _ _ [] = do putStrLn ""
        prettyPrint' str i (x:xs) = do
            putStrLn $ str ++ printf " %d: %016lx" i x
            prettyPrint' str (i + 1) xs
    in prettyPrint' str 0 xs

main :: IO b
main = do
    args <- getArgs
    if Prelude.length args /= 4
    then exitFailure
    else let [fileIn, keyStr, nonceStr, fileOut] = args
        in do
            bytes <- BS.readFile fileIn
            let key = read64Hex keyStr
                keys = keySchedule key
                nonce = read64Hex nonceStr
                paddedBytes = pad128File bytes
                pt =  (chunk64 . BS.unpack) paddedBytes
                ct = speckCtr pt key nonce
                ctBytes = (BS.pack . dechunk64) ct in do
                    prettyPrint "key" key
                    prettyPrint "key schedule" keys
                    prettyPrint "nonce" nonce
                    putStrLn ("pt length:" ++ (show . Prelude.length) pt)
                    prettyPrint "pt" pt
                    prettyPrint "ct" ct
                    BS.writeFile fileOut ctBytes

            exitSuccess
