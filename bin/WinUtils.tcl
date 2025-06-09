encoding system utf-8

namespace eval ::winUtils {

    proc centerWindow {w {width 400} {height 250} } {
        after idle "
                update idletasks

                if {[winfo exists $w] == 1} {
                    # centre
                    set xmax \[winfo screenwidth $w\]
                    set ymax \[winfo screenheight $w\]
                    set x \[expr \{(\$xmax - \[winfo reqwidth $w\]) / 2\}\]
                    set y \[expr \{(\$ymax - \[winfo reqheight $w\]) / 2\}\]

                    wm geometry $w \"+\$x+\$y\"
                }
                "
    }

    proc close {wmName} \
    {
        global mainTitle
        destroy $wmName
        wm title . $mainTitle
    }

    proc mapMarkMove {x y can} \
    {
        if {$::mapMode != "move"} { 
            return
        }
        set ::startX [$can canvasx $x]
        set ::startY [$can canvasy $y]
        set ::selection [$can find overlapping [$can canvasx $x] [$can canvasy $y] [$can canvasx $x] [$can canvasy $y]]
    }

    proc mapUnmarkMove {x y can} \
    {
        if {$::mapMode != "move"} {
            return
        }
        catch {unset ::selection}
    }
    
    proc mapMove {x y can} {
        if {$::mapMode != "move"} {
            return
        }
        set currentX [$can canvasx $x]
        set currentY [$can canvasy $y]
        $can move $::selection  [expr {$currentX - $::startX}] [expr {$currentY - $::startY}]
        set ::startX $currentX
        set ::startY $currentY
    }

    proc mapScroll {x y can} {
        if {$::mapMode != "move"} {
            return
        }
        set currentX [$can canvasx $x]
        set currentY [$can canvasy $y]
        $can xview moveto [expr {($currentX - $::startX) / [$can cget -width]}]
        $can yview moveto [expr {($currentY - $::startY) / [$can cget -height]}]
        set ::startX $currentX
        set ::startY $currentY
    }


    proc mapMark {x y can} \
    {
        if {$::mapMode != "draw"} { 
            return
        }
        catch {unset ::lineArray}
        set ::posX [$can canvasx $x]
        set ::posY [$can canvasy $y]
        set ::lineArray(N) 0
        set ::lineArray(0) [list $::posX $::posY]
    }

    proc mapUnmark {x y can} \
    {
        if {$::mapMode != "draw"} {
            return
        }
        set coords {}
        for {set i 0} {$i < $::lineArray(N)} {incr i} {
            append coords $::lineArray($i) " "
        }

        $can delete segments
        $can create line $coords -tag line -joinstyle round -smooth true -arrow none -fill $::lineColor -width 3
    }

    proc drawLine {x y can} \
    {
        if {$::mapMode != "draw"} {
            return
        }
        set ::posX [$can canvasx $x]
        set ::posY [$can canvasy $y]
        set coords $::lineArray($::lineArray(N))
        lappend coords $::posX $::posY
        incr ::lineArray(N)
        set ::lineArray($::lineArray(N)) [list $::posX $::posY]

        $can create line $coords -tag segment -fill $::lineColor -width 3
    }
    
    proc changeZoom {{direction ""} {canv ""}} {
        if {$direction == "" || $::mainImage == ""} {
            set ::nZoom 100
            set ::cZoom " 100% "
            return
        }
        
        set direction [string map {in + out -} $direction]
        set ::nZoom [expr $::nZoom $direction 10]
        if {$::nZoom > 100} {
            set ::nZoom 100
        }
        if {$::nZoom < 10} {
            set ::nZoom 10
        }
        set ::cZoom $::nZoom%
        ::winUtils::comboZoom $canv
    }


    proc comboZoom {canv} {
        if {$::mainImage == ""} {
            set ::nZoom 100
            set ::cZoom " 100% "
            return
        }
        $canv configure -cursor watch
        update

        $canv delete mainMap
        $canv delete mainOverlay
        set width [image width $::mainImage]
        set height [image height $::mainImage]
        set ::workingImage [image create photo wImage]
        set ::nZoom [string trim $::cZoom %]
        resizephoto $::mainImage $::workingImage [expr $width*$::nZoom/100] [expr $height*$::nZoom/100]
        set width [image width $::workingImage]
        set height [image height $::workingImage]
        set scrollregion [list 0 0 $width $height]
        $canv configure -scrollregion $scrollregion
        $canv create image 0 0 -image wImage -anchor nw -tags mainMap

        $canv configure -cursor arrow
        update

        return
    }

