#!/bin/sh

###
#
#            Name:  wp_plugin_counter.sh
#     Description:  This script counts how many WordPress plugins your site has,
#                   compares the count to the last known count, and notifies you
#                   by email and/or SMS if the count doesn't match. This script
#                   works best when triggered hourly by cron.
#          Author:  Elliot Jordan <elliot@elliotjordan.com>
#         Created:  2014-11-20
#   Last Modified:  2014-12-03
#         Version:  1.1.1-beta
#
###

############################### WEBSITE SETTINGS ###############################

# The name or URL of your website(s).
# No https:// and no trailing slash.
WEBSITE_NAME=(
    "www.pretendco.com"
    "www.pretendco.com/blog"
    "shop.pretendco.com"
)

# The full path to the root dir of your website(s).
# No trailing slash.
WEBSITE_ROOT=(
    "/home3/pretendco/public_html"
    "/home3/pretendco/public_html/blog"
    "/home3/pretendco/subdomains/shop"
)

# The relative paths from WEBSITE_ROOT to your WP plugins dir.
# This is "wp-content/plugins" by default. No leading or trailing slash.
PLUGIN_DIR=(
    "wp-content/plugins"
    "wp-content/plugins"
    "wp-content/plugins"
)

# The full path to the file(s) you'd like to save log output to.
# I recommend NOT saving this log file inside your WEBSITE_ROOT dir.
# You can use the same log for multiple sites.
LOG_FILE=(
    "/home3/pretendco/wp_plugin_counter.log"
    "/home3/pretendco/wp_plugin_counter.log"
    "/home3/pretendco/wp_plugin_counter.log"
)

################################ ALERT SETTINGS ################################

# Set to true if you'd like to see `git status` output in notifications.
# Your WEBSITE_ROOT must be a git repo in order for this to work.
INCLUDE_GIT_STATUS=false

# Set to true if you'd like to receive alerts via SMS upon plugin count change.
SEND_SMS_ALERT_ON_CHANGE=false
# If the above is true, specify your phone's email-to-txt address here.
SMS_RECIPIENT="0005551212@txt.att.net"

# The email notifications will be sent to this email address.
# Multiple "to" addresses can be separated by commas.
EMAIL_TO="you@pretendco.com, somebodyelse@pretendco.com"

# The email notifications will be sent from this email address.
EMAIL_FROM="$(echo $(whoami)@$(hostname))"

# Set to true if you'd like to receive an email regardless of the plugin count.
SEND_ALERTS_WHEN_COUNT_UNCHANGED=false

# The path to sendmail on your server. Typically /usr/sbin/sendmail.
sendmail="/usr/sbin/sendmail"

# Set to true if you want the script to display the email in standard output
# instead of actually sending it.
DEBUG_MODE=false


################################################################################
######################### DO NOT EDIT BELOW THIS LINE ##########################
################################################################################


######################## VALIDATION AND ERROR CHECKING #########################

