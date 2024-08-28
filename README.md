I was curious to see what all things bots are trying to exploit on my VMs, the naughty IP addresses, and what not. So I wrote a simple Ruby script to parse a log file.

I believe the format assumed is the default CentOS rsyslog format:
```
Jul 15 05:00:01 <user.debug> tower devd[38761]: Pushing table
```

An example output in current setup would look like this:
```
7403
["82.144.183.66", 2079]
["admin", 2048]
["141.98.11.11", 1537]
["62.122.184.71", 1092]
["141.98.11.113", 973]
["ubuntu", 928]
["test", 800]
["217.76.51.101", 796]
["14.199.160.53", 796]
["user", 680]
```

The current setup parses the counts how many times a certain IP address or username shows up in the logs. It is easy enough to configure / expand to parse and output whatever you are interested in.
