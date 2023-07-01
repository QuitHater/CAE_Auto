*clearmark comps 1
*createmark comps 1 "displayed"
set dirnme [tk_chooseDirectory]

set all_cmps [hm_getmark comps 1]
foreach cur_cmps $all_cmps {
	set fileloc [list]
	*clearmark comps 1
	*createmark comps 1 "$cur_cmps"
	set prtnme [hm_getvalue comps id=$cur_cmps dataname=name]
	append fileloc $dirnme "/" $prtnme ".step"
	*createstringarray 2 "elements_on" "geometry_on"
	*isolateentitybymark 1 1 2
	*window 0 0 0 0
	*geomexport "step_ct" "$fileloc" "AssemblyMode=Parts" "Export=Displayed" "GeometryMode=Standard" "LayerMode=None" "NameFromRepresentation=off" "OptimizeForCAD=on" "SourceUnits=MMKS (mm kg N s)" "TargetUnits=Millimeters" "TopologyMode=Solid/Shell" "Version=AP214" "WriteMetaDataAsName=TAG" "WriteNameFrom=Metadata"
	*clearmark comps 1
}
