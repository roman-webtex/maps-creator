encoding system utf-8

namespace eval ::maps {
    
    proc arrangeParts {} {

        apave::APave create ::arrangePave

        ::arrangePave makeWindow .arrangeWindow "Вирівнювання мап"

        set content {
            {fraMain - - - - {pack -side top -fill both -expand 1 -padx 5 -pady 3}}
            {fraMain.canArrange - - - - {pack -side left -fill both -expand 1}}
            {fraMain.sbv fraMain.canArrange L - - {pack -side left -after %w}}
            {fraMain.sbh fraMain.canArrange T - - {pack -side left -before %w}}
            {fraButton - - - - {pack -side bottom -fill x -expand 1 -padx 5 -pady 3}}
            {fraButton.butOk - - - - {pack -side left -padx 3 -pady 5} {-t "Готово" -com "::arrangePave res .arrangeWindow 1"}}
        }
        ::arrangePave paveWindow .arrangeWindow $content 

        focus .arrangeWindow
        grab .arrangeWindow

        set width 0
	set height 0
	set mCanv .arrangeWindow.fraMain.canArrange
	
	for {set i 0} {$i < $::rows} {incr i} {
	    set width 0
	    for {set j 0} {$j < $::cols} {incr j} {
	        image create photo tImg$i$j -file [file join $::imageDir .. tmp t$i$j.jpg]
	        $mCanv create image $width $height -image tImg$i$j -anchor nw -tags t$i$j
	        incr width [image width tImg$i$j]
	        set hh [image height tImg$i$j]
	    }
	    incr height $hh
	}

        set scrollregion [list 0 0 $width $height]
        $mCanv configure -scrollregion  $scrollregion \
	    -xscrollcommand [list .arrangeWindow.fraMain.sbh set ] \
	    -yscrollcommand [list .arrangeWindow.fraMain.sbv set ] 


        bind $mCanv <Button-1> { ::winUtils::mapMarkMove %x %y %W}
        bind $mCanv <ButtonRelease-1> { ::winUtils::mapUnmarkMove %x %y %W}
   	bind $mCanv <B1-Motion> { ::winUtils::mapMove %x %y %W}

        set ::done [::arrangePave showModal .arrangeWindow -focus .arrangeWindow.fraMain.canArrange]
        
        foreach item [$mCanv find all] {
            if {[lindex [split [$mCanv coords $item]] 0] > 0 || [lindex [split [$mCanv coords $item]] 1] < 0} {
                set X [lindex [split [$mCanv coords $item]] 0]
                set Y [lindex [split [$mCanv coords $item]] 1]
                set ti [image create photo i$item -file [file join $::imageDir .. tmp [$mCanv gettags $item].jpg]]
                set w [image width $ti]
                set h [image height $ti]
                if {$X < 0} {
                    set w [expr int($w + $X)]
                    set X [expr int(abs($X))]
                } else {
                    set X 0
                }
                if {$Y < 0} {
                    set h [expr int($h + $Y)]
                    set Y [expr int(abs($Y))]
                } else {
                    set Y 0
                }
                set tmpPart [image create photo]
	        $tmpPart copy $ti -from $X $Y $w $h
	        $tmpPart write [file join $::imageDir .. tmp [$mCanv gettags $item].jpg]
            }
            lappend ::canvItems [$mCanv gettags $item] [$mCanv coords $item]
        }
        
        destroy .arrangeWindow
        destroy ::arrangePave
    }
}
