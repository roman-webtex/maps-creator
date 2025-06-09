encoding system utf-8

namespace eval ::maps::file {

    proc createAction {} {
    	set ::cols 1
    	set ::rows 1
    	set ::done 0

    	tablelist::addBWidgetEntry
    	tablelist::addBWidgetComboBox

    	if {[winfo exist .addForm]} {
	    destroy .addForm
	}

	maps::sysutils::showInfo " 1/3: Введіть розмірність карти"

    	apave::APave create ::editPave
        ::editPave csSet -2 .

	set editForm .addForm
        set content {
            {fra  - - - - {-st news -padx 5 -pady 5}}
            {fra.entRow - - 1 1 {-st wes} {-tvar ::rows}}
            {fra.lab1 fra.entRow L 1 1 {-st es}  {-t "ряд."}}
            {fra.entCol fra.lab1 L 1 1 {-st wes} {-tvar ::cols}}
            {fra.lab2 fra.entCol L 1 1 {-st es}  {-t "кол."}}
            {fra.seh1 fra.entRow T 1 4 }
            {fra.butOk fra.seh1 T 1 2 {-st ws} {-t "Розпочати" -com "::editPave res $editForm 1"}}
            {fra.butCancel fra.butOk L 1 2 {-st es} {-t "Закрити" -com "::editPave res $editForm 0"}}
        }
        ::editPave makeWindow $editForm "Введіть розмірність карти (ряд Х кол)..."
        ::editPave paveWindow $editForm $content

        focus $editForm
        grab $editForm

        set ::done [::editPave showModal $editForm -focus .addForm.fra.entRow]

        destroy $editForm

	if {$::done != 1} {
	    maps::sysutils::showInfo
            destroy ::editPave
	    return
	}

	set ::done 0

	maps::sysutils::showInfo " 2/3: Додайте мапи"

        set width [expr {$::cols * 100 + $::cols * 4}]
        set height [expr {$::rows * 100 + $::rows * 4}]

	set editForm .addForm
        ::editPave makeWindow $editForm "Додайте мапи..."

        set content {
            {fra  - - - - {-st news -padx 5 -pady 5}}
            {fra.canCreaCanvas - - 1 4 {-st news -padx 5 -pady 5} { -width $width -height $height }}
            {fra.seh1 fra.canCreaCanvas T 1 4 }
            {fra.butChange fra.seh1 T 1 2 {-st ws  -pady 5} {-t "Вирівняти" -com "::maps::arrangeParts"}}
            {fra.butOk fra.butChange L 1 2 {-st es -pady 5} {-t "Готово" -com "::editPave res $editForm 1"}}
        }
        ::editPave paveWindow $editForm $content
        
        set canv $editForm.fra.canCreaCanvas

	image create photo dummyImg -width 100 -height 100 -file [file join $::imageDir .. pict folder_100_100.jpg]
	for {set i 0} {$i < $::rows} {incr i} {
	    for {set j 0} {$j < $::cols} {incr j} {
		$canv create image [expr $j * 100 + 4] [expr $i * 100 + 4] -image dummyImg -anchor nw -tags t$i$j
		$canv bind t$i$j <Button-1> [list ::maps::file::addImage %W %x %y t$i$j]
	    }
	}

        focus $editForm
        grab $editForm
	bind $editForm <Escape> {set done 0}

        set ::done [::editPave showModal $editForm -focus .addForm.fra.entRow]

        destroy $editForm

	if {$::done == 1} {
	    ::maps::sysutils::showInfo " 3/3: Створення загальної мапи"
	    
	    if {$::rows == 1 && $::cols == 1} {
    	        set img [image create photo tImg -file [file join $::imageDir .. tmp t11.jpg]]
	        set ::mainImage [image create photo mImage -width [image width $img] -height [image height $img]]
	        $::mainImage copy $img -to 0 0 
	    } else {
	        ::maps::sysutils::showProgress 1 0 3 "Підрахунок розмірів..."

		set width [set height [set h 0]]
		
		for {set i 0} {$i < $::rows} {incr i} {
		    set width 0
		    for {set j 0} {$j < $::cols} {incr j} {
			set img [image create photo tImg -file [file join $::imageDir .. tmp t$i$j.jpg]]
			incr width [image width $img]
			set h [expr max([image height $img], $h)]
		    }
		    incr height $h
		}
	        ::maps::sysutils::showProgress 1 1 3 "Створення мапи..."
	        set ::mainImage [image create photo mImage -width $width -height $height]
		
                foreach {item coord} $::canvItems { 
        	    set img [image create photo t$item -file [file join $::imageDir .. tmp $item.jpg]]
        	    $::mainImage copy $img -to [expr max(int([lindex $coord 0]), 0)] [expr max(int([lindex $coord 1]), 0)]
        	    destroy t$item
        	}
	    }
            ::maps::sysutils::showProgress 1 2 3 "Збереження результату..."

	    if {[winfo exist .mainWindow.fraMain.canMain]} {
		destroy .mainWindow.fraMain.canMain
	    }
			
	    $::mainImage write [file join $::workingDir out result.jpg]
	    set scrollregion [list 0 0 $width $height]

	    set mainCanvas [canvas .mainWindow.fraMain.canMain \
		-scrollregion  $scrollregion \
		-xscrollcommand [list .mainWindow.fraMain.sbh set ] \
		-yscrollcommand [list .mainWindow.fraMain.sbv set ]] 

	    $mainCanvas create image 0 0 -image $::mainImage -anchor nw -tags mainMap

	    pack $mainCanvas -side left -expand 1 -fill both

	    set ::cZoom 100%
	    set ::nZoom [string trim $::cZoom %]

#            bind .mainWindow.fraMain.canMain <Button-1> { ::winUtils::mapMarkMove %x %y %W}
#            bind .mainWindow.fraMain.canMain <ButtonRelease-1> { ::winUtils::mapUnmarkMove %x %y %W}
#	    bind .mainWindow.fraMain.canMain <B1-Motion> { ::winUtils::mapMove %x %y %W}

	    bind $mainCanvas <Button-1> { ::winUtils::mapMark %x %y %W}
	    bind $mainCanvas <ButtonRelease-1> { ::winUtils::mapUnmark %x %y %W}
  	    bind $mainCanvas <B1-Motion> { ::winUtils::drawLine %x %y %W}
   	    bind $mainCanvas <Escape> {$mainCanvas delete line}

	    ::maps::sysutils::showProgress
	}

	destroy $editForm
	maps::sysutils::showInfo
	return
    }

