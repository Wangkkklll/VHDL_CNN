pll_clk_inst : pll_clk PORT MAP (
		areset	 => areset_sig,
		inclk0	 => inclk0_sig,
		c0	 => c0_sig,
		c1	 => c1_sig,
		c2	 => c2_sig,
		locked	 => locked_sig
	);