# Let's make sure we have the same number of website settings.
if [[ ${#WEBSITE_NAME[@]} != ${#WEBSITE_ROOT[@]} ||
      ${#WEBSITE_NAME[@]} != ${#PLUGIN_DIR[@]} ||
      ${#WEBSITE_NAME[@]} != ${#LOG_FILE[@]} ]]; then

    echo "Error: Please carefully check the website settings in the wp_plugin_counter.sh file. The number of parameters don't match." >&2
    exit 1001

fi # End website settings count validation.

# Let's make sure we aren't using default email alert settings.
if [[ $EMAIL_TO == "you@pretendco.com, somebodyelse@pretendco.com" ]]; then

    echo "Error: The email alert settings are still set to the default value. Please edit them to suit your environment." >&2
    exit 1002

fi # End email settings validation.

# Let's make sure we aren't using default SMS alert settings.
if [[ $SEND_SMS_ALERT_ON_CHANGE == true &&
      $SMS_RECIPIENT == "0005551212@txt.att.net" ]]; then

    echo "Error: The SMS alert settings are still set to the default value. Please edit them to suit your environment." >&2
    exit 1003

fi # End SMS settings validation.

# Let's make sure the sendmail path is correct.
if [[ ! -x $sendmail ]]; then

    echo "Error: The specified path to sendmail ($sendmail) appears to be incorrect. Trying to locate the correct path..." >&2
    sendmail_try2=$(which sendmail)

    if [[ $sendmail_try2 == '' || ! -x $sendmail_try2 ]]; then
        echo "Error: Unable to locate the path to sendmail." >&2
        exit 1004
    else
        echo "Located sendmail at $sendmail_try2. Please adjust the \"$(basename $0)\" script settings accordingly." >&2
        sendmail="$sendmail_try2"
        # Fatal error avoided. No exit needed.
    fi

fi # End sendmail validation.


################################# MAIN PROCESS #################################

# Count the number of sites we need to process.
SITE_COUNT=${#WEBSITE_NAME[@]}

# Begin iterating through websites.
for (( i = 0; i < $SITE_COUNT; i++ )); do

    # Get last plugin count and timestamp.
    LAST_PLUGIN_COUNT="$(grep " : ${WEBSITE_NAME[$i]} : " "${LOG_FILE[$i]}" | tail -n 1 | awk -F ' : | plugins' {'print $3'})"
    LAST_CHECK_DATE="$(grep " : ${WEBSITE_NAME[$i]} : " "${LOG_FILE[$i]}" | tail -n 1 | awk -F ' : ' {'print $1'})"

    # Get current plugin count and timestamp.
    # This count excludes the following items from the `ls -l` output:
    #   The line which gives the total size of the directory.
    #   The lines ./ and ../ which link to the current directory and its parent.
    #   Any files called index.php. ("Silence is golden.")
    CURRENT_PLUGIN_COUNT="$(ls -l /"${WEBSITE_ROOT[$i]}/${PLUGIN_DIR[$i]}/" | grep -v " ./$" | grep -v " ../$" | grep -v "^total " | grep -v " index.php$" | wc -l)"
    CURRENT_CHECK_DATE="$(date)"

    # Compare current count to last count and return result.
    if [[ "$LAST_PLUGIN_COUNT" != "$CURRENT_PLUGIN_COUNT" ]]; then
        HAS_COUNT_CHANGED=true
    else
        HAS_COUNT_CHANGED=false
    fi

    # If no previous log exists for this site (e.g. on first run) then do not send alerts.
    if [[ $(grep " : ${WEBSITE_NAME[$i]} : " "${LOG_FILE[$i]}" | wc -l) == 0 ]]; then
        HAS_COUNT_CHANGED=false
    fi

    # Write a new count and timestamp to the logs.
    echo "$CURRENT_CHECK_DATE : ${WEBSITE_NAME[$i]} : $CURRENT_PLUGIN_COUNT plugins" >> ${LOG_FILE[$i]}

    # If the count has changed, send an email.
    if [[ $HAS_COUNT_CHANGED == true ]]; then

        if [[ $SEND_SMS_ALERT_ON_CHANGE == true && $SMS_RECIPIENT != "0005551212@txt.att.net" ]]; then

            SMS_MESSAGE="Plugin alert for ${WEBSITE_NAME[$i]}. Details sent to $EMAIL_TO.\n.\n"
            printf "$SMS_MESSAGE" | $sendmail "$SMS_RECIPIENT"

        fi

        EMAIL_SUBJ="[${WEBSITE_NAME[$i]}] WordPress plugin count change detected"
        EMAIL_MSG="WARNING: The number of WordPress plugins on ${WEBSITE_NAME[$i]} has changed since our last check:\n\n"

        # Include last two lines from the log.
        EMAIL_MSG+="$(grep " : ${WEBSITE_NAME[$i]} : " "${LOG_FILE[$i]}" | tail -n 2)\n\n"

        # Include git status, if that option is enabled.
        if [[ $INCLUDE_GIT_STATUS == true ]]; then
            GIT_STATUS="$(cd "${WEBSITE_ROOT[$i]}"; git status)"
            if [[ $? == 0 ]]; then
                EMAIL_MSG+="Here are the file-level changes, as reported by Git:\n\n$GIT_STATUS\n\n"
            else
                EMAIL_MSG+="(An error occurred while trying to check Git status.)\n\n"
            fi
        fi

        EMAIL_MSG+="Thank you."

        # Construct the message.
        THE_EMAIL="From: $EMAIL_FROM\nTo: $EMAIL_TO\nSubject: $EMAIL_SUBJ\n$EMAIL_MSG\n.\n"

        if [[ $DEBUG_MODE == true ]]; then
            # Print the message, if in debug mode.
            printf "$THE_EMAIL\n\n"
        else
            # Send the message.
            printf "$THE_EMAIL" | $sendmail "$EMAIL_TO"
        fi

    elif [[ $SEND_ALERTS_WHEN_COUNT_UNCHANGED == true ]]; then

        EMAIL_SUBJ="[${WEBSITE_NAME[$i]}] WordPress plugin count verified"
        EMAIL_MSG="WARNING: The number of WordPress plugins on ${WEBSITE_NAME[$i]} has not changed since our last check:\n\n"

        # Include last line from the log.
        EMAIL_MSG+="$(grep " : ${WEBSITE_NAME[$i]} : " "${LOG_FILE[$i]}" | tail -n 1)\n\n"

        # Include git status, if that option is enabled.
        if [[ $INCLUDE_GIT_STATUS == true ]]; then
            GIT_STATUS="$(cd "${WEBSITE_ROOT[$i]}"; git status)"
            if [[ $? == 0 ]]; then
                EMAIL_MSG+="Here are the file-level changes, as reported by Git:\n\n$GIT_STATUS\n\n"
            else
                EMAIL_MSG+="An error occurred while trying to check Git status:\n\n$GIT_STATUS\n\n"
            fi
        fi

        EMAIL_MSG+="Thank you."

        # Construct the message.
        THE_EMAIL="From: $EMAIL_FROM\nTo: $EMAIL_TO\nSubject: $EMAIL_SUBJ\n$EMAIL_MSG\n.\n"

        if [[ $DEBUG_MODE == true ]]; then
            # Print the message, if in debug mode.
            printf "$THE_EMAIL\n\n"
        else
            # Send the message.
            printf "$THE_EMAIL" | $sendmail "$EMAIL_TO"
        fi

    fi

done # End iterating through websites.

exit $?