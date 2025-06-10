#!/bin/env tclsh

foreach i [list 65 66 67 68 69 70 71 72] {
 puts m-36-0$i.jpg
 exec wget -nv https://freemap.com.ua/wp-content/themes/foundation_xy/assets/images/maps/genshtab/m-36-0$i.jpg
}
