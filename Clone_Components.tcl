#----------------------------------------------------------------------------
	# Clear All Marks
	#----------------------------------------------------------------------------
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
	}

#CLONE PART Multi#

proc dup_the_parts { } {
Clear_All_Marks
while 1 {
	set nclst [list]
	*createmarkpanel elems 1
	set dupelems [hm_getmark elems 1]
	if {[llength $dupelems] == 0} {
	return
	}
	*createmarkpanel comps 1
	set uoldcomp [hm_getmark comps 1]
	set newnamecomp [hm_getstring "Preifix for new comp="]

	foreach oldcomp $uoldcomp {
		set ocname [hm_getcollectorname comps $oldcomp]
		*clearmark elements 1
		*createmark elems 1 "by comp name" $ocname
		set compelems [hm_getmark elems 1]
		set oldprop [hm_getentityvalue comps $oldcomp "property.id" 0 -byid]
		set opname [hm_getcollectorname props $oldprop]
		set npname [list]
		set ncname [list]
		append npname "$newnamecomp" _$opname
		append ncname "$newnamecomp" _$ocname
		set ccc [hm_entityinfo exist comp "$ncname" -byname]
		set ppp [hm_entityinfo exist comp "$npname" -byname]
			if { $ccc == 1 && $ppp == 1 } {
				tk_messageBox -message "Component with this name Already exist. Please Use Diffrent Prifix" -title "Hypermesh" \
		    		-type ok -icon info; Clear_All_Marks
	       			 return;
			} else {
			}
		*collectorcreateonly properties "$npname" "$opname" 56
		*collectorcreateonly components "$ncname" "$ocname" 56
		*createmark components 1 "by name" "$ncname"
		*propertyupdate components 1 "$npname"
		lappend nclst $ncname
		eval *createmark elems 1 $dupelems
		eval *createmark elems 2 $compelems
		*markintersection elems 1 elems 2
		*movemark elems 1 "$ncname"
	}

	if {[llength $nclst] != 0} {
	eval *createmark comps 2 "by name" "$nclst"
		*autocolorwithmark components 2 }
		Clear_All_Marks
	}
}

 dup_the_parts
