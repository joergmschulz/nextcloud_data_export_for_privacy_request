#!/bin/bash

# this script executes an audit for a specified user


audit_user='joerg.schulz'

echo "========================
LISTE IHRER DATEIEN" > $audit_user.log
ssh root@c "(find /data/nc/$audit_user)" >> $audit_user.log
ssh root@c "(find /data/nc/appdata_oc2577a033c1/identityproof/user-$audit_user)" >> $audit_user.log



echo "========================
LISTE aller Datenbankeinträge auf Ihren Namen" >> $audit_user.log


declare -a queries=("SELECT * FROM public.oc_accounts where uid like '$audit_user';"
"SELECT * FROM public.oc_polls_votes where user_id like '$audit_user';"
"SELECT *  FROM oc_ldap_user_mapping where owncloud_name = '$audit_user';"
"SELECT * FROM public.oc_mail_accounts where user_id like '$audit_user';"
"SELECT id , principaluri  FROM oc_addressbooks where principaluri like '$audit_user';"
"select * from oc_cards left join oc_addressbooks on oc_addressbooks.id = oc_cards.addressbookid  where principaluri like '%$audit_user';"
"SELECT displayname as calendarname FROM public.oc_calendars where principaluri like '%$audit_user';"
"SELECT message as comment  FROM public.oc_comments where actor_id like '$audit_user';"
"SELECT * FROM public.oc_deck_boards where owner like '$audit_user';"
"SELECT title as deck_title FROM public.oc_deck_boards where owner = '$audit_user';"
"SELECT title as deck_cards_title FROM public.oc_deck_cards where owner = '$audit_user';"
"SELECT title as deck_stack_title FROM public.oc_deck_stacks where board_id in (SELECT id FROM public.oc_deck_boards where owner = '$audit_user');"
"SELECT data as deck_attachment FROM public.oc_deck_attachment where created_by = '$audit_user';"
"SELECT count(*) encrypted_calendarobjects  FROM public.oc_calendarobjects where calendarid in (SELECT id from public.oc_calendars where principaluri like '%$audit_user' );"
"SELECT id  deleted_file FROM public.oc_files_trash  where public.oc_files_trash.user::text like '%$audit_user';"
"SELECT * FROM public.oc_mail_accounts where user_id like '%$audit_user';"
"SELECT file_name mail_attachment FROM public.oc_mail_attachments where user_id = '$audit_user';"
"SELECT name as mailbox_name, special_use FROM public.oc_mail_mailboxes where public.oc_mail_mailboxes.account_id in (select id from oc_mail_accounts where user_id = '$audit_user');"
"SELECT * FROM public.oc_mail_messages left join public.oc_mail_mailboxes on oc_mail_mailboxes.id = public.oc_mail_messages.mailbox_id::int where public.oc_mail_mailboxes.account_id in (select id from oc_mail_accounts where user_id = '$audit_user');"
"SELECT user_id collector, email collected_email_address, display_name collected_address_display_name FROM public.oc_mail_coll_addresses where public.oc_mail_coll_addresses.user_id = '$audit_user' or public.oc_mail_coll_addresses.email like '$audit_user'"
"SELECT label, email FROM public.oc_mail_recipients where message_id in (SELECT public.oc_mail_messages.id FROM public.oc_mail_messages left join public.oc_mail_mailboxes on oc_mail_mailboxes.id = public.oc_mail_messages.mailbox_id::int where public.oc_mail_mailboxes.account_id in (select id from oc_mail_accounts where user_id = '$audit_user'))"
"SELECT label as title_of_passman_entry_rest_is_encrypted FROM public.oc_passman_credentials where user_id::text = '$audit_user';"
"SELECT title polls_title, description FROM public.oc_polls_polls where owner::text = '$audit_user';"
"SELECT * FROM public.oc_preferences where userid::text = '$audit_user';"
"SELECT share_with, uid_owner, uid_initiator, item_source, file_target FROM public.oc_share where uid_owner::text = '$audit_user' or uid_initiator::text = '$audit_user';"
"SELECT * FROM public.oc_talk_participants where user_id::text = '$audit_user';"
"SELECT *  FROM oc_activity  where affecteduser::text  = '$audit_user' or oc_activity.user::text = '$audit_user'::text"
)

for query in "${queries[@]}" ; do
  ssh murg "(cd /usr/local/src/docker/nextcloud && sudo docker-compose exec -T -u postgres postgres psql -P pager=off  -d nextcloud_db -c \"$query\" )" >> $audit_user.log ;
done
