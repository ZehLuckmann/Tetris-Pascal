Program tetris;
Const



  HEIGHT = 20;        // Altura do grid (�rea interna, sem contar as bordas)
  HeightPlusOne = 21;   // Altura do grid + 1
  WIDTH = 11;           // Largura do grid (�rea interna, sem contar as bordas)
  WidthPlusOne = 12;    // Largura do grid + 1    
  LEFT = -1;            // Identifica��o dos movimentos horizontais
  RIGHT = 1;            // (utilizado na chamada ao procedure move)

Type
  T_coordinate = record // Coordenada cartesiana (x,y)
                   x : integer;                       
                   y : integer;                                                       
                 end;          


  T_objgrid = array[1..4, 1..4] of boolean;   // Forma de pe�as. Constituida por uma array bidimensional
                                              // de 4x4 do tipo boolean. Por exemplo, a forma da pe�a "L"
                                              // � representada da seguinte maneira:    0 0 1 0          
                                              //                                        1 1 1 0          
                                              // (0 = FALSE, 1 = TRUE)                  0 0 0 0          
                                              //                                        0 0 0 0          
                                                                                                         
  T_grid = record                 // Informa��es sobre um ponto do grid, se ele est�                                                                                                                                
             status : boolean;    // preenchido ou n�o (status) e de que cor ele est�                    
             color  : integer;    // preenchido, se for o caso.                                          
           end;                                                                                          

  T_object = record                     // Pe�as.
               pos   : T_coordinate;    // posi��o
               cell  : T_objgrid;       // formato 
               size  : integer;          // tamanho (ver coment�rio abaixo)
               color : integer;         // cor                             
             end;

Var
  grid : array[0..WidthPlusOne, 0..HeightPlusOne] of T_grid;    // Grid (incluindo bordas)
  obj  : T_object;                                              // Pe�a caindo no grid    
  next : T_object;                                              // Pr�xima pe�a (fixa)    

  level : integer;               // N�vel em que se encontra o jogador                    																																														
  score : integer;               // Pontua��o                                                                                                                                         
  cycle : record                                                                                            
            freq   : integer;    // Intervalo entre decaimentos da pe�a.
            status : integer;    // Tempo decorrido desde �ltimo decaimento.
            step   : integer;    // Tempo entre ciclos de execu��o. � a cada ciclo o programa
                                 // checa se o usu�rio pressionou alguma tecla.              
          end;                   // (medidas em milisegundos)



  orig      : T_coordinate;    // Origem - posi��o do canto superior esquerdo do grid na tela.
	gameover  : boolean;         // O jogo acabou?
  quit      : boolean;         // O usu�rio deseja sair do jogo?
                                       
  i, j      : integer;    // Contadores
  c         : char;       // Variavel auxiliar (recebe input)

{ ------------------------------------------------------------------
  Procedure Xclrscr: Fornecidos 4 pontos x1, y1, x2, y2, limpa uma 
  �rea na tela equivalente ao ret�ngulo de v�rtices superior       
  direito = (x1, y1) e inferior esquerdo = (x2, y2).                                                                                                                                                          
  Equivale a:     window( x1, y1, x2, y2 );                                                                                              
                  clrscr;
 ------------------------------------------------------------------ }
                         
Procedure Xclrscr( x1, y1, x2, y2 : integer );                
  Var x, y : integer;
  Begin
    for y := y1 to y2 do
    begin
      gotoxy(x1, y);
      for x := x1 to x2 do
          write(' ');
      end;           
  End;              

{ ------------------------------------------------------------------
  Function shock: Verifica se a pe�a est� livre para mover-se      
  horizontalmente xmov unidades e verticalmente ymov unidades.     
 ------------------------------------------------------------------ }
Function shock( xmov, ymov : integer ): boolean;
Var i, j   : integer;
    return : boolean;
Begin
	gotoxy(1,1);	
	return := FALSE;	
	
	for i := 1 to 4 do	
	    for j := 1 to 4 do	
	        if (obj.cell[i,j])	
	            and (obj.pos.x + i + xmov >= 0)	
	            and (obj.pos.x + i + xmov <= WIDTH+1)	
	            and (grid[obj.pos.x+i+xmov, obj.pos.y+j+ymov].status)   // esta condi��o precisa aparecer por �ltimo!	
	            then return := TRUE;                                                                                 	
	shock := return;	
End;              
{ ------------------------------------------------------------------
  Procedure rotate: Roda a pe�a no sentido hor�rio, se poss�vel.  
 ------------------------------------------------------------------ }


