module Main where

-- Aqui estou importando algumas funções para transformar de inteiros para caracteres
--  e vice-vesa, funções de entrada/saída e números aleatóreos:

import Data.Char
import System.IO
import System.Random

-- Tabuleiro do jogo:
type GBoard = [[Char]]
-- Tabuleiro que contem a posicao das minas (Mapa de Minas). True = mina, False = sem mina:
type MBoard = [[Bool]]




-- Exemplo de Tabuleiro 9x9 inicial todo fechado:
gBoard :: GBoard
gBoard = [['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-'],
          ['-','-','-','-','-','-','-','-','-']]

-- Exemplo de tabuleiro 9x9 com a posição das minas:

mBoard :: MBoard
mBoard = [[True, False, False, False, False, False, False, True, False],
          [False, False, False, False, False, False, False, False, False],
          [False, False, False, False, False, False, False, False, False],
          [False, False, False, False, True, True, True, False, False],
          [False, False, False, False, True , False, True, True, False],
          [False, False, False, False, True, True, True, False, False],
          [False, False, True, False, False, False, False, False, False],
          [False, False, False, False, False, False, False, False, False],
          [False, False, False, False, False, False, False, False, False]]


getSize :: [t] -> Int
getSize [] = 0
getSize (x:xs) = 1 + getSize xs


-- PRIMEIRA PARTE - FUNÇÕES PARA MANIPULAR OS TABULEIROS DO JOGO (MATRIZES)

-- A ideia das próximas funções é permitir que a gente acesse uma lista usando um indice,
-- como se fosse um vetor

-- gArr (get array): recebe uma posicao (p) e uma lista (vetor) e devolve o elemento
-- na posição p do vetor

gArr :: Int -> [t] -> t
gArr pos vec = getPos 0 pos vec

    where
        getPos :: Int -> Int -> [t] -> t
        --getPos _ _ [] = error "Posição inválida"
        getPos counter pos (x:xs)
            | counter == pos    = x
            | otherwise         = getPos (counter + 1) pos xs

-- uArr (update array): recebe uma posição (p), um novo valor (v), e uma lista (vetor) e devolve um
-- novo vetor com o valor v na posição p 

uArr :: Int -> a -> [a] -> [a]
uArr pos nv vetor = changeVal 0 pos nv vetor

    where
        changeVal :: Int -> Int -> a -> [a] -> [a]
        changeVal counter pos nv (x:xs)
            | counter == pos  = nv : xs
            | otherwise = x : changeVal (counter+1) pos nv xs


-- Uma matriz, nada mais é do que um vetor de vetores. 
-- Dessa forma, usando as operações anteriores, podemos criar funções para acessar os tabuleiros, como 
-- se  fossem matrizes:

-- gPos (get position) recebe linha (l), coluna (c) (não precisa validar) e um tabuleiro. Devolve o elemento na posicao
-- tabuleiro[l,c]. Usar gArr na implementação

gPos :: Int -> Int -> [[a]] -> a
gPos l c board = gArr c (gArr l board)

-- uPos (update position): recebe um novo valor, uma posição no tabuleiro (linha e coluna) e um tabuleiro. Devolve 
-- o tabuleiro modificado com o novo valor na posiçao lxc


uPos :: Int -> Int ->  a -> [[a]] -> [[a]]
uPos l c nv board = uArr l ( uArr c nv (gArr l board)) board


--------------- SEGUNDA PARTE: LÓGICA DO JOGO

-- isMine: recebe linha coluna e o tabuleiro de minas, e diz se a posição contém uma mina

isMine :: Int -> Int -> MBoard -> Bool
isMine l c board = gPos l c board


-- isValidPos: recebe o tamanho do tabuleiro (ex, em um tabuleiro 9x9, o tamanho é 9), 
-- uma linha e uma coluna, e diz se essa posição é válida no tabuleiro

isValidPos :: Int -> Int -> Int -> Bool
isValidPos tam l c = not ((l >= tam || l < 0) || (c >= tam || c < 0 ))

-- 
-- validMoves: Dado o tamanho do tabuleiro e uma posição atual (linha e coluna), retorna uma lista
-- com todas as posições adjacentes à posição atual

-- Exemplo: Dada a posição linha 3, coluna 3, as posições adjacentes são: [(2,2),(2,3),(2,4),(3,2),(3,4),(4,2),(4,3),(4,4)]
-- ...   ...      ...    ...   ...
-- ...  (2,2)    (2,3)  (2,4)  ...
-- ...  (3,2)    (3,3)  (3,4)  ...
-- ...  (4,2)    (4,3)  (4,4)  ...
-- ...   ...      ...    ...   ...

--  Dada a posição (0,0) que é um canto, as posições adjacentes são: [(0,1),(1,0),(1,1)]

--  (0,0)  (0,1) ...
--  (1,0)  (1,1) ...
--   ...    ...  ..

