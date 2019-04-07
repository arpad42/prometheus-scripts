# Introduction

I used (and still use) Munin for more than a decade. I have several dozens scripts written in Bash, Perl, Python or Ruby to gather specific metrics. Implement them one-by-one to create a specialized Prometheus exporter is a big PITA so this is why I decided to utilize the Prometheus's textfile exporter and modify my scripts only a bit to generate Prometheus output instead of Munin.

Every script produces it's output to the STDOUT and the very minimalistic `run.sh` puts them to the right place. The scheduling is based on cron but you can use any other scheduling solution.

I know there is a dedicated munin_exporter but I had a few problems with it:
* You have to install/keep the Munin deployment which means that you have to configure and maintain an extra service.
* It doesn't supports labelling the time-series (or I didn't find it how to do that). Every time-series has it's own unique name. E.g. it will generate `spamstats_ham{...}` and `spamstats_spam{...}` instead of `spamstats{line="ham",...}` and `spamstats{line="spam",...}`.
* It requires to setup a `label` for every time-series in Munin.
* I got false results from `DERIVE` series. Just changing the type to `GAUGE` solved the issue even that specific series should be `counter` in Prometheus.

# Installation

Create the necessary directories:
```sh
mkdir -p /etc/prometheus/run{1,2,5,60}
mkdir -p /usr/share/prometheus/scripts
mkdir -p /var/lib/prometheus-scripts
```

Copy the scripts:
```sh
cp run.sh /usr/share/prometheus
cp scripts/* /usr/share/prometheus/scripts/
```

Enable the textfile collector in the node_exporter (create the directory if it doesn't exist):
```
... --collector.textfile.directory=/var/lib/node_exporter/ ...
```

If the `/var/lib/node_exporter/` isn't appropriate for you feel free to change it and modify the `run.sh` too.

Create cron entries to schedule the script executions. Create/modify `/etc/cron.d/prometheus` to include this lines:
```
* * * * *       root    /usr/share/prometheus/run.sh 1
*/2 * * * *     root    /usr/share/prometheus/run.sh 2
*/5 * * * *     root    /usr/share/prometheus/run.sh 5
0 * * * *       root    /usr/share/prometheus/run.sh 60
```

Create symlinks to the selected metrics under `/etc/prometheus/runX`, e.g.:
```sh
ln -s /usr/share/prometheus/scripts/dovecot /etc/prometheus/run2/
```