Procedure rotate;
Var i, j : integer;
    old  : T_objgrid;
Begin
	
	for i := 1 to 4 do
    for j := 1 to 4 do
        old[i,j] := obj.cell[i,j];

	for i := 1 to obj.size do
    for j := 1 to obj.size do
        obj.cell[i,j] := old[j,obj.size+1-i];

  if (shock(0,0)) then
    for i := 1 to 4 do
      for j := 1 to 4 do
      	obj.cell[i,j] := old[i,j];
End;                              
  
{ ------------------------------------------------------------------
  Procedure move: Move a pe�a para a direita ou para a esquerda,    
  se poss�vel.                                                      
 ------------------------------------------------------------------}
Procedure move( xmov : integer );                                   
Begin
  if (not shock(xmov, 0)) then 
		obj.pos.x := obj.pos.x + xmov;
End;                              

{ ------------------------------------------------------------------
  Procedure consolidate: Prende a pe�a ao local onde ela se         
  encontra. Ap�s isso, a pe�a perde seu status de pe�a e passa a    
  ser apenas parte do grid. Este procedimento � chamado quando a    
  pe�a chega ao fundo do grid, ou encontra com outra abaixo dela.   
 ------------------------------------------------------------------ }
Procedure consolidate;                                               
Var i, j : integer;                                                
Begin
  for i := 1 to 4 do
    for j := 1 to 4 do
      if (obj.cell[i,j]) then
      begin              
        grid[obj.pos.x+i, obj.pos.y+j].status := TRUE;
        grid[obj.pos.x+i, obj.pos.y+j].color := obj.color;                                                                    
      end;
End;

{ ------------------------------------------------------------------
  Procedure checklines: Checa se alguma linha do grid foi           
  completada. Se sim, apaga o conteudo dela, trazendo todas as      
  linhas acima para baixo (as linhas que est�o acima da que foi     
  completada 'caem'). Tamb�m recalcula o score, o level e o         
  cycle.freq.                                                       
 ------------------------------------------------------------------ }
Procedure checklines;
Var i, j, down  : integer;
    LineCleared : boolean;
Begin                     
	down := 0;                
	for j := HEIGHT downto 1 do
  begin                  
  	LineCleared := TRUE;   
    for i := 1 to WIDTH do 
    	if not (grid[i,j].status) then 
				LineCleared := FALSE;
    if (LineCleared) then
    begin     
		  down := down + 1;
		  score := score + 10;
    end                 																	
    else                    
    begin
	    for i := 1 to WIDTH do
      begin             
	      grid[i,j+down].status := grid[i,j].status;
	      grid[i,j+down].color := grid[i,j].color;  
      end;                                      
  	end; 	   
  end;                                                  

  level := score div 200;                               
  cycle.freq := trunc( 500 * exp(level*ln(0.85)) );

  textcolor(YELLOW);                                    
  gotoxy( orig.x + (WIDTH+2)*2 + 18, orig.y + 15 );     
  write(level);                                         
  gotoxy( orig.x + (WIDTH+2)*2 + 30, orig.y + 15 );     
  write(score);                                         
End;

{ ------------------------------------------------------------------
  Procedure hideobj: esconde a pe�a da tela.                        
 --------------------------------------------------------------- }  
Procedure hideobj( obj : T_object );
Var i, j : integer;
Begin
  
	for i := 1 to 4 do
	  for j := 1 to 4 do
      if (obj.cell[i,j]) then
      begin              
	      gotoxy( orig.x + (obj.pos.x + i) * 2, orig.y + obj.pos.y+j );
	      write('  ');                                                 
      end;
  
	gotoxy( orig.x, orig.y );
End;

{ ------------------------------------------------------------------
  Procedure drawobj: desenha a pe�a na tela.                        
 ------------------------------------------------------------------ }
