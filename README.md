vagos
=====
Using vagrant-openstack for [hp helion public cloud](https://horizon.hpcloud.com) and [hp helion openstack](https://helion.hpwsportal.com/).

* Bootup instance: vagrant
* Provisioning: chef
* Test the instance: serverspec
* CI: jenkins

Notes
-----
* vendor cookbook is not git-managed. When you cloned first, you need to fetch cookbooks
* you need to create "passrc" file which contains "OS_PASSWORD" parameter for horizon login
  (This file is git-ignored bacause it contains credentials)
* floating ip addr is defined in "publicrc" file (FLOATING_IP parameter)

Prerequisites
-------------
```
$ rbenv versions
$ gem install bundle
$ bundle (install)
$ vagrant plugin install vagrant-openstack-plugin
$ vagrant box add dummy https://github.com/cloudbau/vagrant-openstack-plugin/raw/master/dummy.box
```

serverspec setup
----------------
```
$ serverspec-init   # choose "UN*X", "SSH" and "vagrant managed instance"
$ vi spec/default/*_spec.rb
$ vi .rspec   # setup color configuration
```

How to use
----------
* bootup
```
$ git clone https://github.com/tetsuyasodo/vagos
$ cd vagos
$ bundle exec berks vendor ./cookbooks
$ echo "export OS_PASSWORD=xxxxx" > passrc
$ . passrc
$ . publicrc
$ vagrant up --provider=openstack
```

* provision
```
$ vagrant ssh-config > vagrant-ssh.conf
$ bundle exec knife solo bootstrap default -F vagrant-ssh.conf
```

* test
```
$ grep vagrant-ssh spec/spec_helper.rb  ### modified to use vagrant-ssh.conf for serverspec test
$ bundle exec rake spec
$ bundle exec rake ci:setup:rspec spec  ### for Jenkins report
```

Integration with Jenkins
------------------------
* need to install git plugin
* create a new job
* "source code management" set to "git"
* "repository URL" set to "https://github.com/tetsuyasodo/vagos"
* "build procedure" set to "shell exec" and shell script is as follows:
```
rm -rf cookbooks
bundle exec berks vendor ./cookbooks
. ~/passrc
. publicrc
ssh-keygen -R $FLOATING_IP
vagrant up --provider=openstack
vagrant ssh-config > vagrant-ssh.conf
bundle exec knife solo bootstrap default -F vagrant-ssh.conf
bundle exec rake ci:setup:rspec spec
rm -f vagrant-ssh.conf
vagrant destroy -f
```
* "post build procedure" set to "JUnit" and xml stored in "spec/reports/**/*.xml"
* In MacOS, workspace is on "/Users/sodo/.jenkins/jobs/testjob01/workspace"

For further development of recipes and testcases
------------------------------------------------
```
$ bundle exec knife cookbook create nginx -o ./site-cookbooks  # change 'nginx' for your package name
$ vi site-cookbooks/nginx/recipes/default.rb
$ vi nodes/default.json  # add run_list
$ vi Berksfile   # add your cookbook entry
$ bundle exec berks vendor ./cookbooks   # if any vendor cookbooks to be added
```

ToDo
----

