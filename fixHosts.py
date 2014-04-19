#!/usr/bin/python
# vim:ts=4:et:sts=4:sw=4:smarttab
import os
import sys

def generateHosts(team, box):
    team_number = team * 10
    if box == "beatles":
        hostfile = [
            "127.0.0.1    localhost.localdomain localhost",
            "::1          localhost6.localdomain6 localhost6",
            "10.0.%i.11   beatles.blue%i.pcdc" % (team_number, team),
            "10.0.%i.11   support.blue%i.pcdc" % (team_number, team),
        ]
    elif box == "zeppelin":
        hostfile = [
            "127.0.0.1    localhost.localdomain localhost",
            "::1          localhost6.localdomain6 localhost6",
        ]
    elif box == "floyd":
        hostfile = [
            "127.0.0.1    localhost.localdomain localhost",
            "10.0.%i.5    floyd" % team_number,
        ]
    f = open("/etc/hosts", "w")
    for line in hostfile:
        f.write(line + "\n")
    f.close()

def removeFiles():
    dir_list = [
        "/etc/httpd/logs",
        "/var/www/html/roundcube/logs",
    ]
    for dir in dir_list:
        os.system("rm -rf %s/*" % dir)
        print "Deleted '%s/*'." % dir

def removeTempUsers():
    users = [
        "jweatherly",
        "jweathelry",
        "testuser",
    ]
    print "Deleting temp users...",
    for user in users:
        os.system("userdel %s" % user)
        os.system("rm -rf /home/%s" % user)
    print "done."

def removeHistory():
    f = open("/etc/passwd", "r")
    output = f.readlines()
    for line in output:
        la = line.split(":")
        if int(la[2]) >= 500 or la[2] == "0":
            name = la[0]
            directory = la[5]
            try:
                path = os.path.join(directory, ".bash_history")
                os.remove(path)
            except OSError:
                print "Cannot delete history file for '%s', skipping." % name
        else:
            print "Skipping user '%s:%s'." % (la[0], la[2])

def setHostname(team, box):
    hostname = "%s.blue%i.pcdc" % (box, team)
    print "Setting hostname to '%s'..." % hostname,
    os.system("hostname %s" % hostname)
    print "done."

def setEthernet(team):
    tn = team * 10
    print "Creating the ethernet configuration file...",
    file = [
        "DEVICE=eth0",
        "BOOTPROTO=static",
        "# HWADDR=00:21:70:BE:01:C3",
        "ONBOOT=yes",
        "NETMASK=255.255.255.0",
        "GATEWAY=10.0.%i.1" % tn,
        "DNS=10.0.%i.7" % tn,
    ]
    if box == "zeppelin":
        file.append("IPADDR=10.0.%i.17" % tn)
    elif box == "beatles":
        file.append("IPADDR=10.0.%i.11" % tn)
    elif box == "floyd":
        file.append("IPADDR=10.0.%i.5" % tn)
    f = open("/etc/sysconfig/network-scripts/ifcfg-eth0", "w")
    for line in file:
        f.write("%s\n" % line)
    f.close()
    print "done."

def clearSqlData(team, box):
    commands = [ 
        "DELETE FROM db.orders;",
        "DELETE FROM db.orders_total;",
    ]
    if box == "floyd":
        for line in commands:
            print "Removing table information: '%s'..." % line
            command = 'mysql -u root -e "%s"' % line
            os.system(command)
    else:
        print "No database configured, skipping..."

def insertDatabase(box):
    if box != "floyd":
        return
    os_ver = open("/etc/redhat-release", "r").readlines()[0].rstrip("\n")
    print "Detected OS: '%s'" % os_ver
    db_file = ""
    os_split = os_ver.split(" ")[2]
    commands = [
        "DROP DATABASE db;",
        "CREATE DATABASE db;",
    ]
    for line in commands:
        command = 'mysql -u root -e "%s"' % line
        print "Running command: '%s'..." % command,
        os.system(command)
        print "done."
    if os_split == "3.4":
        db_file = "data/floyd_college_db.sql" 
    else:
        db_file = "data/floyd_highschool_db.sql"
    command = "mysql -u root db < %s" % db_file
    print "Executing command: '%s'..." % command,
    os.system(command)
    print "done."

if __name__ == "__main__":
    team = int(sys.argv[1])
    box = sys.argv[2]
    generateHosts(team, box)
    removeTempUsers()
    removeFiles()
    removeHistory()
    setHostname(team, box)
    setEthernet(team)
    insertDatabase(box)
    clearSqlData(team, box)
