WordPress Plugin Counter
========================

This script counts how many WordPress plugins your site has, compares the count to the last known count, and notifies you of the results.

This script works best when triggered hourly by cron.


## Features

- Email notifications tell you whether the plugin count has changed.
- Filter-friendly subject line lets you keep an email record of changes.
- Integration with git, for inclusion of file-level changes in the email notifications.
- If the plugin count has changed, you can be notified by SMS message.
- Since the plugin counter is not a WordPress plugin itself, it's less susceptible to tampering.
- Relatively easy to configure on web hosts that support custom cron entries.


## Instructions

1. Edit the options in the WEBSITE SETTINGS and ALERT SETTINGS sections to suit your environment. (See [below](#settings-detail) for details.)
2. Place the script in your web hosting "home" folder.
3. Add the script to your host's cron tab. If you want it to check hourly, for example, the crontab might look like this:
```
0 * * * * /bin/sh /home3/pretendco/wp_plugin_counter.sh
```

The first time the script runs, you'll get a notification that the plugin count has changed. (This is also an excellent opportunity to test whether the SMS alerts are working, if you configured that option.)


## Settings Detail

#### Website Settings

For the first four settings, you can specify a single value, for example:
```
WEBSITE_NAME=(
    "www.pretendco.com"
)
```
Or you can specify values for multiple WordPress sites, for example:
```
WEBSITE_NAME=(
    "www.pretendco.com"
    "www.pretendco.com/blog"
    "shop.pretendco.com"
)
```
All four settings require the same number of values. (For example, don't
specify three WEBSITE_NAMEs but only one WEBSITE_ROOT.)


#### Alert Settings

I recommend that you set DEBUG_MODE to true and run the script manually to test whether alerts are working.

Once you confirm that the output is correct (especially the "To:" email address), then set DEBUG_MODE to false.


## Known Issues

- Does not detect CHANGED plugins; only detects ADDED or REMOVED plugins.
- If a fatal error occurs, no notification will be sent. Use SSH to test running the script manually before you include in cron, and you'll minimize this risk.


## To Do

- [ ] Ability to test alerts easily.
- [ ] Ability to use switches.
- [ ] Ability to loop endlessly.
- [ ] `grep -c` intead of `grep x | wc -l`