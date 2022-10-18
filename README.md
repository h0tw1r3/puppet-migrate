# Using Bolt with Puppetdb

Project [queries the puppetdb] for inventory. The steps below include installing bolt via ruby gems which is sufficient for this project, but a package install is typically recommended.

For this guide you will need:

* access to the PE server command line.
* a PE user with permission to query the puppetdb.
* a local user on all nodes with sudo root access.

## Setup

_Perform all steps as a non-root user with sudo access on the server you are migrating from._

1. Install [Puppet Bolt]

       /opt/puppetlabs/puppet/bin/gem install -N --user bolt

   > requires internet access, alternatively you may download a bolt
     package directoy from puppet

2. Add the ruby gems bin to your environment PATH.

       PATH=$PATH:$(/opt/puppetlabs/puppet/bin/ruby -e 'print Gem.user_dir')/bin

3. Download CA bundle  
   **SKIP THIS STEP** if you are executing from the old server as recommended!

       rm ca.pem
       curl -k https://<HOSTNAME>:8140/puppet-ca/v1/certificate/ca > ca.pem

   > the URL may not work with very old versions of PE

4. Generate an access token with permission to query the puppetdb.
   For expediency, authenticate using an admin account.

       puppet-access login --lifetime 1d

5. Edit `bolt-defaults.yaml`.  
   Modify the hostname of `server_uri` to the OLD PE server name.

6. Edit `inventory.yaml`.  
   Modify `query` to select the targets (nodes) for migration.

7. Confirm bolt returns the list of targets you expect.

       bolt inventory show

8. Test executing command on all targets as root.

       bolt command run 'uptime' --targets all

   > executing user requires sudo root access on all targets

9. Review migration script, *modify as necessary* and test against one node.

       bolt script run migrate.sh --targets :NODE:

10. Deploy to all nodes.

        bolt script run migrate.sh --targets all

[Puppet Bolt]: https://puppet.com/docs/bolt/latest/bolt.html
[queries the puppetdb]: https://puppet.com/docs/bolt/latest/bolt_connect_puppetdb.html
