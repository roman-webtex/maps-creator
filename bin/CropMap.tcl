encoding system utf-8

namespace eval ::maps {

    proc cropAction {} {
	set ::topCoord {}
	set ::rightCoord {}
	set ::bottomCoord {}
	set ::leftCoord {}
	set ::delta 0

	set ::cropDone 0

	set imgForm .imageForm
	toplevel $imgForm
	wm title $imgForm "Обрізати"
	::winUtils::centerWindow $imgForm
	focus $imgForm
	grab $imgForm

	ttk::frame $imgForm.innerFrame
	pack $imgForm.innerFrame -fill both -expand true
	pack [ttk::button $imgForm.btnOk -text "Готово" -command {set ::cropDone 1}] -side bottom -fill x -padx 5 -pady 5

	set small [image create photo smallImg]

	$small copy $::mainImage -shrink -subsample 1

	set canv [canvas $imgForm.innerFrame.canvas -width 600 -height 600 \
		-scrollregion [list 0 0 [expr [image width $small] + 20] [expr [image height $small] + 20]] \
		-xscrollcommand [list $imgForm.innerFrame.xscroll set ] \
		-yscrollcommand [list $imgForm.innerFrame.yscroll set]] 
	scrollbar $imgForm.innerFrame.xscroll -orient horizontal -command [list $canv xview]
	scrollbar $imgForm.innerFrame.yscroll -orient vertical -command [list $canv yview]
	grid $canv $imgForm.innerFrame.yscroll -sticky news
	grid $imgForm.innerFrame.xscroll -sticky ew
	grid rowconfigure $imgForm.innerFrame 0 -weight 1
	grid columnconfigure $imgForm.innerFrame 0 -weight 1

	$canv create image 10 10 -anchor nw -image smallImg
		
	set ::topCoord [list 0 7 [expr [image width $small] + 20] 7]
	set ::rightCoord [list [expr [image width $small] + 7] 0 [expr [image width $small] + 7] [expr [image height $small] + 20]]
	set ::bottomCoord [list 0 [expr [image height $small] + 7] [expr [image width $small] + 20] [expr [image height $small] + 7]]
	set ::leftCoord [list 7 0 7 [expr [image height $small] + 20]]

	$canv create line $::topCoord -width 2 -fill yellow -activefill red -tags top -arrow both
	$canv create line $::rightCoord -width 2 -fill yellow -activefill red -tags right -arrow both
	$canv create line $::bottomCoord -width 2 -fill yellow -activefill red -tags bottom -arrow both
	$canv create line $::leftCoord -width 2 -fill yellow -activefill red -tags left -arrow both

	$canv bind top <B1-Motion> {::winUtils::moveLine top %W %x %y}
	$canv bind bottom <B1-Motion> {::winUtils::moveLine bottom %W %x %y}
	$canv bind left <B1-Motion> {::winUtils::moveLine left %W %x %y}
	$canv bind right <B1-Motion> {::winUtils::moveLine right %W %x %y}

	$canv bind top <Button-1> {::winUtils::clickLine %x %y}
	$canv bind bottom <Button-1> {::winUtils::clickLine %x %y}
	$canv bind left <Button-1> {::winUtils::clickLine %x %y}
	$canv bind right <Button-1> {::winUtils::clickLine %x %y}

	vwait ::cropDone
	if {$::cropDone == 1} {
	    $::mainImage blank
	    $::mainImage configure -width [expr {[lindex $::rightCoord 0] - [lindex $::leftCoord 0] - 14}]  -height [expr {[lindex $::bottomCoord 1] - [lindex $::topCoord 1] - 14}]
	    $::mainImage copy $small -from [expr {[lindex $::leftCoord 0] - 7}] [expr {[lindex $::topCoord 1] - 7}] [expr {[lindex $::rightCoord 0] - 7}] [expr {[lindex $::bottomCoord 1] -7}]
	    $::mainImage write [file join $::workingDir out result.jpg]
	}

	destroy $imgForm
	maps::sysutils::showInfo

        .mainWindow.fraMain.canMain delete [.mainWindow.fraMain.canMain find all]

	set scrollregion [list 0 0 [image width $::mainImage] [image height $::mainImage]]

	.mainWindow.fraMain.canMain configure -scrollregion  $scrollregion \
	    -xscrollcommand [list .mainWindow.fraMain.sbh set ] \
	    -yscrollcommand [list .mainWindow.fraMain.sbv set ] 

	.mainWindow.fraMain.canMain create image 0 0 -image $::mainImage -anchor nw -tags mainMap

	set ::cZoom 100%
	set ::nZoom 100

	return
    }
}