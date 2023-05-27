ram_input_inst : ram_input PORT MAP (
		clock	 => clock_sig,
		data	 => data_sig,
		rdaddress	 => rdaddress_sig,
		rden	 => rden_sig,
		wraddress	 => wraddress_sig,
		wren	 => wren_sig,
		q	 => q_sig
	);
