-- ghc --make taskstat.hs
import System.Environment
import System.IO
import Control.Monad
import Text.Printf

-- see /fs/proc/array.c
titles = 
 ["pid","tcomm","task_state","ppid","pgid","sid","tty_nr","tty_pgrp",
  "task_flags", "min_flt","cmin_flt","maj_flt","cmaj_flt","utime","stime",
  "cutime","cstime", "priority","nice","num_threads","==0",
  "start_time","vsize","mm_rss","rsslim","mm->start_code","mm->end_code",
  "mm->start_stack", "esp","eip","pending.signal.sig","blocked.sig",
  "sigign.sig","sigcatch.sig","wchan", "==0","==0","task->exit_signal",
  "task_cpu", "task->rt_priority", "task->policy","delayacct_blkio_ticks",
  "gtime","cgtime","mm->start_data","mm->end_data","mm->start_brk"]

main :: IO ()
main = do
  (id:_) <- getArgs
  pstat id

pstat :: String -> IO ()
pstat id = do
  l <- readFile $ "/proc/" ++ id ++ "/stat"
  mapM_ (\(a,b) -> printf "%-25s: %20s\n" a b) $ zip titles (words l)