    proc initWM {args} {

        # Initializes Tcl/Tk session. Used to be called at the beginning of it.
        #   args - options ("name value" pairs)

        if {!$::apave::_CS_(initWM)} return
        
        lassign [apave::parseOptions $args -cursorwidth $::apave::cursorwidth -theme {clam} \
            -buttonwidth -8 -buttonborder 1 -labelborder 0 -padding 1] \
            cursorwidth theme buttonwidth buttonborder labelborder padding
        set ::apave::_CS_(initWM) 0
        set ::apave::_CS_(CURSORWIDTH) $cursorwidth
        set ::apave::_CS_(LABELBORDER) $labelborder
        #wm withdraw .
        if {$::tcl_platform(platform) eq {windows}} {
            #wm attributes . -alpha 0.0
        }
        # for default theme: only most common settings
        set tfg1 $::apave::_CS_(!FG)
        set tbg1 $::apave::_CS_(!BG)
        if {$theme ne {}} {catch {ttk::style theme use $theme}}
        
        ttk::style map . \
            -selectforeground [list !focus $tfg1 {focus active} $tfg1] \
            -selectbackground [list !focus $tbg1 {focus active} $tbg1]
        ttk::style configure . -selectforeground  $tfg1 -selectbackground $tbg1

        # configure separate widget types
        ttk::style configure TButton -anchor center -width $buttonwidth \
            -relief raised -borderwidth $buttonborder -padding $padding
        ttk::style configure TMenubutton -width 0 -padding 0
        # TLabel's standard style saved for occasional uses
        ttk::style configure TLabelSTD {*}[ttk::style configure TLabel]
        ttk::style configure TLabelSTD -anchor w
        ttk::style map       TLabelSTD {*}[ttk::style map TLabel]
        ttk::style layout    TLabelSTD [ttk::style layout TLabel]
        # ... TLabel new style
        ttk::style configure TLabel -borderwidth $labelborder -padding $padding
        # ... Treeview colors
        set twfg [ttk::style map Treeview -foreground]
        set twfg [apave::putOption selected $tfg1 {*}$twfg]
        set twbg [ttk::style map Treeview -background]
        set twbg [apave::putOption selected $tbg1 {*}$twbg]
        ttk::style map Treeview -foreground $twfg
        ttk::style map Treeview -background $twbg
        # ... TCombobox colors
        ttk::style map TCombobox -fieldforeground [list {active focus} $tfg1 readonly $tfg1 disabled grey]
        ttk::style map TCombobox -fieldbackground [list {active focus} $tbg1 {readonly focus} $tbg1 {readonly !focus} white]

        apave::initPOP .
        apave::initStyles
        apave::initStylesFS name Tahoma size 6
    }

    proc clickLine {x y} {
	set ::delta [list $x $y]
	return
    }

    proc moveLine {tag w x y} {
	if {$::delta == 0} {
            set ::delta [list $x $y]
	    return
	} else {
	    set deltaX [expr {$x - [lindex $::delta 0]}]
	    set deltaY [expr {$y - [lindex $::delta 1]}]
	    set ::delta [list $x $y]
	}

	if {$tag eq "top"} {
	    set dy [expr {[lindex $::topCoord 1] + $deltaY}]
	    set ::topCoord [list [lindex $::topCoord 0] $dy [lindex $::topCoord 2] $dy]
	    $w coord $tag $::topCoord
	} elseif {$tag eq "right"} {
	    set dx [expr {[lindex $::rightCoord 0] + $deltaX}]
	    set ::rightCoord [list $dx [lindex $::rightCoord 1] $dx [lindex $::rightCoord 3]]
	    $w coord $tag $::rightCoord
	} elseif {$tag eq "bottom"} {
	    set dy [expr {[lindex $::bottomCoord 1] + $deltaY}]
	    set ::bottomCoord [list [lindex $::bottomCoord 0] $dy [lindex $::bottomCoord 2] $dy]
	    $w coord $tag $::bottomCoord
	} elseif {$tag eq "left"} {
	    set dx [expr {[lindex $::leftCoord 0] + $deltaX}]
	    set ::leftCoord [list $dx [lindex $::leftCoord 1] $dx [lindex $::leftCoord 3]]
	    $w coord $tag $::leftCoord
	}
	update
	return
    }

}