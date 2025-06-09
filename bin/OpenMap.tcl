encoding system utf-8

namespace eval ::maps::file {
    proc openAction {} {
	set filename [tk_getOpenFile -filetypes {{{JPG Maps} {.jp*g}}} -initialdir [file join $::workingDir out ] -title "Відкрити згенеровану мапу"]
	if {$filename eq ""} {
		return
	}

	::maps::sysutils::showProgress 1 1 3 "Відкриття мапи..."

	if {[winfo exist .mainWindow.fraMain.canMain]} {
	    .mainWindow.fraMain.canMain delete [.mainWindow.fraMain.canMain find all]
	}

	set ::mainImage [image create photo -file $filename]

	set width [image width $::mainImage]
	set height [image height $::mainImage]
		
	set scrollregion [list 0 0 $width $height]

	set mainCanvas [canvas .mainWindow.fraMain.canMain \
	    -scrollregion  $scrollregion \
	    -xscrollcommand [list .mainWindow.fraMain.sbh set ] \
	    -yscrollcommand [list .mainWindow.fraMain.sbv set]] 

	::maps::sysutils::showProgress 1 2 3 "Відкриття мапи..."

	$mainCanvas create image 0 0 -image $::mainImage -anchor nw -tags mainMap

#	set ::overlay [image create photo overlay -height $height -width $width -format PNG ]
#	$::overlay blank
#	$mainCanvas create image 0 0 -image overlay -anchor nw -tags mainOverlay

	::maps::sysutils::showProgress 1 3 3 "Відкриття мапи..."

        pack $mainCanvas -side left -expand 1 -fill both

	set ::cZoom 100%
	set ::nZoom 100
        
#        bind .mainWindow.fraMain.canMain <Button-1> { ::winUtils::mapMarkMove %x %y %W}
#        bind .mainWindow.fraMain.canMain <ButtonRelease-1> { ::winUtils::mapUnmarkMove %x %y %W}
#   	bind .mainWindow.fraMain.canMain <B1-Motion> { ::winUtils::mapScroll %x %y %W}

        bind $mainCanvas <Button-1> { ::winUtils::mapMark %x %y %W}
        bind $mainCanvas <ButtonRelease-1> { ::winUtils::mapUnmark %x %y %W}
   	bind $mainCanvas <B1-Motion> { ::winUtils::drawLine %x %y %W}
    	bind .mainWindow <Escape> {$mainCanvas delete line}

	::maps::sysutils::showProgress
    }
}