Procedure drawobj( obj : T_object );                               
Var i, j : integer;
Begin

  textcolor(obj.color);

  for i := 1 to 4 do
    for j := 1 to 4 do
      if (obj.cell[i,j]) then
      begin
	      gotoxy( orig.x + (obj.pos.x + i) * 2, orig.y + obj.pos.y + j );
	
	      write(#219, #219);
			end;

  	gotoxy( orig.x, orig.y );

End;

{ ------------------------------------------------------------------
  Procedure refresh: redesenha todo o grid na tela.
 ------------------------------------------------------------------ }                                                              
Procedure refresh;
Var i, j : integer;
Begin

  for i := 0 to WIDTH+1 do
    for j := 0 to HEIGHT+1 do
    begin
    
    	gotoxy( orig.x + 2*i, orig.y + j );

      if (grid[i,j].status) then
      begin
      	textcolor(grid[i,j].color);
      	write(#219, #219);
      end
  		else   
      	write('  ');
	end;
	
	gotoxy( orig.x, orig.y );
End;

{ ------------------------------------------------------------------
  Procedure createtgt: pega a pe�a j� gerada anteriormente que est� 
  na caixa "next" (vari�vel next) e a transforma na pe�a atual.     
  Depois, gera nova pe�a randomicamente, posicionando-a na caixa    
  "next".                                                           
 ------------------------------------------------------------------ }
Procedure createtgt;
Var i, j : integer;
Begin
  hideobj(next);
  obj := next;  
  obj.pos.x := WIDTH div 2 - 2;
  obj.pos.y := 0;               
  next.pos.x := WIDTH + 4;      
  next.pos.y := 6;              
  
  for i := 1 to 4 do
    for j := 1 to 4 do
    	next.cell[i,j] := FALSE;

  case random(8) of
	    0: begin                    // Quadrado
	         next.cell[2,2] := TRUE;             
	         next.cell[2,3] := TRUE;             
	         next.cell[3,2] := TRUE;             
	         next.cell[3,3] := TRUE;             
	         next.size := 4;                     
	         next.color := WHITE;                
         end;
      1: begin                   // Retangulo
	         next.cell[2,1] := TRUE;             
	         next.cell[2,2] := TRUE;             
	         next.cell[2,3] := TRUE;             
	         next.cell[2,4] := TRUE;             
	         next.size := 4;                     
	         next.color := LIGHTRED;             
         end;
      2: begin                    // "L"
	         next.cell[3,2] := TRUE;       
	         next.cell[1,3] := TRUE;       
	         next.cell[2,3] := TRUE;       
	         next.cell[3,3] := TRUE;       
	         next.size := 3;                                                      
	         next.color := LIGHTGREEN;     
         end;
      3: begin                    // "L" invertido
	         next.cell[1,2] := TRUE;
	         next.cell[1,3] := TRUE;
	         next.cell[2,3] := TRUE;
	         next.cell[3,3] := TRUE;
	         next.size := 3;        
	         next.color := LIGHTBLUE;
         end;
      4: begin                    // "S"
	         next.cell[2,2] := TRUE;
	         next.cell[2,3] := TRUE;
	         next.cell[3,1] := TRUE;
	         next.cell[3,2] := TRUE;
	         next.size := 4;        
	         next.color := LIGHTCYAN;
         end;
      5: begin                    // "Z"
	         next.cell[2,2] := TRUE;        
	         next.cell[2,3] := TRUE;        
	         next.cell[3,3] := TRUE;        
	         next.cell[3,4] := TRUE;        
	         next.size := 4;                
	         next.color := LIGHTMAGENTA;    
         end;
      6: begin                    // "T"
	         next.cell[1,2] := TRUE;
	         next.cell[2,1] := TRUE;
	         next.cell[2,2] := TRUE;
	         next.cell[2,3] := TRUE;
	         next.size := 3;        
	         next.color := LIGHTGRAY;
         end;
      7: begin                    // "T"
	         next.cell[1,1] := TRUE;
	         next.cell[1,3] := TRUE;
	         next.cell[2,1] := TRUE;
	         next.cell[2,2] := TRUE;
	         next.cell[2,3] := TRUE;
					 next.size := 3;        
	         next.color := RED;
         end;
      end;   

  	drawobj(next);
  End;                                                               
  
{ ------------------------------------------------------------------
  Procedure prninfo: imprime as informa��es presentes ao lado       
  do grid (contorno da caixa "next" e comandos do jogo).            
 ------------------------------------------------------------------ }
Procedure prninfo( xpos, ypos : integer );
Begin
  Xclrscr( xpos, ypos, 80, 24 );

  
  textcolor(WHITE);             												
  gotoxy( xpos, ypos+0 );
  write(#218, #196, #196, ' Next ', #196, #196, #191);
  gotoxy( xpos, ypos+1 );
  write(#179, '          ', #179);
  gotoxy( xpos, ypos+2 );
  write(#179, '          ', #179);
  gotoxy( xpos, ypos+3 );
  write(#179, '          ', #179);
  gotoxy( xpos, ypos+4 );
  write(#179, '          ', #179);
  gotoxy( xpos, ypos+5 );
  write(#179, '          ', #179);
  gotoxy( xpos, ypos+6 );
  write(#179, '          ', #179);
  gotoxy( xpos, ypos+7 );
  write(#192, #196, #196, #196, #196, #196, #196, #196, #196, #196, #196, #217);
  textcolor(YELLOW);  
  gotoxy( xpos, ypos+10 );
  write('       Level: 0    Score: 0');
  gotoxy( xpos+12, ypos+1 );
  write('Controles:');
  gotoxy( xpos+12, ypos+2 );
  write('  Mover : [setas]');
  gotoxy( xpos+12, ypos+3 );
  write('  Girar : [space]');
  gotoxy( xpos+12, ypos+4 );
  write('  Cair  : [enter]');
  gotoxy( xpos+12, ypos+5 );
  write('  Pausa : "P"');
  gotoxy( xpos+12, ypos+6 );
  write('  Sair  : [esc]');
  
  textcolor(WHITE);             												
  xpos := xpos + 30;									
  gotoxy( xpos, ypos+0 );
	writeln('             ,----------------,              ,---------,');
	gotoxy( xpos, ypos+1 );
	writeln('        ,-----------------------,          ,"        ,"|');
	gotoxy( xpos, ypos+2 );
	writeln('      ,"                      ,"|        ,"        ,"  |');
	gotoxy( xpos, ypos+3 );
	writeln('     +-----------------------+  |      ,"        ,"    |');
	gotoxy( xpos, ypos+4 );
	writeln('     |  .-----------------.  |  |     +---------+      |');
	gotoxy( xpos, ypos+5 );
	writeln('     |  |                 |  |  |     | -==---- |      |');
	gotoxy( xpos, ypos+6 );
	writeln('     |  |     TETRIS!     |  |  |     |         |      |');
	gotoxy( xpos, ypos+7 );
	writeln('     |  |     Made by:    |  |  |/----|`---=    |      |');
	gotoxy( xpos, ypos+8 );
	writeln('     |  |   Zeh Luckmann  |  |  |   ,/|==== ooo |      ;');
	gotoxy( xpos, ypos+9 );
	writeln('     |  |                 |  |  |  // |(((( [33]|    ," ');
	gotoxy( xpos, ypos+10 );
	writeln('     |  `-----------------�  |," .;�| |((((     |  ,"   ');
	gotoxy( xpos, ypos+11 );
	writeln('     +-----------------------+  ;;  | |         |,"     ');
	gotoxy( xpos, ypos+12 );
	writeln('        /_)______________(_/  //�   | +---------+       ');
	gotoxy( xpos, ypos+13 );
	writeln('   ___________________________/___  `,                  ');
	gotoxy( xpos, ypos+14 );
	writeln('  /  oooooooooooooooo  .o.  oooo /,   \,"-----------    ');
	gotoxy( xpos, ypos+15 );
	writeln(' / ==ooooooooooooooo==.o.  ooo= //   ,`\--{)B     ,"    ');
	gotoxy( xpos, ypos+16 );
	writeln('/_==__==========__==_ooo__ooo=_/�   /___________,"      ');
	

  
End;

{ ------------------------------------------------------------------
  Procedure prnGameover: imprime mensagem de "game over" ao lado    
  do grid.
 ------------------------------------------------------------------ }
Procedure prnGameover( xpos, ypos : integer );
Begin
  Xclrscr( xpos, ypos, 80, 24 );

  textcolor(WHITE);
  gotoxy( xpos, ypos+2 );
  writeln('    * * *   SE FUDEU!  * * *');
	gotoxy( xpos, ypos+6 );
  write('Deseja iniciar um ');
  textcolor(LIGHTRED);
  write('N');
  textcolor(WHITE);
  write('ovo jogo ou ');
  textcolor(LIGHTRED);
  write('S');
  textcolor(WHITE);
  write('air?');
End;

{ ------------------------------------------------------------------
                       PROGRAMA PRINCIPAL
 ------------------------------------------------------------------}
Begin                                                               
	randomize;
	
	orig.x := 2;	
	orig.y := 2;	
	clrscr;
	
	gotoxy( orig.x + (WIDTH+2)*2 + 5, orig.y + 1 );
	
	textcolor(WHITE);
	
	repeat
	  prninfo( orig.x + (WIDTH+2)*2 + 4, orig.y + 5 );
		for i := 0 to WIDTH+1 do              // Preenche todo o grid (inclusive bordas)
	   	for j := 0 to HEIGHT+1 do	
    	begin
    		grid[i,j].status := TRUE;
    		grid[i,j].color := DARKGRAY;
    	end;
				
	  for i := 1 to WIDTH do                // Esvazia �rea interna do grid (deixando apenas	
      for j := 1 TO HEIGHT do           // as bordas preenchidas)	
        grid[i,j].status := FALSE;
	
	  refresh;	
	  gameover := FALSE;	
	  quit := FALSE;
	  cycle.freq := 500;
	  cycle.step := 50;
	  cycle.status := 0;
	  score := 0;
	  createtgt;
	  createtgt;
	  refresh;

	  while not (gameover or quit) do	
	  begin
			if (keypressed) then    // Se o usu�rio pressionou uma tecla (keypressed = TRUE),	
	    begin               		// � preciso agir de acordo com o comando correspondente.	
	      case upcase(readkey) of
					
          	#0: case (readkey) of
	          	#75: begin           // seta para esquerda
									hideobj(obj);
			            move(left);
		              drawobj(obj);
	            	end;
	
             #77: begin           // seta para direita
	                  hideobj(obj);
	                  move(right); 
	                  drawobj(obj);
                  end;

             #80: cycle.status := 0;    // seta para baixo
						 			end;
	
	           #13: begin                     // [enter]	
	                  while (not shock(0,1)) do	
	                    obj.pos.y := obj.pos.y + 1;	
	                  	cycle.status := 0;             	
	                  end;
											
	          	#27: quit := TRUE;   // [esc
	
	            #32: begin           // espa�o	
		                  hideobj(obj);          	
		                  rotate;                	
		                  drawobj(obj);          	
	                  end;
	
             'P': begin
	                  textbackground(LIGHTGRAY);	
	                  for i := 1 to WIDTH do    	
	                      for j := 1 to HEIGHT do	
	                      begin	
	                        gotoxy( orig.x + 2*i, orig.y + j );	
	                        write('  ');	
	                      end;
	
	                  textbackground(BLACK);	
	                  textcolor(LIGHTGRAY);
	                                        
	                  gotoxy( orig.x + WIDTH - 2, orig.y + HEIGHT div 2 - 1 );	
	                  write('       ');                                       	
	                  gotoxy( orig.x + WIDTH - 2, orig.y + HEIGHT div 2 );    	
	                  write(' PAUSE ');                                       	
	                  gotoxy( orig.x + WIDTH - 2, orig.y + HEIGHT div 2 + 1 );	
	                  write('       ');                                       	
	                  gotoxy( orig.x, orig.y );                               	
	                	repeat                                                  	
	                      c := upcase(readkey);                               	
	                  until (c = 'P') or (c = #27);                           	
	                  if (c = #27) then quit := TRUE;                         	
		                  refresh;                                                	
		                  drawobj(obj);                                           	
	                  end;	
	             end;	
	          end;   
	
	      if (cycle.status < cycle.step) then    // J� est� na hora de fazer um decaimento?	
	      begin                                  // Se sim...	
        	hideobj(obj);          // esconde pe�a
	          if (shock(0,1))	then               	
            begin               // Se a pe�a n�o pode mover-se para baixo:
						 	consolidate;      // ancora a pe�a
            	checklines;       // checa por linhas completadas
            	refresh;          // redesenha todo o grid
            	createtgt;        // cria nova pe�a
            if shock(0, 0) then gameover := TRUE;  // caso j� n�o haja espa�o no grid para essa nova pe�a,
      			end                                    // o jogo est� acabado
       			else               // Se a pe�a pode mover-se para baixo:
            	obj.pos.y := obj.pos.y + 1;    // move a pe�a para baixo	
	          	drawobj(obj);          // desenha pe�a	
	          end;		
	      cycle.status := (cycle.status + cycle.step) mod cycle.freq;
					
	      delay(cycle.step);	
	
	    end;
	          	
  if (quit) then break;

  prnGameover( orig.x + (WIDTH+2)*2 + 4, orig.y + 5 );

  repeat	
      c := upcase(readkey);

  until (c = 'N') or (c = 'S');  	
	until (c = 'S');		
	clrscr;
	gotoxy( 25, 12 );
	textcolor(WHITE);
	write('Pressione [ENTER] para sair seu puto . . .');
  
End.