    proc addImage {widget x y tag} {
	set ::topCoord {}
	set ::rightCoord {}
	set ::bottomCoord {}
	set ::leftCoord {}
	set ::delta 0

	set ::cropDone 0

	set filename [tk_getOpenFile -filetypes {{{JPG Maps} {.jp*g}}} -initialdir $::imageDir -title "Відкрити карту"]
	if {$filename eq ""} {
            return
	}

	set imgForm .imageForm
	toplevel $imgForm
	wm title $imgForm "Обрізати"
	::winUtils::centerWindow $imgForm
	focus $imgForm
	grab $imgForm

	ttk::frame $imgForm.innerFrame
	pack $imgForm.innerFrame -fill both -expand true
	pack [ttk::button $imgForm.btnOk -text "Готово" -command {set ::cropDone 1}] -side bottom -fill x -padx 5 -pady 5

	set tempImg [image create photo -file $filename]
	set small [image create photo smallImg]

	$small copy $tempImg -shrink -subsample 1

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
	    set tmpJpeg [image create photo]
	    $tmpJpeg copy $small -from [expr {[lindex $::leftCoord 0] - 7}] [expr {[lindex $::topCoord 1] - 7}] [expr {[lindex $::rightCoord 0] - 7}] [expr {[lindex $::bottomCoord 1] -7}]
	    $tmpJpeg write [file join $::imageDir .. tmp $tag.jpg]
	    set ratio [expr {round([image width $tmpJpeg] / 100)}]
	    set resImg [image create photo $tag] 
	    $resImg copy $tmpJpeg -shrink -subsample $ratio
	    $widget itemconfigure $tag -image $tag 
	}

	destroy $imgForm
	maps::sysutils::showInfo
	focus .addForm
	wm attributes .addForm -topmost yes
	wm attributes .addForm -topmost no

	return
    }
}