validMoves :: Int -> Int -> Int -> [(Int,Int)]
validMoves tam l c
    | not (isValidPos tam l c) = error "Posição Inválida"
    | otherwise                = checkMoves tam (genMoves l c)


    where
        checkMoves :: Int -> [(Int,Int)] -> [(Int,Int)]
        checkMoves tam [] = []
        checkMoves tam ((xa,xb):xs)
            | isValidPos tam xa xb  = (xa,xb) : checkMoves tam xs
            | otherwise             = checkMoves tam xs
        genMoves :: Int -> Int -> [(Int, Int)]
        genMoves l c = [(l-1,c-1),(l-1,c),(l-1,c+1),(l,c-1),(l,c+1),(l+1,c-1),(l+1,c),(l+1,c+1)]

-- cMinas: recebe uma posicao  (linha e coluna), o tabuleiro com o mapa das minas, e conta quantas minas
-- existem nas posições adjacentes

cMinas :: Int -> Int -> MBoard -> Int
cMinas l c mboard = countMines (validMoves (getSize mboard) l c) mboard

    where
        countMines :: [(Int,Int)] -> MBoard -> Int
        countMines [] mboard = 0
        countMines ((xa,xb):xs) mboard
            | isMine xa xb mboard = 1 + countMines xs mboard
            | otherwise           = countMines xs mboard

---
--- abreJogada: é a função principal do jogo!!
--- recebe uma posição a ser aberta (linha e coluna), o mapa de minas e o tabuleiro do jogo. Devolve como
--  resposta o tabuleiro do jogo modificado com essa jogada.
--- Essa função é recursiva, pois no caso da entrada ser uma posição sem minas adjacentes, o algoritmo deve
--- seguir abrindo todas as posições adjacentes até que se encontre posições adjacentes à minas.
--- Vamos analisar os casos:
--- - Se a posição a ser aberta é uma mina, o tabuleiro não é modificado e encerra
--- - Se a posição a ser aberta já foi aberta, o tabuleiro não é modificado e encerra
--- - Se a posição a ser aberta é adjacente a uma ou mais minas, devolver o tabuleiro modificado com o número de
--- minas adjacentes na posição aberta
--- - Se a posição a ser aberta não possui minas adjacentes, abrimos ela com zero (0) e recursivamente abrimos
--- as outras posições adjacentes a ela

abreJogada :: Int -> Int -> MBoard -> GBoard -> GBoard
abreJogada l c mboard gboard
    | isMine l c mboard     = gboard
    | opened l c gboard     = gboard
    | cMinas l c mboard > 0 = uPos l c (intToDigit (cMinas l c mboard)) gboard
    | otherwise             = abreJgRec (validMoves (getSize mboard) l c) mboard (uPos l c (intToDigit 0) gboard)

    where 
        opened :: Int -> Int -> GBoard -> Bool
        opened l c gboard = not (gPos l c gboard == '-')
        abreJgRec :: [(Int,Int)] -> MBoard -> GBoard -> GBoard
        abreJgRec [] mboard gboard = gboard
        abreJgRec ((xl,xc):xs) mboard gboard = abreJgRec xs mboard (abreJogada xl xc mboard gboard)


--- abreTabuleiro: recebe o mapa de Minas e o tabuleiro do jogo, e abre todo o tabuleiro do jogo, mostrando
--- onde estão as minas e os números nas posições adjecentes às minas. Essa função é usada para mostrar
--- todo o tabuleiro no caso de vitória ou derrota

abreTabuleiro :: MBoard -> GBoard -> GBoard
abreTabuleiro mboard gboard = abreTab 0 0 mboard gboard

    where
        opened :: Int -> Int -> GBoard -> Bool
        opened l c gboard = not (gPos l c gboard == '-')
        abreTab :: Int -> Int -> MBoard -> GBoard -> GBoard
        abreTab l c mboard gboard
            | opened l c gboard = gboard
            | isMine l c mboard = abreRec (validMoves (getSize mboard) l c) mboard (uPos l c '*' gboard)
            | otherwise         = abreRec (validMoves (getSize mboard) l c) mboard (uPos l c (intToDigit (cMinas l c mboard)) gboard)
        abreRec :: [(Int, Int)] -> MBoard -> GBoard -> GBoard
        abreRec [] mboard gboard = gboard
        abreRec ((xl,xc):xs) mboard gboard = abreRec xs mboard (abreTab xl xc mboard gboard)



--  -- contaFechadas: Recebe um GBoard e conta quantas posições fechadas existem no tabuleiro (posições com '-')

contaFechadas :: GBoard -> Int
contaFechadas []     = 0
contaFechadas (x:xs) = contaLinha x + contaFechadas xs 

    where
        contaLinha :: [Char] -> Int
        contaLinha [] = 0
        contaLinha (x:xs)
            | x == '-'  = 1 + contaLinha xs
            | otherwise = contaLinha xs

