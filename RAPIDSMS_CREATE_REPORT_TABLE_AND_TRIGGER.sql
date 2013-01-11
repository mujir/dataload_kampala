CREATE TABLE received_bednets_report
(
  id serial NOT NULL,
  quantity integer NOT NULL,
  at_location character varying(50) NOT NULL
);
ALTER TABLE received_bednets_report  OWNER TO mtrack;
CREATE TABLE sent_bednets_report
(
  id serial NOT NULL,
  quantity integer NOT NULL,
  from_location character varying(50),
  at_location character varying(50) NOT NULL
);
ALTER TABLE sent_bednets_report  OWNER TO mtrack;
CREATE TABLE distributed_bednets_report
(
  id serial NOT NULL,
  quantity integer NOT NULL,
  at_location character varying(50) NOT NULL
);
ALTER TABLE distributed_bednets_report  OWNER TO mtrack;


CREATE INDEX distributed_at_location_index
  ON distributed_bednets_report
  USING btree
  (at_location COLLATE pg_catalog."default" );
CREATE INDEX at_location_index
  ON received_bednets_report
  USING btree
  (at_location COLLATE pg_catalog."default" );
CREATE INDEX sent_at_location_index
  ON sent_bednets_report
  USING btree
  (at_location COLLATE pg_catalog."default" );
CREATE INDEX sent_from_location_index
  ON sent_bednets_report
  USING btree
  (at_location COLLATE pg_catalog."default" );


CREATE  OR REPLACE FUNCTION fillBednetsReport() 
RETURNS TRIGGER AS 
$BODY$
	DECLARE 
		rawMessage TEXT;
		mssgType TEXT;	
		mssgPart Text[];
	BEGIN
		
		SELECT raw INTO rawMessage FROM rapidsms_xforms_xformsubmission WHERE id = NEW.id and has_errors='f';

		select regexp_split_to_table(rawMessage, E'\\.') into mssgType limit 1;

		if mssgType ilike 'recv' then
			select regexp_split_to_array(rawMessage, E'\\.') into mssgPart;
			insert into received_bednets_report (quantity,at_location) values(mssgPart[2]::int,mssgPart[3]);			
		end if;
		if mssgType ilike 'send' then
			select regexp_split_to_array(rawMessage, E'\\.') into mssgPart;
			insert into sent_bednets_report (quantity,from_location,at_location) values(mssgPart[2]::int,mssgPart[3],mssgPart[4]);	
		end if;
		if mssgType ilike 'dist' then
			select regexp_split_to_array(rawMessage, E'\\.') into mssgPart;
			insert into distributed_bednets_report (quantity,at_location) values(mssgPart[2]::int,mssgPart[3]);	
		end if;

	  RETURN NULL;
	END;
$BODY$
		 LANGUAGE plpgsql;

CREATE TRIGGER populate_bednets_report
		AFTER INSERT ON rapidsms_xforms_xformsubmission
		FOR EACH ROW
		EXECUTE PROCEDURE fillBednetsReport() ;


