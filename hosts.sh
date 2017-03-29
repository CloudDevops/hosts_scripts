#----functions

function snow_data_transform {
	cp QDC-D out
	cat out | tr '"' '\n' |grep intuit.net > out1
	rm out
}

function reformat-fqdn {
        cat out1 | tr '"' '\n' |grep ie.intuit.net > ieMaster_tmp
        cat out1 | tr '"' '\n' |grep corp.intuit.net > corpMaster_tmp
        cat ieMaster_tmp |grep intuit.net > ieMaster
        cat corpMaster_tmp |grep intuit.net > corpMaster
        cat ieMaster|grep intuit.net > ie.intuit.net_tmp
        cat corpMaster|grep intuit.net > corp.intuit.net_tmp
        cat ie.intuit.net_tmp | cut -d"." -f1 > ie.intuit.net
        cat corp.intuit.net_tmp | cut -d"." -f1 > corp.intuit.net
        for i in `cat ie.intuit.net`;do echo $i.corp.intuit.net ;done > ie-reformatfqdn
        for i in `cat corp.intuit.net`;do echo $i.corp.intuit.net ;done > corp-reformatfqdn
        cat ie-reformatfqdn > reformatfqdn ; cat corp-reformatfqdn >> reformatfqdn
	rm out1 ieMaster* corpMaster* ie.* corp.* ie-* corp-*
}

function vagrant_salt_master {
	sed -i 's/minion1.corp.intuit.net/minion1/g' reformatfqdn 
}





#-----code

snow_data_transform

reformat-fqdn

vagrant_salt_master


