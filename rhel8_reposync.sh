#!/bin/bash
#set -x

export repo_dir="/repo1"
export todate=`date +%Y%m%d`
export totime=`date +%Y%m%d-%H%M%S`
export repofile="/repo1/logs/reposync8.log.$totime"
export tmppath="/root/bin/temp"
export fpath="/repo1/rhel8.repo"

### Modify Service IP
export sip="10.65.30.103"

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

echo "Start Time : $totime " >> $repofile

### repo file Create
echo "#### Local Repository ####" > $fpath
echo "#Create by : $(date +%y%m%d-%H%M)" >> $fpath
echo "" >> $fpath
echo "" >> $fpath



echo "-------------------------------------Start-------------------------------------------" >> $repofile
for repos in $(cat /root/reposync/rhel8_channel.txt)
do
echo "-------------------------------------$repos-------------------------------------------" >> $repofile
### reposync

#/usr/bin/reposync --gpgcheck -l --downloadcomps --download-metadata -r $repos --download_path=$repo_dir >> $repofile 2>&1
/usr/bin/reposync --nogpgcheck --newest-only --downloadcomps --download-metadata --repo $repos -p $repo_dir >> $repofile 2>&1
echo "" >> $repofile
#createrepo $repo_dir/$repos >> $repofile 2>&1

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

