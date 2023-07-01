proc rrename {} {
set modified_name [hm_getstring]
*createmark comps 1 "displayed"
set comps_id_a [hm_getmark comps 1]
set dup_list [list]
set displ [list]
set us_sa [list]
set string ""
set string1 ""
foreach id_a $comps_id_a {
	set thickne_a [hm_getthickness comps $id_a]
     if {$thickne_a == 0.0} {
	continue
	}
	*createmark comps 2 $id_a
	set proper_a [hm_getvalue comps mark=2 dataname=propertyid]
	set props_name_a [hm_getcollectorname props $proper_a]
	set compon_name_a [hm_getcollectorname comps $id_a]
	set thickvalue [format %.0f [expr ($thickne_a * 100)]]
	if {$thickne_a < 1.0} {
	set new_name [append string $modified_name 0$thickvalue]
	} else {
	set new_name [append string $modified_name $thickvalue]
	}
	set dup_name_list [lsearch -all $dup_list $new_name]
	lappend dup_list $new_name	
	if {[llength $dup_name_list] > 0} {
		eval *createmark elems 2 "by comp name" "$compon_name_a"
                *movemark elements 2 $new_name
		set displ [append string1 $compon_name_a\n]
		lappend us_sa $compon_name_a
		set string ""
		continue
	}
	*renamecollector components "$compon_name_a" "$new_name"
	*renamecollector properties "$props_name_a" "$new_name"
	set string ""
}      
	if {[llength $displ] > 0} {
		if {[llength $displ] < 10} {
	  tk_messageBox -message "duplicate thickness found in \n$displ component names"
}
	  *EntityPreviewEmpty components 1
	  *deletemark components 1
          *EntityPreviewUnused properties 1
	  *deletemark properties 1
}
}
*startnotehistorystate {hst}
rrename
*endnotehistorystate {hst}
