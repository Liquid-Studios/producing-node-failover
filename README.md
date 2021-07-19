# Producing Node Failover via `keepalived`
This is a simple `keepalived` configuration to automatically pause/resume the `nodeos` producer plugin to prive high-availability.
Based on https://github.com/pete001/eos-bp-failover/tree/master/producing-node-failover
## Install `keepalived` and `jq`
We highly recommend getting familiar with `keepalived` and you to make sure multicast communication is possible between producer nodes.
```
sudo apt-get install linux-headers-$(uname -r)
sudo apt-get install keepalived jq
```
## Setting Up for Nodeos
For a simple check `keepalived.conf` will request the `eosio::http_plugin` via the  [isInSync.sh](isInSync.sh) script.
```
vrrp_script chk_nodeos {
    script "/bin/bash /etc/keepalived/isInSync.sh"
    interval 2
}
```
The idea is that you would set this up on two producing nodes, a `MASTER` and a `BACKUP`.

Here is an example config for a `MASTER` (this example does not focus on the networking, there are many tutorials out there on how to do this):
```
vrrp_instance ProducerVRRP {

    state MASTER
    interface eth0
    virtual_router_id 5
    priority 200
    advert_int 1

    virtual_ipaddress {
        192.168.1.1/24 dev eth0
    }

    track_script {
        chk_nodeos
    }

    notify /etc/keepalived/check_nodeos.sh
```
The two important sections here are `track_script` and `notify`.

`chk_nodeos` registers the `nodeos` process id checker.

`notify` is a link to the script which will be invoked as soon as the `track_script` returns a code other than `0`.

### The Producer HA Script

Check the script @ [check_nodes.sh](check_nodeos.sh)

`keepalived` will automatically pass the state to the script referenced in `notify`.

Using this state we can invoke the relevant `pause` or `resume` call to `nodeos` which works via the `eosio::producer_api_plugin` plugin which must be enabled in the `config.ini`.

The idea is that both producing nodes would use the same `signature-provider`, we keep both producers online but thanks to the producer api we can ensure that only 1 producing node is active at one time whilst the backup remains online keeping synced to the network.

Within the `check_nodes.sh` script, there is an optional Slack webhook that can be used to send a push notification on any update. This could be easily changed to drop in Pager Duty or some other service that will hook into your Ops alerting platform.

