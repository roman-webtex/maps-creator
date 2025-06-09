set ::db_user ""
set ::db_password ""
set ::data 0
set ::mainTitle ""
set ::fSize 8
set ::inZoom 0
set ::lineColor ""
set ::nZoom 100
set ::mainImage ""
set ::mapMode move
set num 100
while {$num > 0} {
    lappend ::zoomList " $num% "
    incr num -10
}
