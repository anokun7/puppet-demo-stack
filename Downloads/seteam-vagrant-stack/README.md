# Vagrant Puppet Enterprise Stack

#### Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Size and Limitations](#size-and-limitations)
4. [Installation and Puppet Master](#installation-and-puppet-master)
    * [Quickstart](#quickstart)
    * [Clone the Repository](#clone-the-repository)
    * [Configure the Puppet Master](#configure-the-puppet-master)
    * [Access the Puppet Enterprise Console](#access-the-puppet-enterprise-console)
6. [Shutting Down and Resuming](#shutting-down-and-resuming)

## Overview
This tool provides a quick way to bootstrap an example deployment of Puppet Enterprise, complete with a master and several managed nodes running different operating systems. It's intended to give you an easy way to demonstrate Puppet Enterprise on a single laptop without any outside infrastructure.

The most up to date instructions will always be here: [TSE Confluence Demo Environment Page](https://confluence.puppetlabs.com/display/TSE/Demo+Environment)

## Prerequisites
This tool is built on top of a few different technologies, mainly VirtualBox and Vagrant, so you'll need to ensure that those are present before you continue. You'll also need to have the Git tools installed to checkout the repository. 

1. Install [Virtual Box](https://www.virtualbox.org/wiki/Downloads).
2. Install [Vagrant](http://vagrantup.com/).
3. Install the required Vagrant plugins:
	* `$ vagrant plugin install oscar`
	* `$ vagrant plugin install vagrant-hosts`
	* `$ vagrant plugin install vagrant-multiprovider-snap` (optional, but you won't have snapshot functionality if you don't install it)

Note that you'll also need acceess to the [private repository on GitHub](http://www.github.com/puppetlabs/seteam-vagrant-stack). If you don't have access for some reason, go ahead and open a ticket on [Jira](https://jira.puppetlabs.com) to let Operations know to give you access. 

## Size and Limitations
Each new VM takes up about 1.7GB to 7GB of hard drive space (depending on the image type), and each snapshot takes up about half as much as a full image. If you no longer need a particular VM and want to free up that space, use `vagrant destroy {vm name}`. If that doesn't work for some reason, you can manually delete the VM images and snapshots from `~/VirtualBox VMs/`.

The VMs also use a significant amount of RAM while they're running—about 1GB each—as well as CPU time. Most relatively recent laptops should be able to run at least 3-5 VMs while maintaining decent performance, but your mileage may vary. Make sure to shut down VMs when not in use (see [Shutting Down and Resuming](#shutting-down-and-resuming)) to avoid slowing down your computer unnecessarily. 


## Installation and Puppet Master
### Quickstart

    vagrant destroy -f; vagrant up; vagrant provision --provision-with hosts; vagrant snap take

### Clone the repository
First you'll need to clone the `seteam-vagrant-stack` repository from GitHub. If the following command doesn't work then you should refer to the above note about access to the Puppet Labs private repositories.

	$ git clone git@github.com:puppetlabs/seteam-vagrant-stack.git

### Configure the Puppet Master
You're finally ready to begin creating your demonstration environment. Change into the `seteam-vagrant-stack` directory and bring up the puppet master:

	$ cd seteam-vagrant-stack
	$ vagrant up /master/
	
It's going to take a little while to download the Centos image and configure it, during which time you'll see a lot of activity in the terminal. When it finishes, you should see something like this:

	Notice: /Stage[main]/Role::Puppetmaster/Exec[instantiate_environment]/returns: executed successfully
	Notice: Finished catalog run in 379.72 seconds

You may also see a warning that "The guest additions on this VM do not match the installed version of
VirtualBox." That doesn't appear to impact the functionality and it should be fixed with a subsequent release of the seteam-vagrant-stack tool.

### Access the Puppet Enterprise Console
You'll be back at the command prompt, but the puppet master is still running in the background. Before you can get to the console, you'll need to figure out where it is:

	$ vagrant hosts list

The response should look something like `10.20.1.1 master`, meaning that the `master` VM has the IP address of `10.20.1.1`. Next, just point your browser to `https://10.20.1.1` (or whatever the actual IP address is) and log in with the username `admin@puppetlabs.com`, password `puppetlabs`. Don't worry if you get a warning about the security certificate; that really won't affect anything. 

When you log in, you may notice that there's just one node listed: `master`. Not a bad start, but also not a great example of Puppet in action. In the next section, you'll add some additional nodes to manage.


## Shutting Down and Resuming
After a long day of booting up virtual machines in Vagrant, the output of `vagrant status` may start to look something like this:

	Current machine states:

	master                    running (virtualbox)
	centos59a                 not created (virtualbox)
	centos64a                 not created (virtualbox)
	centos64b                 running (virtualbox)
	centos64c                 not created (virtualbox)
	debian607a                running (virtualbox)
	ubuntu1204a               running (virtualbox)
	sles11a                   not created (virtualbox)
	solaris10a                running (virtualbox)
	server2008r2a             not created (virtualbox)
	server2008r2b             not created (virtualbox)
	
Running that many virtual machines is going to make it difficult to get much else done on your computer, so you'll want to run the following command to suspend all of the running virtual machines and reclaim those resources:

	$ vagrant suspend

You can also suspend individual machines by adding their name to the end of the command (e.g., `vagrant suspend master`). You can resume all suspended VMs with a single command, `vagrant resume`, or resume one at a time by specifying the name (e.g., `vagrant resume master`).

