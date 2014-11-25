#!/bin/sh

###
#
#            Name:  wp_plugin_counter.sh
#     Description:  This script counts how many WordPress plugins your site has,
#                   compares the count to the last known count, and notifies you
#                   of the results. This script works best when triggered hourly
#                   by cron.
#                       - Ability to include git status in email summary.
#                       - Ability to send SMS alert upon plugin count change.
#          Author:  Elliot Jordan <elliot@elliotjordan.com>
#         Created:  2014-11-20
#   Last Modified:  2014-11-24
#         Version:  1.0
#
###

################################### SETTINGS ###################################

WEBSITE_URL="www.pretendco.com"
WEBSITE_ROOT="/home3/pretendco/public_html" # no trailing slash
PLUGIN_DIR="wp-content/plugins" # no leading or trailing slash
LOG_FILE="/home3/pretendco/wp_plugin_counter.log"

INCLUDE_GIT_STATUS=false
SEND_SMS_ALERT_ON_CHANGE=false
SEND_ALERTS_WHEN_COUNT_UNCHANGED=false

EMAIL_TO="you@pretendco.com"
SMS_RECIPIENT="0005551212@txt.att.net"
EMAIL_FROM="$(echo $(whoami)@$(hostname))"

################################################################################

# Get last plugin count and timestamp.
LAST_PLUGIN_COUNT="$(tail -n 1 "$LOG_FILE" | awk -F' : | plugins.' {'print $2'})"
LAST_CHECK_DATE="$(tail -n 1 "$LOG_FILE" | awk -F' : ' {'print $1'})"

# Get current plugin count and timestamp.
CURRENT_PLUGIN_COUNT="$(ls -l /"$WEBSITE_ROOT/$PLUGIN_DIR/" | grep -v " ./" | grep -v " ../" | grep -v "total " | grep -v " index.php" | wc -l)"
CURRENT_CHECK_DATE="$(date)"

CHANGE_STATUS=false
EMAIL_SUBJ=""
EMAIL_MSG=""

# Write new plugin count and timestamp.
echo "$CURRENT_CHECK_DATE : $CURRENT_PLUGIN_COUNT plugins." >> $LOG_FILE

# Compare last count to current count, and set email message accordingly.
if [[ "$LAST_PLUGIN_COUNT" != "$CURRENT_PLUGIN_COUNT" ]]; then

    CHANGE_STATUS=true

    if [[ $SEND_SMS_ALERT_ON_CHANGE == true ]]; then

        # Only send SMS if a change has been detected, and if the SMS setting above is true
        SMS_MESSAGE="Plugin alert for $WEBSITE_URL. Details sent to $EMAIL_TO.\n.\n"
        printf "$SMS_MESSAGE" | /usr/sbin/sendmail "$SMS_RECIPIENT"

    fi

elif [[ $SEND_ALERTS_WHEN_COUNT_UNCHANGED == false ]]; then

    # If alerts are not needed, we can stop here.
    exit 0

fi

# Start constructing email message.
EMAIL_SUBJ+="[$WEBSITE_URL] WordPress plugin count "
if [[ $CHANGE_STATUS == true ]]; then
    EMAIL_SUBJ+="change detected"
    EMAIL_MSG+="WARNING: "
else
    EMAIL_SUBJ+="verified"
fi
EMAIL_MSG+="The number of WordPress plugins on $WEBSITE_URL has "
if [[ $CHANGE_STATUS == false ]]; then
    EMAIL_MSG+="not "
fi
EMAIL_MSG+="changed since our last check:\n\n"

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

# Send the message
printf "$SENDMAIL" | /usr/sbin/sendmail "$EMAIL_TO"

exit $?