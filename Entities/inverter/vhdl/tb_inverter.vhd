-- This is an inverter VHDL model
-- Initially written by Marko Kosunen
-- Last modification by Marko Kosunen, marko.kosunen@aalto.fi, 08.08.2017 17:35
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE std.textio.all;

ENTITY tb_inverter IS
    GENERIC(g_Rs     : real := 1.0e9;
            g_infile : STRING:="/tools/designs/mkosunen/mkosunen/FADER_MATLAB/OO_MIMO/simulations/Inverter/Modelsim/A.txt";
            g_outfile: STRING:="/tools/designs/mkosunen/mkosunen/FADER_MATLAB/OO_MIMO/simulations/Inverter/Modelsim/Z.txt"

           ); 
END ENTITY;

ARCHITECTURE behav OF tb_inverter IS

--FILE f_infile : text open read_mode  is "/tools/designs/mkosunen/mkosunen/FADER_MATLAB/OO_MIMO/simulations/Inverter/Modelsim/infile.txt";
FILE f_infile  : text open read_mode  is g_infile; 
FILE f_outfile : text open write_mode is g_outfile;

--These are to synchronize operation and end the simulation properly
SIGNAL s_clk : STD_LOGIC:='0';
SIGNAL s_EOF: BOOLEAN:=FALSE;
SIGNAL s_done: BOOLEAN:=FALSE;
--
--Design signals
CONSTANT c_tsample: time := real(1.0e12/g_Rs)*1 ps;    
SIGNAL s_A   : STD_LOGIC;
SIGNAL s_z   : STD_LOGIC;


--This probably could be written in asynchronous manner
--By controlling the read and write with two pocesses
--but it is easier to synchronize
BEGIN
clkgen:PROCESS
    BEGIN
        WHILE (NOT s_done) LOOP
            s_clk<=NOT s_clk;
            WAIT FOR  c_tsample/2;
        END LOOP;
        WAIT;
END PROCESS;

reader:PROCESS(s_clk)
    VARIABLE v_inline  : LINE;
    VARIABLE v_dataread: BIT_VECTOR(0 DOWNTO 0);
    VARIABLE v_A       : STD_LOGIC_VECTOR(0 DOWNTO 0);
    BEGIN
        IF  (NOT s_EOF) THEN
          IF rising_edge(s_clk) THEN
              readline(f_infile, v_inline); 
              read( v_inline , v_dataread);
              v_A:=to_stdlogicvector(v_dataread);
              s_A<=v_A(0);
          END IF;
      END IF;
      IF (endfile(f_infile)) THEN
          s_EOF<=TRUE;
      END IF;
END PROCESS;

writer:PROCESS(s_clk)
    VARIABLE v_outline  : LINE;
    VARIABLE v_datawrite: BIT;
    BEGIN
        v_datawrite:=to_bit(std_ulogic(s_Z));
    IF  (NOT s_done) THEN
      IF falling_edge(s_clk) THEN
          write( v_outline , v_datawrite);
          writeline(f_outfile, v_outline); 
          IF (s_EOF) THEN
              s_done<=TRUE;
          END IF;
      END IF;
  END IF;
END PROCESS;


DUT: ENTITY work.inverter(rtl)
    PORT MAP (A => s_A,
              Z => s_Z
             );
        
END ARCHITECTURE;

