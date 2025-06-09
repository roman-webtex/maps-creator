encoding system utf-8

namespace eval ::maps {
    
    proc buildMainWindow {} {
        set ::mainTitle "Менеджер мап"

        foreach {i icon} {0 add 1 change 2 warn 3 OpenFile 4 folder} {
            image create photo Img$i -data [apave::iconData $icon]
        }

        image create photo ImgZoomIn  -file [file join $::imageDir .. pict zoom-in-thin.png]
        image create photo ImgZoomOut -file [file join $::imageDir .. pict zoom-out-thin.png]
        image create photo ImgMove    -file [file join $::imageDir .. pict cursor-24.png]
        image create photo ImgDraw    -file [file join $::imageDir .. pict paintbrush-9.png]
    
        apave::APave create ::pave
        toplevel .mainWindow
        wm title .mainWindow $::mainTitle

        wm geometry .mainWindow "$::window_size"

        set content {
            {Menu - - - - - {-array {File "&Файл" Edit "&Редагування" Project "&Проект"}} ::maps::fillMenuAction}
            {toolMenu - - - - {pack -side top} {-array { 
                Img0 {{::maps::file::createAction} -tooltip "Створити мапу \nCtrl+N"} 
                Img3 {{::maps::file::openAction} -tooltip "Відкрити мапу \nCtrl+N"} sev 5 
                ImgZoomOut {{::winUtils::changeZoom out .mainWindow.fraMain.canMain} } h_ 1
                opcZoom {::cZoom ::zoomList {-width 5} {} -command {::winUtils::comboZoom .mainWindow.fraMain.canMain} -tooltip "Масштаб мапи" } h_ 1
                ImgZoomIn {{::winUtils::changeZoom in .mainWindow.fraMain.canMain}} sev 5 h_ 1
            }}}
            {fraMain - - - - {pack -side top -fill both -expand 1 -padx 5 -pady 3}}
            {fraMain.canMain - - - - {pack -side left -fill both -expand 1}}
            {fraMain.sbv fraMain.canMain L - - {pack -side left -after %w}}
            {fraMain.sbh fraMain.canMain T - - {pack -side left -before %w}}
            {staMainInfo - - - - {pack -side bottom -padx 5 } { -array { 
                {"" -font {-slant italic -size 8} -anchor w} 120 }}}
        }

        ::pave paveWindow .mainWindow $content
        
        pack [Button .mainWindow.toolMenu.btnMove -image ImgMove -command {::maps::sysutils::changeMode move} -relief solid] -side left
        pack [Button .mainWindow.toolMenu.btnDraw -image ImgDraw -command  {::maps::sysutils::changeMode draw} -relief flat] -side left
        pack [ttk::frame .mainWindow.toolMenu.fr0001 ] -side left -padx 3
        pack [ttk::separator .mainWindow.toolMenu.separ -orient vertical] -side left -fill both
        pack [ttk::frame .mainWindow.toolMenu.fr0002 ] -side left -padx 3

        foreach filename [glob -nocomplain [file join $::workingDir system pict colors *.jpg]] {
            set color [lindex [split [lindex [split $filename /] end] .] 0]
            pack [Button .mainWindow.toolMenu.btn$color -relief flat -image [image create photo $color -width 16 -height 16 -file $filename]] -side left
            bind .mainWindow.toolMenu.btn$color <Button-1> {::maps::sysutils::changeColor %W}
            if {$::lineColor == ""} {
                set ::lineColor $color
                .mainWindow.toolMenu.btn$color configure -relief solid
            }
        }

        wm protocol .mainWindow WM_DELETE_WINDOW {::maps::prog_exit}
        
        bind .mainWindow <Control-q> {::maps::prog_exit}
        bind .mainWindow <Control-w> {::maps::closeAll}

    }

    proc fillMenuAction {} {
        set m .mainWindow.menu.file
        $m add command -label "Створити мапу" -command { ::maps::file::createAction }
        $m add command -label "Відкрити мапу" -command { ::maps::file::openAction }
        $m add command -label "Зберігти мапу" -command { ::maps::file::saveAction }
        $m add separator
        $m add command -label "Вихід" -command {::maps::prog_exit}

        set m .mainWindow.menu.edit
        $m add command -label "Обрізати мапу" -command { ::maps::cropAction }
        
        set m .mainWindow.menu.project
        $m add command -label "Створити проект" -command { ::maps::project::newProj }
        $m add command -label "Відкрити проект" -command { ::maps::project::openProj }
        $m add command -label "Зберігти проект" -command { ::maps::project::saveProj }
        $m add command -label "Зберігти проект як..." -command { ::maps::project::saveProjas }
        $m add separator
        $m add command -label "Додати оверлей" -command { ::maps::project::addOverlay } -state disabled
    }

    proc prog_exit {} {
        foreach filename [glob -nocomplain [file join $::imageDir .. tmp *.jpg]] {
            file delete $filename
        }
        exit
    }
    
    proc closeAll {} {
        
    }

}
