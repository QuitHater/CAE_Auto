#####################################################################
# File			: Auto_Organize_Dup_Components.tcl
# Date			: 05.03.2021
# Created		: Sriram S
# E-Mail		: s.sriram@blr.hepaticatech.com
# Project		: All
# Purpose		: To organize the duplicate components to its original components which already exist in the model.
# Version		: v1.0
#####################################################################
# Changes:
#
# v1.0    05.03.2021
#          - First Release
#
#####################################################################
#####################################################################




proc Clear_All_Marks { } {
		*clearmark nodes 1
		*clearmark nodes 2
		*clearmark elements 1
		*clearmark elements 2
		*clearmark lines 1
		*clearmark lines 2
		*clearmark surfaces 1
		*clearmark surfaces 2
		*clearmark solids 1
		*clearmark solids 2
		*clearmark comps 1
		*clearmark comps 2
		*clearmark props 2
		*clearmark props 1
	}



proc DumComp { } {

set solver_id [hm_getsolver id]
if {$solver_id == 2 } {set char {\:1}}
if {$solver_id == 9 } {set char {\.1}}
if {$solver_id == 1 } {set char {\.1}}


variable c_nme
variable all_comps_names



	*createmark components 1 "all"
	set allcomps [hm_getmark components 1]
	set all_comps_names [list]
	foreach cur_comps $allcomps {
		lappend all_comps_names [hm_getcollectorname components $cur_comps]
				}

	*createmark components 2 "displayed"
	set needed_comps [hm_getmark components 2]

	set n 0
	set blacklist_comp [list]
	puts 1
	foreach cur_cmps $needed_comps {
		set c_nme [hm_getcollectorname components $cur_cmps]
		puts $c_nme
		if {[regexp "$char" $c_nme] == 1} { puts check
			set chnge_name [regsub "$char" $c_nme ""]
		puts chek2
			if {[lsearch $all_comps_names $chnge_name] != -1 } {set to_comps $chnge_name
					Move_Comps $cur_cmps $to_comps
					puts 11
				 	lappend blacklist_comp $c_nme
									}
							}
				}
				if {[llength $blacklist_comp] >= 1} {Dup_DeleteComps $blacklist_comp}
}

proc Move_Comps {frm_cids to_cname} {

	*clearmark elements 1
	*createmark elements 1 "by component id" $frm_cids
	*movemark elements 1 $to_cname
	*clearmark elements 1

}

proc Dup_DeleteComps {complst} {

	foreach cur_delsets $complst {
			Clear_All_Marks
			set blk_props [hm_getvalue component name="$cur_delsets" dataname=propertyid]
			
				*createmark comps 1 "by name" $cur_delsets
				*deletemark comps 1
			if {$blk_props > 0} {
				*createmark props 1 $blk_props
				*deletemark props 1
					}
			}

}


Clear_All_Marks
DumComp
