-----------------------------------------------------------------------------
-- |
-- Module      :  Monitors.Swap
-- Copyright   :  (c) Andrea Rossato
-- License     :  BSD-style (see LICENSE)
-- 
-- Maintainer  :  Andrea Rossato <andrea.rossato@unibz.it>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A  swap usage monitor for XMobar
--
-----------------------------------------------------------------------------

module Monitors.Swap where

import Monitors.Common

import Data.IORef
import qualified Data.ByteString.Lazy.Char8 as B

swapConfig :: IO MConfig
swapConfig = 
    do lc <- newIORef "#BFBFBF"
       l <- newIORef 30
       nc <- newIORef "#00FF00"
       h <- newIORef 75
       hc <- newIORef "#FF0000"
       t <- newIORef "Swap: <usedratio>%"
       p <- newIORef package
       u <- newIORef ""
       a <- newIORef []
       e <- newIORef ["total", "used", "free", "usedratio"]
       return $ MC nc l lc h hc t p u a e

fileMEM :: IO B.ByteString
fileMEM = B.readFile "/proc/meminfo"

parseMEM :: IO [Float]
parseMEM =
    do file <- fileMEM
       let p x y = flip (/) 1024 . read . stringParser x $ y
           tot = p (1,11) file
           free = p (1,12) file
       return [tot, (tot - free), free, (tot - free) / tot * 100]

formatSwap :: [Float] -> Monitor [String] 
formatSwap x =
    do let f n = show (takeDigits 2 n)
       mapM (showWithColors f) x

package :: String
package = "xmb-swap"

runSwap :: [String] -> Monitor String
runSwap _ =
    do m <- io $ parseMEM
       l <- formatSwap m
       parseTemplate l 
    
{-
main :: IO ()
main =
    do let af = runSwap []
       runMonitor swapConfig af runSwap
-}