Description: fix Throughput Widget and plots feature.
Author: Jeffrey M. Ahrenholz <jeffrey.m.ahrenholz@boeing.com>
Origin: https://code.google.com/p/coreemu/source/diff?spec=svn569&old=536&r=569&format=unidiff&path=%2Ftrunk%2Fgui%2Fwidget.tcl
Last-Update: 2014-08-09
Index: core-network-4.7/gui/widget.tcl
===================================================================
--- core-network-4.7.orig/gui/widget.tcl
+++ core-network-4.7/gui/widget.tcl
@@ -908,7 +908,8 @@ proc getstats_link_ifname { link } {
     # TODO: need to determine session number used by daemon
     #       instead this uses a '*' character for a regexp match against
     #       the interfaces in /proc/net/dev
-    set ifname "n$node_num\\.$ifname\\.*"
+#    set ifname "n$node_num\\.$ifname\\.*"
+    set ifname "veth$node_num\\.[string range $ifname 3 end]\\.*"
     return $ifname
 }
 
