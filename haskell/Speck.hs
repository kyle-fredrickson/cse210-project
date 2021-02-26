{-# OPTIONS_GHC -Wno-overlapping-patterns #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
module Speck
( keySchedule
, speckEncrypt
, speckCtr) where

import Data.Bits ( Bits(rotate, xor) )
import Data.List.Split ( chunksOf )
import Data.Word ( Word64 )


xorAll :: [Word64] -> [Word64] -> [Word64]
xorAll = zipWith xor

add1 :: [Word64] -> [Word64]
add1 (n:ns) =
    if n /= 2 ^ 64 - 1 then
        (n + 1) : ns
    else
        0 : add1 ns

keySchedule :: [Word64] -> [Word64]
keySchedule key =
    let keySchedule' :: [Word64] -> Int -> Word64 -> Word64 -> Word64 -> [Word64]
        keySchedule' keys 33 _ _ _ = keys
        keySchedule' keys i l0 l1 l2 = case i `mod` 3 of
            0 -> let l0' =  head keys + rotate l0 (-8) `xor` fromIntegral i
                     k' = rotate (head keys) 3 `xor` l0'
                 in keySchedule' (k':keys) (i + 1) l0' l1 l2
            1 -> let l1' =  head keys + rotate l1 (-8) `xor` fromIntegral i
                     k' = rotate (head keys) 3 `xor` l1'
                 in keySchedule' (k':keys) (i + 1) l0 l1' l2
            2 -> let l2' =  head keys + rotate l2 (-8) `xor` fromIntegral i
                     k' = rotate (head keys) 3 `xor` l2'
                 in keySchedule' (k':keys) (i + 1) l0 l1 l2'
    in reverse (keySchedule' [head key] 0 (key !! 1) (key !! 2) (key !! 3))

encRound :: [Word64] -> Word64 -> [Word64]
encRound [r, l] key =
    let l' = rotate l (-8) + r `xor` key
        r' = rotate r 3 `xor` (rotate l (-8) + r) `xor` key
    in [r', l']

speckEncrypt :: [Word64] -> [Word64] -> [Word64]
speckEncrypt = foldl encRound

speckCtr :: [Word64] -> [Word64] -> [Word64] -> [Word64]
speckCtr pt key nonce =
    let keys = keySchedule key
        pad = concatMap (`speckEncrypt` keys) (getPad nonce (length pt))
    in xorAll pt pad

getPad :: [Word64] -> Int -> [[Word64]]
getPad nonce n =
    let getPad' :: [Word64] -> Int -> [[Word64]] -> [[Word64]]
        getPad' nonce 0 pad = pad
        getPad' nonce n pad = getPad' (add1 nonce) (n - 2) (nonce:pad)
    in reverse (getPad' nonce n [])
