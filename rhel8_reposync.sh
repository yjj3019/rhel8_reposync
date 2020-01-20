#!/bin/bash
#set -x

export repo_dir="/repo1"
export todate=`date +%Y%m%d`
export totime=`date +%Y%m%d-%H%M%S`
export repofile="/repo1/logs/reposync8.log.$totime"
export tmppath="/root/bin/temp"
export fpath="/repo1/rhel8.repo"

### yum file check
if [ -f /var/run/yum.pid ]; then
echo "Start Fail.. YUM Run File Found : $repofile " >> $repofile
echo "Time : $totime " >> $repofile
exit 11
fi

### repofile check
if [ -f $repofile ]; then
echo "Found File : $repofile " >> $repofile
else
touch $repofile
fi

### Log Directory Check
if [ ! -d $repo_dir/logs ]; then
        echo "$repo_dir/logs Not Found " >> $repofile
        mkdir -p $repo_dir/logs
fi

### Old Logs File Delete
/usr/bin/find $repo_dir/logs -mtime +30 -exec rm -f {} \;

### Start Time 
echo "Start Time : $totime " >> $repofile

### repo file Create
echo "#### Local Repository ####" > $fpath
echo "#Create by : $totime" >> $fpath
echo "" >> $fpath
echo "" >> $fpath



echo "-------------------------------------Start-------------------------------------------" >> $repofile
for repos in $(cat /root/reposync/rhel8_channel.txt)
do
echo "-------------------------------------$repos-------------------------------------------" >> $repofile
### reposync

if [ -d $repo_dir/$repos ]
then
	/usr/bin/reposync --nogpgcheck --newest-only --downloadcomps --download-metadata --repo $repos -p $repo_dir >> $repofile 2>&1
	echo "" >> $repofile
	createrepo $repo_dir/$repos >> $repofile 2>&1
else
	/usr/bin/reposync --nogpgcheck --downloadcomps --download-metadata --repo $repos -p $repo_dir >> $repofile 2>&1
	echo "" >> $repofile
	createrepo $repo_dir/$repos >> $repofile 2>&1
fi
	
### repo file Create
  echo "[$repos]" >> $fpath
  echo "name=$repos" >> $fpath
  echo "baseurl=http://$sip/$repos" >> $fpath
  echo "enable=1" >> $fpath
  echo "gpgcheck=0" >> $fpath
  echo "" >> $fpath
  echo "" >> $fpath

done

echo "----------------------------------------END------------------------------------------" >> $repofile

exit;
