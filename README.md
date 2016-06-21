# Tetris-Pascal
Jogo em tetris desenvolvido em pascal.

Principal algoritmo é o de rotação de peças:
Quanto ao tamanho das peças, existem peças de 4x4 (size=4) e de 3x3 (size=3). No
caso das de 4x4, o eixo de rotação é bem no meio da array. Exemplo (retângulo): 
```
       |               |               |               |               |
    0 1 0 0   ->    0 0 0 0   ->    0 0 1 0   ->    0 0 0 0   ->    0 1 0 0
  _ 0 1 0 0 _ ->  _ 1 1 1 1 _ ->  _ 0 0 1 0 _ ->  _ 0 0 0 0 _ ->  _ 0 1 0 0 _
    0 1 0 0   ->    0 0 0 0   ->    0 0 1 0   ->    1 1 1 1   ->    0 1 0 0
    0 1 0 0   ->    0 0 0 0   ->    0 0 1 0   ->    0 0 0 0   ->    0 1 0 0
       |               |               |               |               | 
```
 Já nas peças de 3x3, o eixo de rotação é na célula (2,2). Exemplo ("L"):
```
      |               |               |               |               |  
    0 0 0 0   ->    1 0 0 0         1 1 1 0         0 1 1 0         0 0 0 0
  - 0 0 1 0 - ->  - 1 0 0 0 - ->  - 1 0 0 0 - ->  - 0 0 1 0 - ->  - 0 0 1 0 -
    1 1 1 0   ->    1 1 0 0   ->    0 0 0 0   ->    0 0 1 0   ->    1 1 1 0
    0 0 0 0   ->    0 0 0 0         0 0 0 0         0 0 0 0         0 0 0 0
      |               |               |               |               |
```
 Repare que a estrutura utilizada para representar as formas de 4x4 e de 3x3 é a
 mesma, uma array bidimensional de 4x4. Contudo, nas peças de 3x3, existem 7
 células (as da última coluna e as da úllima linha) que são inutilizadas. 

