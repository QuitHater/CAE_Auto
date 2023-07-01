
*createmarkpanel elems 1
set usrelems [hm_getmark elems 1]

set delemes1 [list]

foreach elid $usrelems {
eval *createmark elements 1 $elid
*findmark elements 1 257 1 elements 0 2
set f_elems [hm_getmark elems 2]
if {[llength $f_elems] == 2} {
	set elone [lindex $f_elems 0]
	set eltwo [lindex $f_elems 1]
	
	lappend delemes1 $elone $eltwo
	
	set allnds1 [hm_getvalue elems id=$elone dataname=nodes]
	set mstnds1 [hm_getvalue elems id=$elone dataname=node1]
	
	set rignode1 [lremove $allnds1 $mstnds1]
	
	set allnds2 [hm_getvalue elems id=$eltwo dataname=nodes]
	set mstnds2 [hm_getvalue elems id=$eltwo dataname=node1]
		set rignode2 [lremove $allnds2 $mstnds2]
		
		set allrignods [list]
		append allrignods $rignode1 $rignode2
		
eval *createmark nodes 2 $allrignods
*rigidlinkinodecalandcreate 2 0 1 123456

}


}
set delemes2 [list]
set delemes2 [join $delemes1]

if {[llength $usrelems] == 1} {set delemes2 $delemes1}

eval *createmark elems 2 $usrelems
*deletemark elems 2

eval *createmark elems 2 $delemes2
*deletemark elems 2