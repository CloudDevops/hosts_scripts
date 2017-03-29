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
        for i in `cat ie.intuit.net`;do echo $i.ie.intuit.net ;done > ie-reformatfqdn
        for i in `cat corp.intuit.net`;do echo $i.corp.intuit.net ;done > corp-reformatfqdn
        cat ie-reformatfqdn > reformatfqdn ; cat corp-reformatfqdn >> reformatfqdn
	cat reformatfqdn | tr '\n' ','|grep intuit.net > reformatfqdn1
	rm out1 ieMaster* corpMaster* ie.* corp.* ie-* corp-* reformatfqdn
}

function vagrant_salt_master {
	sed -i 's/minion1.corp.intuit.net/minion1/g' reformatfqdn1 
}


function nodegroup_from_snow {

        cat reformatfqdn1 > auto_nodegroup

        #Sed all uppercase to lower case

        sed 's/.*/\L&/'  auto_nodegroup > auto_nodegroup1
	rm auto_nodegroup
        #Generate random number for the nodegroup name

        #Delete all white space and tabs before the first word in a line     sed -e 's/^[ \t]*//'

}

function nodegroups {


        {  printf "nodegroups:\n check-zone: L@" ; cat auto_nodegroup1 ; } > auto-nodegroup2
	   cp auto-nodegroup2 /etc/salt/master.d/nodegroups.conf
	   rm auto_nodegroup1
}

function first_run {

        echo > file-to-sort

        salt -N check-zone test.ping --async 2>&1 | tee -a  file-to-sort

        job_id=`cat file-to-sort |grep 'ID'| awk '{print $6}'`

        sleep 15

        salt-run jobs.print_job $job_id > job_completed
	
	rm file-to-sort

}



#-----code

snow_data_transform

reformat-fqdn

vagrant_salt_master

nodegroup_from_snow

nodegroups

first_run
