library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
entity PWM is
generic(
DATA_WIDTH : POSITIVE :=17
);
port(
    CLK     :  in std_logic;
    RST     :  in std_logic;
    S0      :  in std_logic;
    OFFT_I  :  in std_logic_vector(DATA_WIDTH-1 downto 0);
    PERIOD_I:  in std_logic_vector(DATA_WIDTH-1 downto 0);
    PWM_O 	:  out std_logic;
    FINISH  :  out std_logic;
	 y0,y1,y2,y3: out std_logic
);
end PWM;
architecture rtl of PWM is
	--REG
	signal X0,X1,X2,X3 : std_logic;
	--type STATE_TYPE_M0 is(X0,X1,X2,X3);
	--signal STATE_M0: STATE_TYPE_M0;
	signal CNT_REG: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal PWM_REG: std_logic;
	signal FINISH_REG: std_logic;
begin
--GRAFCET CONTROLLER
GRAFCET:PROCESS(CLK,RST)
BEGIN
	IF RST='1' THEN
		X0<='1';X1<='0';X2<='0';X3<='0';
	ELSIF CLK'EVENT AND CLK='1' THEN
		IF X0='1'AND S0='1' AND OFFT_I/=0 AND PERIOD_I/=0 THEN X0<='0'; X1<='1';
		ELSIF X1='1' AND CNT_REG=OFFT_I THEN X1<='0'; X2<='1';
		ELSIF X2='1' AND CNT_REG=PERIOD_I THEN X2<='0';X3<='1';
		ELSIF X3='1' THEN X3<='0';X0<='1';
		END IF;
	END IF;
END PROCESS GRAFCET;

DATAPATH:PROCESS(CLK,X0,X1,X2,X3)
BEGIN
	IF CLK'EVENT AND CLK='1' THEN
		IF X0='1' THEN CNT_REG<=(others=>'0');FINISH_REG<='0';PWM_REG<='Z';
		ELSIF X1='1' THEN PWM_REG<='0';CNT_REG<=CNT_REG+1;
		ELSIF X2='1' THEN PWM_REG<='1';CNT_REG<=CNT_REG+1;
		ELSIF X3='1' THEN FINISH_REG<='1';
		END IF;
	END IF;
END PROCESS DATAPATH;
PWM_O<=PWM_REG;
FINISH<=FINISH_REG;
y0<=X0;
y1<=X1;
y2<=X2;
y3<=X3;
END rtl;
