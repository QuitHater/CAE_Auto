#####################################################################
# File			: Skoda_Check_V2.tcl
# Date			: 04.07.2019
# Created		: S.Sriram
# E-Mail		: s.sriram@blr.hepaticatech.com
# Project		: Skoda Related
# Purpose		: Check Minimum Quality for Skoda Projects
# Version		: v2.0
#####################################################################
# Changes:
#
# v2.0     04.07.2019 
#          - Second Release
#
#####################################################################
#####################################################################




namespace eval ::Skoda_Minium_Check {

	variable tabname "Skoda_Check"
	variable main

	variable fvalue 0.0
	variable uvalue ""
	variable trivalue ""


#----------------------------------------------------------------------------
	# ClearMarks##
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
	}


#----------------------------------------------------------------------------
	# OverallMin ##
	#----------------------------------------------------------------------------
	proc all_elems {} {

		Clear_All_Marks
		set elist [list];
		*createmark comps 1 "displayed"
		set compA [hm_getmark comps 1]

		foreach compB $compA {
			set thickn [hm_getthickness comps $compB]
			set n [expr {$thickn*1.101}]
			eval *createmark elems 1 "by comps" $compB
			*elementtestlength elements 1 $n 2 1 2 0 "  2D Length <  "	
			set femls [hm_getmark elems 2]
				if {[llength $femls] > 0} {
				lappend elist $femls}
		}       
		set finalel [join $elist]
		eval *createmark elems 1 $finalel
		set aemls [hm_getmark elems 1]
		if {[llength $aemls ] > 0 } {
			*displaycollectorwithfilter components "none" "" 1 0
			*findmark elements 1 0 1 elements 0 2
			*clearmark elements 2
		} else {tk_messageBox -message "No Elements are fails"}

		}


#----------------------------------------------------------------------------
	# Single Componenet check ##
	#----------------------------------------------------------------------------
	proc single_comp {} {

		variable fvalue 0.0;
		variable uvalue;	

		Clear_All_Marks
		set elist [list]

		if {$uvalue == ""} {
		tk_messageBox -message "Please enter Thickness." -title "Hypermesh" \
		    -type ok -icon info;
		return;
	    }

		set Fne "$::Skoda_Minium_Check::uvalue"
		set N [expr $Fne + 0.000]
		
	
		set fvalue [format %6.2f [expr {$N*1.1}]]
		*createmark comps 1 "displayed"
		set compA [hm_getmark comps 1]
		foreach compB $compA {
		set thickn [hm_getthickness comps $compB]
			if {$thickn == $N } {
				set n [expr {$N*1.101}]
				eval *createmark elems 1 "by comps" $compB
				*elementtestlength elements 1 $n 2 1 2 0 "  2D Length <  "
				set nelems [hm_getmark elems 2]
				lappend elist $nelems }
		}

		set finalel [join $elist]	
		eval *createmark elems 2 $finalel
		set femls [hm_getmark elems 2]
		if {[llength $femls ] > 0 } {
			*displaycollectorwithfilter components "none" "" 1 0
			*findmark elements 2 0 1 elements 0 1 
			} else {tk_messageBox -message "No Elements are fails"}

		}


#----------------------------------------------------------------------------
	# Triapernode ##
	#----------------------------------------------------------------------------



proc tr {} {

	variable trivalue;

	if {$trivalue == ""} {
		tk_messageBox -message "Please enter the Tria Per Node value." -title "Hypermesh" \
		    -type ok -icon info;
		return;
	    }

	set nut "$::Skoda_Minium_Check::trivalue"

	set Nu [ expr $nut + 0 ]
	*createmark comps 1 "all"
	eval *createmark elements 1 {"by comps"} [hm_getmark comps 1]
	*createmark elements 2 "by config" 103 106
	*markintersection elements 1 elements 2
	array unset triArr
	set hitList {}
	set hitelem {}
	foreach e [hm_getmark elements 1] {
	  foreach n [hm_nodelist $e] {
	    if {[info exists triArr($n)]} {
		    incr triArr($n)
		    	if {$triArr($n) >= $Nu} {
	      			lappend hitList $n
				lappend hitelems $e
	    			}
	   } else {
	      set triArr($n) 1
	    }
	  }
	}
	if {[llength $hitList]==0} {
	  tk_messageBox -message "No trias attached to trias"
	} else {
	  *displaycollectorwithfilter components "none" "" 1 0
	 eval *createmark nodes 1 $hitList
	 *nodemarkaddtempmark 1
	 eval *createmark nodes 1 $hitList
	 *findmark nodes 1 257 1 elements 0 2
	 hm_createmark elems 2 "advanced" "displayed" 
	 *createmark elements 1 "by config" quad4
	 *maskentitymark elements 1 0
	 *createmark elems 1 "by config type" 1 tria3
	 *displaycollectorwithfilter components "none" "" 1 0
	 *findmark elements 1 0 1 elements 0 2
	 hm_saveusermark elems 1
	}
	Clear_All_Marks

}




################################################################
	## Destroy Main window and tab
	##
	proc DestroyPanel {} {
		variable tabname
		variable main

		hm_framework removetab $tabname
		destroy $main
	}


