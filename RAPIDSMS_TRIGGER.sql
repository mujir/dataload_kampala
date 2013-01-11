CREATE  OR REPLACE FUNCTION createEavValue() 
RETURNS TRIGGER AS 
$BODY$
	DECLARE 
		rawMessage TEXT;
		eavValue TEXT;
		xformId Text;
		attributeId Text;
		mssgType TEXT;	
		mssgPart Text[];
		submissionId int;
	BEGIN
	
		-- attribute ids for SEND - 422, 423, 424 
		-- attribute ids for RECV - 425, 426
		-- attribute ids for DIST - 427, 428
		
		SELECT raw, xform_id, id::int INTO rawMessage, xformId, submissionId FROM rapidsms_xforms_xformsubmission WHERE id = NEW.id;

		select regexp_split_to_table(rawMessage, E'\\.') into mssgType limit 1;

		if mssgType ilike 'recv' then
			select regexp_split_to_array(rawMessage, E'\\.') into mssgPart;
			insert into eav_value (entity_ct_id, generic_value_ct_id, entity_id, value_int, created, modified, attribute_id) values(37, 37, submissionId, mssgPart[2]::int, now(), now(), 425);
			insert into eav_value (entity_ct_id, generic_value_ct_id, entity_id, value_text, created, modified, attribute_id) values(37, 37, submissionId, mssgPart[3], now(), now(), 426);	
		end if;
		if mssgType ilike 'send' then
			select regexp_split_to_array(rawMessage, E'\\.') into mssgPart;
			insert into eav_value (entity_ct_id, generic_value_ct_id, entity_id, value_int, created, modified, attribute_id) values(37, 37, submissionId, mssgPart[2]::int, now(), now(), 422);
			insert into eav_value (entity_ct_id, generic_value_ct_id, entity_id, value_text, created, modified, attribute_id) values(37, 37, submissionId, mssgPart[3], now(), now(), 423);	
			insert into eav_value (entity_ct_id, generic_value_ct_id, entity_id, value_text, created, modified, attribute_id) values(37, 37, submissionId, mssgPart[4], now(), now(), 424);	
		end if;
		if mssgType ilike 'dist' then
			select regexp_split_to_array(rawMessage, E'\\.') into mssgPart;
			insert into eav_value (entity_ct_id, generic_value_ct_id, entity_id, value_int, created, modified, attribute_id) values(37, 37, submissionId, mssgPart[2]::int, now(), now(), 427);
			insert into eav_value (entity_ct_id, generic_value_ct_id, entity_id, value_text, created, modified, attribute_id) values(37, 37, submissionId, mssgPart[3], now(), now(), 428);	
		end if;

	  RETURN NULL;
	END;
$BODY$
		 LANGUAGE plpgsql;


CREATE TRIGGER benerator_trigger_to_populate_eav_value
		AFTER INSERT ON rapidsms_xforms_xformsubmission
		FOR EACH ROW
		EXECUTE PROCEDURE createEavValue();

