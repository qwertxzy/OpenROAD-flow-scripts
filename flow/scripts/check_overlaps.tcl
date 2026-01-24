# TODO: where to put this
set unplace_threshold 1000

# Helper function to check if an instance is a standard cell
proc is_std_cell {inst} {
  set master [$inst getMaster]
  return [expr {[$master getType] == "CORE"}]
}

# Helper function to check if an instance is a macro
proc is_macro {inst} {
  set master [$inst getMaster]
  set type [$master getType]
  return [expr {$type == "BLOCK" || $type == "BLOCK_SOFT"}]
}

# Helper function to check if two rectangles overlap
proc rects_overlap {rect1 rect2} {
  set x1_min [lindex $rect1 0]
  set y1_min [lindex $rect1 1]
  set x1_max [lindex $rect1 2]
  set y1_max [lindex $rect1 3]

  set x2_min [lindex $rect2 0]
  set y2_min [lindex $rect2 1]
  set x2_max [lindex $rect2 2]
  set y2_max [lindex $rect2 3]

  # Check if rectangles do NOT overlap
  if {$x1_max <= $x2_min || $x2_max <= $x1_min ||
    $y1_max <= $y2_min || $y2_max <= $y1_min} {
    return 0
  }
  return 1
}

# Get the design block
set block [ord::get_db_block]

# Get all instances
set all_insts [$block getInsts]

# Separate macros and standard cells
set macros [list]
set std_cells [list]

foreach inst $all_insts {
  if {[is_macro $inst]} {
    lappend macros $inst
  } elseif {[is_std_cell $inst]} {
    # Skip standard cells with placement status NONE (unplaced)
    set placement_status [$inst getPlacementStatus]
    if {$placement_status != "NONE"} {
      lappend std_cells $inst
    }
  }
}

puts "Found [llength $macros] macros and [llength $std_cells] placed standard cells"

# Determine whether standard cells should be unplaced again in any case
# (env(MACRO_UNPLACE_STD) exists and is true-ish)
if {[info exists ::env(MACRO_UNPLACE_STD)]} {
  set unplace_std $::env(MACRO_UNPLACE_STD)
} else {
  set unplace_std 0
}

# If thats not the case, do the overlap check to decide
if { ! $unplace_std } {
  # Find the macro with maximum overlapping standard cells
  set max_overlap_count 0
  set max_overlap_macro ""

  foreach macro $macros {
    set macro_name [$macro getName]
    set macro_bbox [$macro getBBox]
    set macro_rect [list [$macro_bbox xMin] [$macro_bbox yMin] [$macro_bbox xMax] [$macro_bbox yMax]]

    # Calculate macro area
    set macro_width [expr {[$macro_bbox xMax] - [$macro_bbox xMin]}]
    set macro_height [expr {[$macro_bbox yMax] - [$macro_bbox yMin]}]

    set overlap_count 0

    foreach std_cell $std_cells {
      set cell_bbox [$std_cell getBBox]
      set cell_rect [list [$cell_bbox xMin] [$cell_bbox yMin] [$cell_bbox xMax] [$cell_bbox yMax]]

      if {[rects_overlap $macro_rect $cell_rect]} {
        incr overlap_count
      }
    }

    if {$overlap_count > $max_overlap_count} {
      set max_overlap_count $overlap_count
      set max_overlap_macro $macro_name
    }
  }

  puts "========================================="
  puts "Maximum Overlap Result:"
  puts "  Macro with most overlaps: $max_overlap_macro"
  puts "  Number of overlapping standard cells: $max_overlap_count"
  if { $max_overlap_count > $unplace_threshold } {
    puts "  Number of overlapping standard cells exceeds threshold of $unplace_threshold"
    set unplace_std 1
  }
  puts "========================================="
}

if { $unplace_std } {
  puts "Unplacing all standard cells"
  foreach inst [$block getInsts] {
    if {[is_std_cell $inst]} {
      $inst setPlacementStatus NONE
    }
  }
}