################################################################
	## Get the Script folder
	##
	proc getScriptDirectory {} {
		set dispScriptFile [file normalize [info script]]
		set scriptFolder [file dirname $dispScriptFile]
		return $scriptFolder
	}

################################################################
	## Main window and program start
	##

proc CreatePanel { } {
		variable tabname
		variable main

		variable value_distanceX
		variable value_distanceY
		variable value_distanceZ

		set iconDir [getScriptDirectory]
		append iconDir "/Icons/"
		
		set pady 3
		set ns "[namespace current]::"
		set tablist [ hm_framework getalltabs ]
		if { [ lsearch $tablist $tabname ] > -1 } {
			DestroyPanel
		}

		if {[winfo exist .frameSkodaMiniumCheck]} {
			destroy .frameSkodaMiniumCheck
		}
		
		set main [ frame .frameSkodaMiniumCheck ]
		hm_framework addtab $tabname $main

		label $main.spaceHead
		pack $main.spaceHead

		set frameMeasure [hwt::LabeledFrame $main.frameMeasure   " Over All Check " topPad 2\
									-side    top \
									-anchor  nw \
									-padx    1 \
									-pady    $pady \
									-justify left \
									-expand  0]

		set frameMeasure2 [hwt::LabeledFrame $main.frameMeasure2   " Individual " topPad 2\
									-side    top \
									-anchor  nw \
									-padx    1 \
									-pady    $pady \
									-justify left \
									-expand  0]

		set frameMeasure3 [hwt::LabeledFrame $main.frameMeasure3   " Tria Per Node " topPad 2\
									-side    top \
									-anchor  nw \
									-padx    1 \
									-pady    $pady \
									-justify left \
									-expand  0]


		set frameClose [hwt::LabeledFrame $main.frameClose   " Close " topPad 2\
									-side    top \
									-anchor  nw \
									-padx    1 \
									-pady    $pady \
									-justify left \
									-expand  0]

		set iconDirName $iconDir
		append iconDirName "search.png"
		set all_check [hwt::CanvasButton $frameMeasure.all_check [::hwt::DluWidth 144] [::hwt::DluHeight 24]\
			-icon	[file join "$iconDirName"] \
            -iconH   4 \
            -iconV   6 \
            -relief	raised \
			-justify center \
			-text	" Check All Elements " \
            -help	" Check All Elements " \
            -takefocus 1 \
            -command "${ns}all_elems"]

pack $all_check			-expand 1 -fill x -side top -padx 2 -pady 2

		set iconDirName $iconDir
		append iconDirName "filter.png"
		set single_check [hwt::CanvasButton $frameMeasure2.single_check [::hwt::DluWidth 144] [::hwt::DluHeight 24]\
			-icon	[file join "$iconDirName"] \
            -iconH   4 \
            -iconV   6 \
            -relief	raised \
			-justify center \
			-text	" Check Individual " \
            -help	" Check Individual Elements by thickness " \
            -takefocus 1 \
            -command "${ns}single_comp"]

pack $single_check			-expand 1 -fill x -side top -padx 2 -pady 2


	set usermin [ hwt::AddEntry $frameMeasure2.usermin \
				label "thickness =" \
				labelwidth 10 \
				entrywidth 20 \
				withoutPacking \
				-justify right \
				-textvariable "::Skoda_Minium_Check::uvalue" \
				State       "normal"
		]
	pack $usermin		-side top -anchor nw -padx 4 -pady 4

	set finalmin [ hwt::AddEntry $frameMeasure2.finalmin \
			label "thickx1.1 =" \
			labelwidth 10 \
			entrywidth 20 \
			withoutPacking \
			-justify right \
			-textvariable "${ns}fvalue" \
			State       "disabled"
		]
	pack $finalmin		-side top -anchor nw -padx 4 -pady 4

	set iconDirName $iconDir
		append iconDirName "tria.png"
	set tpernode [hwt::CanvasButton $frameMeasure3.tpernode [::hwt::DluWidth 144] [::hwt::DluHeight 24]\
			-icon	[file join "$iconDirName"] \
            -iconH   4 \
            -iconV   6 \
            -relief	raised \
			-justify center \
			-text	" Trias Per Node " \
            -help	" Trias Per Node " \
            -takefocus 1 \
            -command "${ns}tr"]

pack $tpernode			-expand 1 -fill x -side top -padx 2 -pady 2

	set trval [ hwt::AddEntry $frameMeasure3.trval \
			label "No.Of Tria =" \
			labelwidth 10 \
			entrywidth 20 \
			withoutPacking \
			-justify right \
			-textvariable "::Skoda_Minium_Check::trivalue" \
			State       "normal"
		]
	pack $trval		-side top -anchor nw -padx 4 -pady 4



	set closeButton  [button $frameClose.closeButton \
									-command "${ns}DestroyPanel" \
									-text " Close " \
									-font [hwt::AppFont]]
		
		grid columnconfigure $frameClose 0 -weight 1 -uniform A
		grid columnconfigure $frameClose 1 -weight 1 -uniform A
		grid $closeButton			-row 0 -column 1 -padx 4 -pady 5 -sticky e -columnspan 2

	}

}

::Skoda_Minium_Check::CreatePanel
