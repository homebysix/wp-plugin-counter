#!/bin/sh

###
#
#            Name:  wp_plugin_counter.sh
#     Description:  This script counts how many WordPress plugins your site has,
#                   compares the count to the last known count, and notifies you
#                   if the count doesn't match. This script works best when
#                   triggered hourly by cron.
#          Author:  Elliot Jordan <elliot@elliotjordan.com>
#         Created:  2014-11-20
#   Last Modified:  2014-11-25
#         Version:  1.0.1-beta
#
###

################################### SETTINGS ###################################

# The URL of your website.
# No https:// and no trailing slash.
WEBSITE_URL="www.pretendco.com"

# The full path to the root dir of your website.
# No trailing slash.
WEBSITE_ROOT="/home3/pretendco/public_html"

# The relative path from $WEBSITE_ROOT to your WP plugins dir.
# No leading or trailing slash.
PLUGIN_DIR="wp-content/plugins"

# The full path to the file you'd like to save log output to.
# I recommend NOT saving this log file inside your $WEBSITE_ROOT dir.
LOG_FILE="/home3/pretendco/wp_plugin_counter.log"

# Set to true if you'd like to see `git status` output in notifications.
# Your $WEBSITE_ROOT must be a git repo in order for this to work.
INCLUDE_GIT_STATUS=false

# Set to true if you'd like to receive alerts via SMS upon plugin count change.
SEND_SMS_ALERT_ON_CHANGE=false
# If the above is true, specify your phone's email-to-txt address here.
SMS_RECIPIENT="0005551212@txt.att.net"

EMAIL_TO="you@pretendco.com"
EMAIL_FROM="$(echo $(whoami)@$(hostname))"

# Set to true if you'd like to receive an email regardless of the plugin count.
SEND_ALERTS_WHEN_COUNT_UNCHANGED=false

# Set to true if you want the script to echo the email instead of actually sending it.
DEBUG_MODE=false

######################### DO NOT EDIT BELOW THIS LINE ##########################


# Get last plugin count and timestamp.
LAST_PLUGIN_COUNT="$(tail -n 1 "$LOG_FILE" | awk -F' : | plugins.' {'print $2'})"
LAST_CHECK_DATE="$(tail -n 1 "$LOG_FILE" | awk -F' : ' {'print $1'})"

# Get current plugin count and timestamp.
CURRENT_PLUGIN_COUNT="$(ls -l /"$WEBSITE_ROOT/$PLUGIN_DIR/" | grep -v " ./" | grep -v " ../" | grep -v "total " | grep -v " index.php" | wc -l)"
CURRENT_CHECK_DATE="$(date)"

# Compare current count to last count and return result
if [[ "$LAST_PLUGIN_COUNT" != "$CURRENT_PLUGIN_COUNT" ]]; then
    HAS_COUNT_CHANGED=true
else
    HAS_COUNT_CHANGED=false
fi

# Write a new count and timestamp to the logs.
echo "$CURRENT_CHECK_DATE : $CURRENT_PLUGIN_COUNT plugins." >> $LOG_FILE

# If the count has changed, send an email.
if [[ $HAS_COUNT_CHANGED == true ]]; then

    if [[ $SEND_SMS_ALERT_ON_CHANGE == true && $SMS_RECIPIENT != "0005551212@txt.att.net" ]]; then

        SMS_MESSAGE="Plugin alert for $WEBSITE_URL. Details sent to $EMAIL_TO.\n.\n"
        printf "$SMS_MESSAGE" | /usr/sbin/sendmail "$SMS_RECIPIENT"

    fi

    EMAIL_SUBJ="[$WEBSITE_URL] WordPress plugin count change detected"
    EMAIL_MSG="WARNING: The number of WordPress plugins on $WEBSITE_URL has changed since our last check:\n\n"
    # Include last two lines from the log.
    EMAIL_MSG+="$(tail -n 2 "$LOG_FILE")\n\n"
    # Include git status, if that option is enabled.
    if [[ $INCLUDE_GIT_STATUS == true ]]; then
        GIT_STATUS="$(cd "$WEBSITE_ROOT"; git status)"
        EMAIL_MSG+="Here are the file-level changes, as reported by Git:\n\n$GIT_STATUS\n\n"
    fi
    EMAIL_MSG+="Thank you."

    # Construct the message
    SENDMAIL="From: $EMAIL_FROM\nTo: $EMAIL_TO\nSubject: $EMAIL_SUBJ\n$EMAIL_MSG\n.\n"

    if [[ $DEBUG_MODE == true ]]; then
        # Print the message
        printf "$SENDMAIL"
    else
        # Send the message
        printf "$SENDMAIL" | /usr/sbin/sendmail "$EMAIL_TO"
    fi

elif [[ $SEND_ALERTS_WHEN_COUNT_UNCHANGED == true ]]; then

    EMAIL_SUBJ="[$WEBSITE_URL] WordPress plugin count verified"
    EMAIL_MSG="WARNING: The number of WordPress plugins on $WEBSITE_URL has not changed since our last check:\n\n"
    # Include last line from the log.
    EMAIL_MSG+="$(tail -n 1 "$LOG_FILE")\n\n"
    # Include git status, if that option is enabled.
    if [[ $INCLUDE_GIT_STATUS == true ]]; then
        GIT_STATUS="$(cd "$WEBSITE_ROOT"; git status)"
        EMAIL_MSG+="Here are the file-level changes, as reported by Git:\n\n$GIT_STATUS\n\n"
    fi
    EMAIL_MSG+="Thank you."

    # Construct the message
    SENDMAIL="From: $EMAIL_FROM\nTo: $EMAIL_TO\nSubject: $EMAIL_SUBJ\n$EMAIL_MSG\n.\n"

    if [[ $DEBUG_MODE == true ]]; then
        # Print the message
        printf "$SENDMAIL"
    else
        # Send the message
        printf "$SENDMAIL" | /usr/sbin/sendmail "$EMAIL_TO"
    fi

fi

exit $?