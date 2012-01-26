{-# LANGUAGE OverloadedStrings #-}
import Data.Maybe
import System.Environment (getEnv)
import Happstack.Server
import Control.Monad (msum)
import Text.Blaze
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

type PathConf = (String, String) -- ^ url, filepath

main :: IO ()
main = do
  home <- getEnv "HOME"
  content <- readFile $ home ++ "/.hfsrc"
  let conf = getConf $ lines content
  servFileWith conf

appTemplate :: String -> H.Html -> H.Html
appTemplate title body = H.html $ do
  H.head $ do
    H.title (H.toHtml title)
    H.meta ! A.httpEquiv "Content-Type" ! A.content "text/html;charset=uft-8"
  H.body body

servFileWith :: [PathConf] -> IO ()  -- 8000
servFileWith pcs = do simpleHTTP nullConf $ msum $ withConf ++ [indexPage]
  where
    entry = ["frames.html","index.html","index.htm"]
    withConf = map (\(u, p) -> dirs u $ serveDirectory EnableBrowsing entry p) pcs
    indexPage = ok $ toResponse $ appTemplate "INDEX" $ sequence_ $ map toA pcs
    toA (u,_) = H.h1 $ H.a ! A.href (toValue u) $ (H.toHtml u) >> H.br

getConf :: [String] -> [PathConf]
getConf ss = catMaybes $ map getConf1 ss
  where
    getConf1 s = case break (== '=') s of
      (u,(_:p)) -> Just (u,p)
      _ -> Nothing
