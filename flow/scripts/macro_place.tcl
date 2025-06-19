source $::env(SCRIPTS_DIR)/load.tcl
# Might also need place vars..
# erase_non_stage_variables floorplan
load_design 2_2_floorplan_io.odb 2_1_floorplan.sdc

puts "Using Strategy $::env(MACRO_STRATEGY)"

# LEO: Global Place helper proc
# should do just as well as the GPL step, which can then just skip ahead
proc do_placement {} {
	set global_placement_args {}

	# Parameters for routability mode in global placement
	if {$::env(GPL_ROUTABILITY_DRIVEN)} {
		lappend global_placement_args {-routability_driven}
	}

	# Parameters for timing driven mode in global placement
	if {$::env(GPL_TIMING_DRIVEN)} {
		lappend global_placement_args {-timing_driven}
	}
	
	set all_args [concat [list -density [place_density_with_lb_addon] \
    -pad_left $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT) \
    -pad_right $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT)] \
    $global_placement_args]

	lappend all_args {*}$::env(GLOBAL_PLACEMENT_ARGS)

	log_cmd global_placement {*}$all_args
}

# Determine whether standard cells should be unplaced again or not
# Criteria are either: TritonMP flow is used
# Or: env(MACRO_UNPLACE_STD) exists and is true-ish
if {$::env(MACRO_STRATEGY) == "TRITON"} {
	set unplace_std 1
} elseif {[info exists ::env(MACRO_UNPLACE_STD)]} {
	set unplace_std $::env(MACRO_UNPLACE_STD)
}

if { $unplace_std } {
	puts "Also unplacing stdcells after this step again"
}

# LEO: Switch between macro placers
# Hierarchical MP
if {$::env(MACRO_STRATEGY) == "HIER_RTLMP"} {
	source $::env(SCRIPTS_DIR)/macro_place_util.tcl
}

# Legacy (Triton) Placer
if {$::env(MACRO_STRATEGY) == "TRITON"} {
	remove_buffers
	do_placement
	macro_placement -halo $::env(MACRO_PLACE_HALO) -channel $::env(MACRO_PLACE_CHANNEL)
}

# My legalize strat after placement
if {$::env(MACRO_STRATEGY) == "LEGALIZE"} {
	# Generate a global placement to legalize
	remove_buffers
	do_placement
	
	# Legalize macros
	fix_macros -halo_width $::env(MACRO_PLACE_HALO)
}

if { $unplace_std } {
	mpl2::unplace_std_cells
}

write_db $::env(RESULTS_DIR)/2_3_floorplan_macro.odb
