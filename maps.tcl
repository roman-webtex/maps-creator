encoding system utf-8

package require Tk
package require tablelist
package require BWidget
package require apave
package require tdom
package require uuid
package require Tktable
package require img::jpeg
package require photoresize

namespace import msgcat::mc

set ::workingDir [file dirname [file normalize [info script]]]
set ::imageDir [file join $::workingDir system maps]

foreach filename [glob -nocomplain [file join $::workingDir bin *.tcl]] {
    source $filename
}

foreach filename [glob -nocomplain [file join $::imageDir .. tmp *.jpg]] {
    file delete $filename
}

switch $::tcl_platform(platform) {     
    windows {         
        set ::explorer explorer
        set ::window_size "[winfo screenwidth .]x[expr {[winfo screenheight .] - 100}]+0+0"
    } 
    unix {         
        set ::explorer xdg-open
        set ::window_size "[winfo screenwidth .]x[winfo screenheight .]+0+0"
    } 
}

namespace eval ::maps {
}

foreach font_name [font names] {
    font configure $font_name -size $::fSize
}
    
proc ::main {} {
    apave::initWM
    ::maps::login
    ::maps::buildMainWindow
}

::main

