source $::env(SCRIPTS_DIR)/load.tcl
# Might also need place vars..
# erase_non_stage_variables floorplan
load_design 2_1_floorplan.odb 2_1_floorplan.sdc

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
	
	# NOTE: use -skip_io as IO placement only happens *after* placement in phase 3
	set all_args [concat [list -density [place_density_with_lb_addon] \
    -pad_left $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT) \
    -pad_right $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT)] \
		-skip_io \
    $global_placement_args]

  lappend all_args {*}[env_var_or_empty GLOBAL_PLACEMENT_ARGS]

	log_cmd global_placement {*}$all_args
}

# LEO: Switch between macro placers
# Hierarchical MP
if {$::env(MACRO_STRATEGY) == "HIER_RTLMP"} {
	source $::env(SCRIPTS_DIR)/macro_place_util.tcl
}

# My legalize strat after placement
if {$::env(MACRO_STRATEGY) == "LEGALIZE"} {
	# Generate a global placement to legalize
	remove_buffers
	do_placement
	
	# Legalize macros
	set leg_args {}
	lappend leg_args -halo_width $::env(MACRO_PLACE_HALO)
	lappend leg_args {*}[env_var_or_empty LEGALIZATION_ARGS]

	log_cmd legalize_macros {*}$leg_args
}

# Source check_overlaps to potentially unplace stdcells again
source $::env(SCRIPTS_DIR)/check_overlaps.tcl

write_db $::env(RESULTS_DIR)/2_2_floorplan_macro.odb
