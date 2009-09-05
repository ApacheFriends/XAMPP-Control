#!/bin/sh

#
# XAMPP
# Copyright (C) 2009 by Apache Friends
# 
# Authors of this file:
# - Kai 'Oswald' Seidler <oswald@apachefriends.org>
# - Christian Speich <kleinweby@apachefriends.org>
# 
# This file is part of XAMPP.
# 
# XAMPP is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# XAMPP is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with XAMPP.  If not, see <http://www.gnu.org/licenses/>.
#

f=/Applications/XAMPP/etc/my.cnf

awk '
/^\[mysqld\]/,/^\[mysqldump\]/ { 
	if($1=="#skip-networking") {
		print "# commented in by xampp security"
		print $0
		print "skip-networking"
		next
	}
}
{
	print
}' $f > /tmp/xampp$$
cp /tmp/xampp$$ $f
rm /tmp/xampp$$ 