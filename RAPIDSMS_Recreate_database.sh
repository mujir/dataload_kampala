#~/bin/sh

start_Time=`date +%s`

sudo -u postgres dropdb mtrack
sudo -u postgres createdb mtrack
~/code/mtrack/mtrack_project/manage.py syncdb
~/code/mtrack/mtrack_project/manage.py migrate
~/code/mtrack/mtrack_project/manage.py loaddata healthmodels locations

##read -n1 -r -p "Please remove the constraints on rapidsms_contact from database. Press any key to start."
##read -n1 -r -p "Please add the trigger to rapidsms_xforms_xformsubmission table to create eav_value entries"
##sudo -u postgres psql mtrack -c "ALTER TABLE rapidsms_contact  drop CONSTRAINT reporting_location_id_refs_id_8c3a8f57"
##sudo -u postgres psql mtrack -c "ALTER TABLE rapidsms_contact  drop CONSTRAINT user_id_refs_id_c38d4eb8"
##sudo -u postgres psql mtrack -c "ALTER TABLE rapidsms_contact  drop CONSTRAINT village_id_refs_id_8c3a8f57"
##sudo -u postgres psql mtrack -c "ALTER TABLE rapidsms_contact  drop CONSTRAINT rapidsms_contact_user_id_key"

sudo -u postgres psql mtrack -f "RAPIDSMS_TRIGGER.sql"

benerator.sh shop.ben.xml

end_Time=`date +%s`
execution_time=`expr $((end_Time - start_Time))`

echo ""
echo ""
echo "TOTAL TIME TAKEN - $execution_time secs"
