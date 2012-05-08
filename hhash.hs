-- package: cryptohash, bytestring, deepseq
import qualified Crypto.Hash.MD2       as MD2
import qualified Crypto.Hash.MD4       as MD4
import qualified Crypto.Hash.MD5       as MD5
import qualified Crypto.Hash.RIPEMD160 as RIPEMD160
import qualified Crypto.Hash.SHA1      as SHA1
import qualified Crypto.Hash.SHA224    as SHA224
import qualified Crypto.Hash.SHA256    as SHA256
import qualified Crypto.Hash.SHA384    as SHA384
import qualified Crypto.Hash.SHA512    as SHA512
import qualified Crypto.Hash.SHA512t   as SHA512t
import qualified Crypto.Hash.Skein256  as Skein256
import qualified Crypto.Hash.Skein512  as Skein512
import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString as BS
import Control.Applicative ((<$>),)
import System.Environment
import Text.Printf
import Control.DeepSeq
import Data.Char

main :: IO ()
main = do
  args <- getArgs
  case args of
    (a:b:rest) -> do
      mbhash <- doHash a b rest
      case mbhash of
        Just hash -> do printf "(%d): \n" $ BS.length hash
                        mapM_ (printf "%02x") $ BS.unpack hash
                        putStrLn "[DONE]"
        _ -> putStrLn "FAILED: unknown hash type"
    _ -> putStrLn "<command> <type> <filename>"

type LazyHash = BSL.ByteString -> BS.ByteString
type LazyHashI = Int -> BSL.ByteString -> BS.ByteString

typeList :: [(String, LazyHash)]
typeList = map (\(k,v) -> (map toLower k,v)) $
  [("MD2"      , MD2.hashlazy),
   ("MD4"      , MD4.hashlazy),
   ("MD5"      , MD5.hashlazy),
   ("RIPEMD160", RIPEMD160.hashlazy),
   ("SHA1"     , SHA1.hashlazy),
   ("SHA224"   , SHA224.hashlazy),
   ("SHA256"   , SHA256.hashlazy),
   ("SHA384"   , SHA384.hashlazy),
   ("SHA512"   , SHA512.hashlazy)]

typeListI :: [(String, LazyHashI)]
typeListI = map (\(k,v) -> (map toLower k,v)) $
  [("SHA512t"  , SHA512t.hashlazy),
   ("Skein256" , Skein256.hashlazy),
   ("Skein512" , Skein512.hashlazy)]

doHash :: String -> String -> [String] -> IO (Maybe BS.ByteString)
doHash ty file rest = do
  let mbfun = lookup (map toLower ty) typeList
  case mbfun of
    Just fun -> Just <$> hashWith fun file
    _ -> do
      let mbfun1 = lookup (map toLower ty) typeListI
      case (mbfun1, rest) of
        (Just fun1, (a:_)) -> Just <$> hashWith (fun1 (read a)) file
        _ -> return Nothing

hashWith :: LazyHash -> FilePath -> IO BS.ByteString
hashWith fun file = do
  bs <- BSL.readFile file
  let hash = fun bs
  return $ BS.length hash `deepseq` hash