-- contaMinas: Recebe o tabuleiro de Minas (MBoard) e conta quantas minas existem no jogo

contaMinas :: MBoard -> Int
contaMinas [] = 0
contaMinas (x:xs) = contaLinha x + contaMinas xs

    where
        contaLinha :: [Bool] -> Int
        contaLinha [] = 0
        contaLinha (x:xs)
            | x         = 1 + contaLinha xs
            | otherwise = contaLinha xs

-- endGame: recebe o tabuleiro de minas, o tabuleiro do jogo, e diz se o jogo acabou.
-- O jogo acabou quando o número de casas fechadas é igual ao numero de minas

endGame :: MBoard -> GBoard -> Bool
endGame mboard gboard = (contaFechadas gboard) == (contaMinas mboard) 

---
---  PARTE 3: FUNÇÕES PARA GERAR TABULEIROS E IMPRIMIR TABULEIROS
---

-- printBoard: Recebe o tabuleiro do jogo e devolve uma string que é a representação visual desse tabuleiro
-- Usar como referncia de implementacao o video sobre tabela de vendas (Aula 06)


printBoard :: GBoard -> String
printBoard board = printHeader ((getSize board)-1) ++ printLHeader ((getSize board)-1) board ++ "\n"

    where 
        printHeader :: Int -> String
        printHeader 0 = "  " ++ show 0
        printHeader tam = printHeader (tam-1) ++ " " ++ show (tam)
        printLHeader :: Int -> GBoard -> String
        printLHeader 0 board = "\n" ++ show 0 ++ " " ++ printLine (gArr 0 board)
        printLHeader pos board = printLHeader (pos-1) board ++ (show pos) ++ " " ++ printLine (gArr pos board)
        printLine :: [Char] -> String
        printLine [] = "\n"
        printLine (x:xs) = x : " " ++ printLine xs


-- geraLista: recebe um inteiro n, um valor v, e gera uma lista contendo n vezes o valor v

geraLista :: Int -> a -> [a]
geraLista 1 v = [v]
geraLista n v = v : geraLista (n-1) v

-- geraTabuleiro: recebe o tamanho do tabuleiro e gera um tabuleiro  novo, todo fechado (todas as posições
-- contém '-'). A função geraLista deve ser usada na implementação

geraNovoTabuleiro :: Int -> GBoard
geraNovoTabuleiro n = geraLista n (geraLista n '-')

-- geraMapaDeMinasZerado: recebe o tamanho do tabuleiro e gera um mapa de minas zerado, com todas as posições
-- contendo False. Usar geraLista na implementação

geraMapaDeMinasZerado :: Int -> MBoard
geraMapaDeMinasZerado n = geraLista n (geraLista n False)

-- A função a seguir (main) deve ser substituida pela função main comentada mais
-- abaixo quando o jogo estiver pronto

-- main :: IO ()
-- main = print "Alo Mundo!"



-- Aqui está o Motor do Jogo.
-- Essa parte deve ser descomentada quando as outras funções estiverem implementadas
-- Para rodar o jogo, digite "main" no interpretador

main :: IO ()
main = do
   putStr "Digite o tamanho do tabuleiro: "
   size <- getLine
   mb <- genMinesBoard (read size)
   gameLoop mb (geraNovoTabuleiro (read size)) 

gameLoop :: MBoard -> GBoard -> IO ()
gameLoop mb gb = do
   putStr (printBoard gb)
   putStr "Digite uma linha: "
   linha <- getLine
   putStr "Digite uma coluna: "
   coluna <- getLine
   if (isMine (read linha) (read coluna) mb)
      then do
            putStr "VOCE PERDEU!\n"
            putStr $ printBoard $ abreTabuleiro mb gb
            putStr "TENTE NOVAMENTE!\n"
      else do
            let newGB = (abreJogada (read linha) (read coluna) mb gb)
            if (endGame mb newGB)
                 then do
                     putStr "VOCE VENCEU!!!!!!!!\n"
                     putStr $ printBoard $ abreTabuleiro mb newGB
                     putStr "PARABENS!!!!!!!!!!!\n"
                 else
                     gameLoop mb newGB




----- DO NOT GO BEYOUND THIS POINT   


genMinesBoard :: Int -> IO MBoard
genMinesBoard size = do
        board <- addMines (round   ((fromIntegral (size *size)) * 0.15)) size (geraMapaDeMinasZerado size) 
        return board

addMines :: Int -> Int -> MBoard -> IO MBoard
addMines 0 size b = return b
addMines n size b = do
                l <- randomRIO (0,(size-1))
                c <- randomRIO (0,(size-1))
                case isMine l c b of
                      True -> addMines n size b
                      False -> addMines (n-1) size (uPos l c True b)

